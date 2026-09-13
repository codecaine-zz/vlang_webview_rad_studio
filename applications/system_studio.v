module main

import simplegui
import system

fn refresh_system_telemetry(w &simplegui.SimpleWindow) {
	t := system.get_hardware_telemetry()
	tot_ram, free_ram, used_ram := system.get_memory_info()
	disk := system.get_disk_info('/')

	uptime_hours := t.uptime_seconds / 3600
	uptime_mins := (t.uptime_seconds % 3600) / 60
	uptime_secs := t.uptime_seconds % 60
	uptime_str := '${uptime_hours}h ${uptime_mins}m ${uptime_secs}s'

	ram_pct := if tot_ram > 0 { f64(used_ram) * 100.0 / f64(tot_ram) } else { 0.0 }
	disk_pct := if disk.total_bytes > 0 { f64(disk.used_bytes) * 100.0 / f64(disk.total_bytes) } else { 0.0 }

	w.set_kpi('kpi_cpu', '${t.cpu_cores} Cores (${t.cpu_arch})', 'Load: ${t.load_avg_1:.2f}, ${t.load_avg_5:.2f}')
	w.set_kpi('kpi_ram', '${system.format_bytes(used_ram)} / ${system.format_bytes(tot_ram)}', '${ram_pct:.1f}% In Use')
	w.set_kpi('kpi_disk', '${system.format_bytes(disk.used_bytes)} / ${system.format_bytes(disk.total_bytes)}', '${disk_pct:.1f}% (${disk.mount_point})')
	w.set_kpi('kpi_os', '${t.os_name} ${t.os_version}', 'Uptime: ${uptime_str}')

	specs_rows := [
		['Processor Model', t.cpu_model, 'Active'],
		['CPU Architecture', t.cpu_arch, 'Native'],
		['Logical CPU Cores', t.cpu_cores.str(), 'Online'],
		['Load Average (1m, 5m, 15m)', '${t.load_avg_1:.2f}, ${t.load_avg_5:.2f}, ${t.load_avg_15:.2f}', 'Nominal'],
		['Total Physical RAM', system.format_bytes(tot_ram), 'Installed'],
		['Used Physical RAM', system.format_bytes(used_ram), '${ram_pct:.1f}%'],
		['Free Physical RAM', system.format_bytes(free_ram), 'Available'],
		['Host Machine Name', t.hostname, 'Resolved'],
		['Operating System', '${t.os_name} ${t.os_version}', 'Kernel Verified'],
		['System Uptime', uptime_str, 'Stable'],
		['Battery Status', '${t.battery_percent}%' + (if t.battery_charging { ' (Charging)' } else { '' }), 'Power Profile'],
		['AC Power Connected', if t.ac_connected { 'Yes' } else { 'No' }, 'Hardware Sensor'],
	]
	w.set_table_rows('specs_table', specs_rows)

	disk_rows := [
		[disk.mount_point, system.format_bytes(disk.total_bytes), system.format_bytes(disk.used_bytes), system.format_bytes(disk.free_bytes), '${disk_pct:.1f}%'],
	]
	w.set_table_rows('disk_table', disk_rows)

	w.set_status('Hardware telemetry refreshed • CPU: ${t.cpu_model} • RAM: ${ram_pct:.1f}% • Host: ${t.hostname}')
}

fn generate_system_report() string {
	t := system.get_hardware_telemetry()
	tot_ram, free_ram, used_ram := system.get_memory_info()
	disk := system.get_disk_info('/')

	return '==================================================\n' +
		'  Vlang Webview RAD Studio - System Report\n' +
		'==================================================\n' +
		'OS:         ${t.os_name} ${t.os_version}\n' +
		'Hostname:   ${t.hostname}\n' +
		'CPU Model:  ${t.cpu_model} (${t.cpu_cores} Cores, ${t.cpu_arch})\n' +
		'Load Avg:   ${t.load_avg_1:.2f}, ${t.load_avg_5:.2f}, ${t.load_avg_15:.2f}\n' +
		'RAM Total:  ${system.format_bytes(tot_ram)}\n' +
		'RAM Used:   ${system.format_bytes(used_ram)}\n' +
		'RAM Free:   ${system.format_bytes(free_ram)}\n' +
		'Disk Total: ${system.format_bytes(disk.total_bytes)}\n' +
		'Disk Used:  ${system.format_bytes(disk.used_bytes)} (${disk.mount_point})\n' +
		'Uptime:     ${t.uptime_seconds} seconds\n' +
		'Battery:    ${t.battery_percent}% (AC: ${t.ac_connected})\n' +
		'=================================================='
}

fn main() {
	mut win := simplegui.new_window(
		title: 'System Information Studio Pro Enterprise -- Hardware Intelligence Workstation'
		width: 1180
		height: 890
		theme: 'monokai_pro'
	)

	win.heading('⚡ System Information Studio Pro Enterprise')
	win.subheading('Enterprise-Grade Cross-Platform Hardware Intelligence, Core Telemetry & Diagnostics Workstation')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_cpu', 'CPU Processor', 'Scanning...', 'Load')
	win.kpi_card_named('kpi_ram', 'Physical Memory', 'Scanning...', 'RAM')
	win.kpi_card_named('kpi_disk', 'Primary Storage', 'Scanning...', 'Filesystem')
	win.kpi_card_named('kpi_os', 'Host & OS Platform', 'Scanning...', 'Uptime')
	win.row_end()

	// Actions Toolbar Box
	win.box_start('⚙️ Telemetry Controls & System Actions')
	win.row_start()
	win.button('🔄 Refresh Telemetry', fn (w &simplegui.SimpleWindow, _ string) {
		refresh_system_telemetry(w)
		w.toast_success('Hardware telemetry updated!')
	})
	win.button('📋 Copy System Report', fn (w &simplegui.SimpleWindow, _ string) {
		report := generate_system_report()
		system.set_clipboard_text(report)
		w.toast_success('Full system report copied to clipboard!')
	})
	win.button('🔔 Desktop Notification', fn (w &simplegui.SimpleWindow, _ string) {
		t := system.get_hardware_telemetry()
		w.notification('System Studio Pro', 'All ${t.cpu_cores} CPU cores operating normally.')
		w.toast_info('Triggered desktop notification')
	})
	win.button('🔊 Play Audio Alert', fn (w &simplegui.SimpleWindow, _ string) {
		system.beep()
		w.toast_info('Played system alert sound')
	})
	win.row_end()
	win.box_end()

	// Detailed Hardware Specs Table Box
	win.box_start('💻 Hardware Architecture & Operating System Specifications')
	specs_headers := ['Hardware Parameter', 'Reported Value', 'Diagnostic State']
	win.table_named('specs_table', specs_headers, [['Loading...', 'Detecting...', 'Standby']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspecting hardware parameter #${idx}')
	})
	win.box_end()

	// Storage & Filesystem Table Box
	win.box_start('💽 Storage Devices & Filesystem Partitions')
	disk_headers := ['Mount Point', 'Total Capacity', 'Used Space', 'Free Space', 'Utilization %']
	win.table_named('disk_table', disk_headers, [['/', 'Loading...', 'Loading...', 'Loading...', '0%']], fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('System Studio Pro Enterprise  •  Native V Hardware Probes  •  Online')

	// Initial population
	refresh_system_telemetry(win)

	win.run()
}
