module main

import simplegui
import system
import os
import time

struct ProcessRecord {
	pid     string
	ppid    string
	user    string
	cpu     f64
	mem     f64
	state   string
	command string
}

fn parse_float_safe(s string) f64 {
	return s.trim_space().f64()
}

fn format_uptime_seconds(sec u64) string {
	hours := sec / 3600
	mins := (sec % 3600) / 60
	secs := sec % 60
	return '${hours}h ${mins}m ${secs}s'
}

fn fetch_process_list(sort_mode string) ![]ProcessRecord {
	// Query real OS process table via ps
	sort_flag := match sort_mode {
		'Sort: Top Memory' { '-m' }
		'Sort: PID (Ascending)' { '-p' }
		else { '-r' } // default top CPU
	}

	res := system.exec_safe('ps', ['-axo', 'pid,ppid,user,%cpu,%mem,stat,comm', sort_flag])
	if res.exit_code != 0 {
		return error(res.output)
	}

	lines := res.output.split_into_lines()
	mut list := []ProcessRecord{}
	for i, line in lines {
		if i == 0 {
			continue // skip header
		}
		tokens := line.trim_space().split_any(' \t').filter(it != '')
		if tokens.len >= 7 {
			list << ProcessRecord{
				pid: tokens[0]
				ppid: tokens[1]
				user: tokens[2]
				cpu: parse_float_safe(tokens[3])
				mem: parse_float_safe(tokens[4])
				state: tokens[5]
				command: tokens[6..].join(' ')
			}
		}
	}

	if sort_mode == 'Sort: Process Name (A-Z)' {
		list.sort(a.command.to_lower() < b.command.to_lower())
	} else if sort_mode == 'Sort: PID (Ascending)' {
		list.sort(a.pid.int() < b.pid.int())
	}
	return list
}

fn inspect_process_details(pid string) string {
	if pid == '' || pid == '-' {
		return 'No process selected. Click a process in the table or enter a PID above.'
	}

	// Fetch detailed process info
	p_res := system.exec_safe('ps', ['-p', pid, '-o', 'pid,ppid,user,%cpu,%mem,stat,time,command'])
	if p_res.exit_code != 0 || p_res.output.trim_space() == '' {
		return '❌ Process PID ${pid} is not currently running or has terminated.'
	}

	lines := p_res.output.split_into_lines()
	full_cmd := if lines.len > 1 {
		tokens := lines[1].trim_space().split_any(' \t').filter(it != '')
		if tokens.len >= 8 { tokens[7..].join(' ') } else { lines[1] }
	} else {
		'Unavailable'
	}

	// Check binary path if available
	mut bin_path := 'Unknown'
	if full_cmd.starts_with('/') {
		bin_tokens := full_cmd.split(' ')
		if bin_tokens.len > 0 && os.exists(bin_tokens[0]) {
			bin_path = bin_tokens[0]
		}
	}

	return [
		'═══════════════════════════════════════════════════════════════════',
		'  ⚡ PROCESS INSPECTION REPORT: PID ${pid}',
		'═══════════════════════════════════════════════════════════════════',
		'Target PID:          ${pid}',
		'Executable Path:     ${bin_path}',
		'Raw PS Output:       ${lines.filter(it != '').join('\n')}',
		'',
		'Full Command Line Execution:',
		'-------------------------------------------------------------------',
		full_cmd,
		'-------------------------------------------------------------------',
		'POSIX Signal Options: SIGTERM (graceful), SIGKILL -9 (force kill),',
		'                      SIGSTOP (pause), SIGCONT (resume).',
	].join('\n')
}

fn get_system_health_report() string {
	t := system.get_hardware_telemetry()
	now := time.now().format_ss()
	ram_usage_pct := if t.ram_total_bytes > 0 { (f64(t.ram_used_bytes) / f64(t.ram_total_bytes)) * 100.0 } else { 0.0 }

	df_res := system.exec_safe('df', ['-h'])
	df_out := if df_res.exit_code == 0 { df_res.output.trim_space() } else { 'Unavailable' }

	return [
		'═══════════════════════════════════════════════════════════════════',
		'  💻 SYSTEM RESOURCES & TELEMETRY REPORT',
		'═══════════════════════════════════════════════════════════════════',
		'Timestamp:        ${now}',
		'Operating System: ${t.os_name} ${t.os_version}',
		'Hostname:         ${t.hostname}',
		'Architecture:     ${t.cpu_arch}',
		'CPU Model:        ${t.cpu_model}',
		'Logical Cores:    ${t.cpu_cores}',
		'Load Average:     1m: ${t.load_avg_1:.2f} | 5m: ${t.load_avg_5:.2f} | 15m: ${t.load_avg_15:.2f}',
		'System Uptime:    ${format_uptime_seconds(t.uptime_seconds)}',
		'',
		'MEMORY UTILIZATION:',
		'-------------------------------------------------------------------',
		'Total Physical:   ${system.format_bytes(t.ram_total_bytes)}',
		'Used Physical:    ${system.format_bytes(t.ram_used_bytes)} (${ram_usage_pct:.1f}%)',
		'Available Free:   ${system.format_bytes(t.ram_free_bytes)}',
		'',
		'BATTERY & POWER SENSOR:',
		'-------------------------------------------------------------------',
		'Charge Level:     ${t.battery_percent}%',
		'Charging State:   ${if t.battery_charging { 'AC Connected (Charging)' } else { 'Battery Power' }}',
		'',
		'STORAGE PARTITIONS & MOUNTS (df -h):',
		'-------------------------------------------------------------------',
		df_out,
	].join('\n')
}

fn refresh_task_manager_gui(w &simplegui.SimpleWindow) {
	filter_text := w.get_value('proc_filter').trim_space().to_lower()
	sort_mode := w.get_value('proc_sort')

	processes := fetch_process_list(sort_mode) or {
		w.toast_error('Failed to query process table: ${err}')
		return
	}

	mut filtered := []ProcessRecord{}
	for p in processes {
		if filter_text == '' || p.command.to_lower().contains(filter_text)
			|| p.pid.contains(filter_text) || p.user.to_lower().contains(filter_text)
			|| p.state.to_lower().contains(filter_text) {
			filtered << p
		}
	}

	mut table_rows := [][]string{}
	for i, p in filtered {
		if i >= 40 {
			break
		}
		table_rows << [
			p.pid,
			p.ppid,
			p.user,
			'${p.cpu:.1f}%',
			'${p.mem:.1f}%',
			p.state,
			p.command,
		]
	}

	if table_rows.len == 0 {
		table_rows << ['-', '-', '-', '-', '-', '-', 'No processes matching "${filter_text}"']
	}

	t := system.get_hardware_telemetry()
	ram_usage_pct := if t.ram_total_bytes > 0 { (f64(t.ram_used_bytes) / f64(t.ram_total_bytes)) * 100.0 } else { 0.0 }
	top_proc := if processes.len > 0 { '${processes[0].command} (${processes[0].cpu:.1f}%)' } else { 'None' }

	w.set_kpi('kpi_processes', '${processes.len} Active', '${filtered.len} Filtered')
	w.set_kpi('kpi_cpu_load', '${t.cpu_cores} Cores', 'Load: ${t.load_avg_1:.2f}, ${t.load_avg_5:.2f}')
	w.set_kpi('kpi_ram', system.format_bytes(t.ram_used_bytes), '${ram_usage_pct:.1f}% of ${system.format_bytes(t.ram_total_bytes)}')
	w.set_kpi('kpi_uptime', format_uptime_seconds(t.uptime_seconds), '${t.os_name} ${t.cpu_arch}')

	w.set_table_rows('proc_table', table_rows)
	w.set_value('sys_inspector', get_system_health_report())

	selected_pid := w.get_value('target_pid').trim_space()
	if selected_pid != '' && selected_pid != '-' {
		w.set_value('proc_inspector', inspect_process_details(selected_pid))
	}

	w.set_status('Task Manager updated at ${time.now().format_ss()} • ${processes.len} active processes • Top: ${top_proc}')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Advanced Task Manager Studio Pro Enterprise'
		width: 1240
		height: 920
		theme: 'dracula'
	)

	win.heading('⚡ Advanced Task Manager Studio Pro Enterprise')
	win.subheading('Real-Time Operating System Process Monitor, POSIX Task Signaling & Subsystem Hardware Telemetry')
	win.divider()

	// Initial fetch
	init_t := system.get_hardware_telemetry()
	init_ram_pct := if init_t.ram_total_bytes > 0 { (f64(init_t.ram_used_bytes) / f64(init_t.ram_total_bytes)) * 100.0 } else { 0.0 }
	init_procs := fetch_process_list('Sort: Top CPU') or { []ProcessRecord{} }
	mut init_rows := [][]string{}
	for i, p in init_procs {
		if i >= 40 {
			break
		}
		init_rows << [p.pid, p.ppid, p.user, '${p.cpu:.1f}%', '${p.mem:.1f}%', p.state, p.command]
	}
	if init_rows.len == 0 {
		init_rows << ['-', '-', '-', '-', '-', '-', 'Scanning processes...']
	}

	// 1. Top Telemetry KPI Cards
	win.row_start()
	win.kpi_card_named('kpi_processes', 'Active Processes', '${init_procs.len} Active', 'Real-Time')
	win.kpi_card_named('kpi_cpu_load', 'CPU & Load Average', '${init_t.cpu_cores} Cores', 'Load: ${init_t.load_avg_1:.2f}, ${init_t.load_avg_5:.2f}')
	win.kpi_card_named('kpi_ram', 'Physical RAM', system.format_bytes(init_t.ram_used_bytes), '${init_ram_pct:.1f}% Used')
	win.kpi_card_named('kpi_uptime', 'System Uptime', format_uptime_seconds(init_t.uptime_seconds), '${init_t.os_name} ${init_t.cpu_arch}')
	win.row_end()

	// 2. Filter & Sort Toolbar
	win.box_start('🔍 Process Filters & Sorting Deck')
	win.row_start()
	win.input_named('proc_filter', 'Filter by command name, user, state, or PID...', '', fn (w &simplegui.SimpleWindow, _ string) {
		refresh_task_manager_gui(w)
	})
	win.dropdown_named('proc_sort', [
		'Sort: Top CPU',
		'Sort: Top Memory',
		'Sort: Process Name (A-Z)',
		'Sort: PID (Ascending)',
	], 'Sort: Top CPU', fn (w &simplegui.SimpleWindow, _ string) {
		refresh_task_manager_gui(w)
	})
	win.button('🔄 Refresh Now', fn (w &simplegui.SimpleWindow, _ string) {
		refresh_task_manager_gui(w)
		w.toast_info('Process table refreshed successfully.')
	})
	win.button('📋 Export CSV', fn (w &simplegui.SimpleWindow, _ string) {
		procs := fetch_process_list(w.get_value('proc_sort')) or {
			w.toast_error('Failed to generate export: ${err}')
			return
		}
		mut csv_lines := ['PID,PPID,User,CPU_Pct,Mem_Pct,State,Command']
		for p in procs {
			csv_lines << '${p.pid},${p.ppid},"${p.user}",${p.cpu},${p.mem},"${p.state}","${p.command}"'
		}
		save_dest := w.save_file_dialog('Export Process Snapshot CSV', 'process_snapshot.csv')
		if save_dest != '' {
			os.write_file(save_dest, csv_lines.join('\n')) or {
				w.toast_error('Failed to write CSV file: ${err}')
				return
			}
			w.toast_success('Exported ${procs.len} processes to ${save_dest}')
		} else {
			system.set_clipboard_text(csv_lines.join('\n'))
			w.toast_info('Copied ${procs.len} process records to clipboard.')
		}
	})
	win.row_end()
	win.box_end()

	// 3. Process Table Section
	win.box_start('📋 Live Active Process Table (Click any row to select PID)')
	initial_headers := ['PID', 'PPID', 'User', '% CPU', '% MEM', 'State', 'Command Name']
	win.table_named('proc_table', initial_headers, init_rows, fn (w &simplegui.SimpleWindow, row_idx_str string) {
		idx := row_idx_str.int()
		procs := fetch_process_list(w.get_value('proc_sort')) or { return }
		filter_text := w.get_value('proc_filter').trim_space().to_lower()
		mut filtered := []ProcessRecord{}
		for p in procs {
			if filter_text == '' || p.command.to_lower().contains(filter_text)
				|| p.pid.contains(filter_text) || p.user.to_lower().contains(filter_text)
				|| p.state.to_lower().contains(filter_text) {
				filtered << p
			}
		}
		if idx >= 0 && idx < filtered.len {
			target := filtered[idx]
			w.set_value('target_pid', target.pid)
			w.set_value('proc_inspector', inspect_process_details(target.pid))
			w.toast_info('Selected PID ${target.pid} (${target.command})')
		}
	})
	win.box_end()

	// 4. Process Control & POSIX Signaling Deck
	win.box_start('⚡ Process Control & POSIX Task Signaling')
	win.row_start()
	win.input_named('target_pid', 'Selected Target PID (e.g. 1234)...', '', fn (w &simplegui.SimpleWindow, val string) {
		if val.trim_space() != '' {
			w.set_value('proc_inspector', inspect_process_details(val.trim_space()))
		}
	})
	win.button('🔎 Inspect PID', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('target_pid').trim_space()
		if pid == '' {
			w.toast_error('Please select or enter a PID to inspect.')
			return
		}
		w.set_value('proc_inspector', inspect_process_details(pid))
		w.toast_info('Updated inspection report for PID ${pid}.')
	})
	win.button('⏹️ Terminate (SIGTERM)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('target_pid').trim_space()
		if pid == '' {
			w.toast_error('Select a PID first.')
			return
		}
		res := system.exec_safe('kill', ['-15', pid])
		if res.exit_code == 0 {
			w.toast_success('Sent SIGTERM to PID ${pid}.')
			time.sleep(200 * time.millisecond)
			refresh_task_manager_gui(w)
		} else {
			w.toast_error('Failed to terminate PID ${pid}: ${res.output}')
		}
	})
	win.button('💥 Force Kill (SIGKILL -9)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('target_pid').trim_space()
		if pid == '' {
			w.toast_error('Select a PID first.')
			return
		}
		res := system.exec_safe('kill', ['-9', pid])
		if res.exit_code == 0 {
			w.toast_warning('Force killed PID ${pid} (SIGKILL -9).')
			time.sleep(200 * time.millisecond)
			refresh_task_manager_gui(w)
		} else {
			w.toast_error('Failed to kill PID ${pid}: ${res.output}')
		}
	})
	win.button('⏸️ Pause (SIGSTOP)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('target_pid').trim_space()
		if pid == '' {
			w.toast_error('Select a PID first.')
			return
		}
		res := system.exec_safe('kill', ['-STOP', pid])
		if res.exit_code == 0 {
			w.toast_info('Suspended execution for PID ${pid} (SIGSTOP).')
			refresh_task_manager_gui(w)
		} else {
			w.toast_error('Failed to stop PID ${pid}: ${res.output}')
		}
	})
	win.button('▶️ Resume (SIGCONT)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('target_pid').trim_space()
		if pid == '' {
			w.toast_error('Select a PID first.')
			return
		}
		res := system.exec_safe('kill', ['-CONT', pid])
		if res.exit_code == 0 {
			w.toast_success('Resumed execution for PID ${pid} (SIGCONT).')
			refresh_task_manager_gui(w)
		} else {
			w.toast_error('Failed to resume PID ${pid}: ${res.output}')
		}
	})
	win.row_end()
	win.box_end()

	// 5. Dual-Pane Inspection Deck: Process Details vs. System Health
	win.raw_html('<style>
		#proc_inspector, #sys_inspector {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
			font-size: 11px !important;
			height: 220px !important;
			min-height: 220px !important;
			background: #191a21 !important;
			color: #50fa7b !important;
			border: 1px solid #282a36 !important;
			border-radius: 6px !important;
			line-height: 1.45 !important;
			padding: 8px !important;
		}
	</style>')

	win.row_start()

	win.box_start('🔬 Process Details & Command Inspector')
	win.textarea_named('proc_inspector', 'Process details inspector...', 'Select a process from the table above or enter a PID to view full arguments, path, and POSIX state.', fn (_ &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.box_start('📊 System Resources, Memory & Storage Partitions')
	win.textarea_named('sys_inspector', 'System telemetry...', get_system_health_report(), fn (_ &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.row_end()

	win.status_bar('Advanced Task Manager Studio Enterprise • ${init_procs.len} active processes • Ready')

	win.run()
}
