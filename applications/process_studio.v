module main

import simplegui
import system

struct ProcessRecord {
	pid     string
	user    string
	cpu     string
	mem     string
	command string
}

fn load_process_records(sort_mode string) ![]ProcessRecord {
	sort_flag := if sort_mode == 'Sort: Top Memory' { '-m' } else { '-r' }
	res := system.exec_safe('ps', ['-axo', 'pid,user,%cpu,%mem,comm', sort_flag])
	if res.exit_code != 0 {
		return error(res.output)
	}
	lines := res.output.split_into_lines()
	mut records := []ProcessRecord{}
	for i, line in lines {
		if i == 0 {
			continue
		}
		tokens := line.trim_space().split_any(' \t').filter(it != '')
		if tokens.len >= 5 {
			records << ProcessRecord{
				pid: tokens[0]
				user: tokens[1]
				cpu: tokens[2]
				mem: tokens[3]
				command: tokens[4..].join(' ')
			}
		}
	}
	return records
}

fn refresh_process_gui(w &simplegui.SimpleWindow, sort_mode string, filter_text string) {
	records := load_process_records(sort_mode) or {
		w.toast_error('Failed to load processes: ${err}')
		return
	}

	lower_filter := filter_text.to_lower().trim_space()
	mut filtered := []ProcessRecord{}
	for r in records {
		if lower_filter == '' || r.command.to_lower().contains(lower_filter) || r.pid.contains(lower_filter) || r.user.to_lower().contains(lower_filter) {
			filtered << r
		}
	}

	mut rows := [][]string{}
	for i, r in filtered {
		if i >= 35 {
			break
		}
		rows << [r.pid, r.user, r.cpu + '%', r.mem + '%', r.command]
	}
	if rows.len == 0 {
		rows << ['-', '-', '-', '-', 'No processes matching "${filter_text}"']
	}

	top_cpu_str := if records.len > 0 { '${records[0].command} (${records[0].cpu}%)' } else { 'None' }
	t := system.get_hardware_telemetry()

	w.set_kpi('kpi_processes', '${records.len} Running', '${filtered.len} Filtered')
	w.set_kpi('kpi_top_cpu', top_cpu_str, 'Top CPU consumer')
	w.set_kpi('kpi_top_mem', system.format_bytes(t.ram_used_bytes), 'RAM in use')
	w.set_kpi('kpi_load', '${t.load_avg_1:.2f}, ${t.load_avg_5:.2f}', 'Load Average')

	w.set_table_rows('process_table', rows)
	w.set_status('Process list updated • ${records.len} total processes active • Top: ${top_cpu_str}')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Process & Task Manager Studio Pro Enterprise'
		width: 1180
		height: 890
		theme: 'dracula'
	)

	win.heading('⚡ Process & Task Manager Studio Pro Enterprise')
	win.subheading('Real-time Operating System Process Inspection, CPU/RAM Metrics, Filtering & Task Control')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_processes', 'Active Processes', '0 Running', 'Reading...')
	win.kpi_card_named('kpi_top_cpu', 'Top CPU Consumer', 'Scanning...', 'Usage')
	win.kpi_card_named('kpi_top_mem', 'Memory In Use', 'Scanning...', 'RAM')
	win.kpi_card_named('kpi_load', 'System Load Avg', '0.00, 0.00', '1m, 5m')
	win.row_end()

	// Process Controls & Filters Box
	win.box_start('🔍 Process Filters & Task Management Toolbar')
	win.row_start()
	win.input_named('proc_filter', 'Filter by command name, user, or PID...', '', fn (w &simplegui.SimpleWindow, val string) {
		sort_mode := w.get('sort_mode')
		refresh_process_gui(w, sort_mode, val)
	})
	sort_modes := ['Sort: Top CPU', 'Sort: Top Memory']
	win.dropdown_named('sort_mode', sort_modes, sort_modes[0], fn (w &simplegui.SimpleWindow, val string) {
		filter_text := w.get('proc_filter')
		refresh_process_gui(w, val, filter_text)
	})
	win.button('🔄 Refresh Processes', fn (w &simplegui.SimpleWindow, _ string) {
		sort_mode := w.get('sort_mode')
		filter_text := w.get('proc_filter')
		refresh_process_gui(w, sort_mode, filter_text)
		w.toast_success('Process table refreshed')
	})
	win.row_end()

	// Signal & Action Controls
	win.row_start()
	win.input_named('target_pid', 'Target Process PID to signal...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🛑 Terminate Process (SIGTERM)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get('target_pid').trim_space()
		if pid == '' || !pid.bytes().all(it.is_digit()) {
			w.toast_warning('Please enter a numeric process PID.')
			return
		}
		res := system.exec_safe('kill', [pid])
		if res.exit_code == 0 {
			w.toast_success('Sent SIGTERM to process PID ${pid}')
		} else {
			w.toast_error('Failed to terminate PID ${pid}: ' + res.output)
		}
		sort_mode := w.get('sort_mode')
		filter_text := w.get('proc_filter')
		refresh_process_gui(w, sort_mode, filter_text)
	})
	win.button('⛔ Force Kill (SIGKILL -9)', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get('target_pid').trim_space()
		if pid == '' || !pid.bytes().all(it.is_digit()) {
			w.toast_warning('Please enter a numeric process PID.')
			return
		}
		res := system.exec_safe('kill', ['-9', pid])
		if res.exit_code == 0 {
			w.toast_warning('Force killed process PID ${pid}')
		} else {
			w.toast_error('Failed to kill PID ${pid}: ' + res.output)
		}
		sort_mode := w.get('sort_mode')
		filter_text := w.get('proc_filter')
		refresh_process_gui(w, sort_mode, filter_text)
	})
	win.button('🔍 Inspect Details', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get('target_pid').trim_space()
		if pid == '' || !pid.bytes().all(it.is_digit()) {
			w.toast_warning('Enter a numeric PID.')
			return
		}
		res := system.exec_safe('ps', ['-p', pid, '-o', 'pid,ppid,user,%cpu,%mem,start,time,comm'])
		if res.exit_code == 0 {
			w.set_value('proc_details', res.output)
			w.toast_info('Loaded details for PID ${pid}')
		} else {
			w.toast_error('Process PID ${pid} not found')
		}
	})
	win.row_end()
	win.box_end()

	// Process Table Box
	win.box_start('📋 Running System Processes')
	headers := ['PID', 'User', '% CPU', '% MEM', 'Command Path']
	win.table_named('process_table', headers, [['-', '-', '-', '-', 'Loading processes...']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspecting process #${idx}')
	})
	win.box_end()

	// Selected Process Details Box
	win.box_start('📑 Selected Process Inspection Console')
	win.raw_html('<style>
		#proc_details {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 100px;
			min-height: 100px;
			background: #191a21;
			color: #50fa7b;
			border: 1px solid #282a36;
			border-radius: 6px;
			line-height: 1.45;
			padding: 8px;
		}
	</style>')
	win.textarea_named('proc_details', 'Click "Inspect Details" above to view full process arguments, threads, and start time...', 'Process inspection details will appear here...', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Task Manager Studio Pro Enterprise  •  POSIX Process Engine  •  Online')

	// Initial population
	refresh_process_gui(win, 'Sort: Top CPU', '')

	win.run()
}
