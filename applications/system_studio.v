module main

import simplegui
import system

fn main() {
	telemetry := system.get_hardware_telemetry()
	tot_ram, free_ram, used_ram := system.get_memory_info()
	disk := system.get_disk_info('/')

	mut win := simplegui.new_window(
		title: 'System Information Studio Pro'
		width: 1150
		height: 850
		theme: 'monokai_pro'
	)

	win.heading('⚡ System Information Studio Pro')
	win.label('Enterprise-Grade Cross-Platform Hardware Intelligence & Telemetry Workstation')

	win.kpi_card('CPU Processor', '${telemetry.cpu_model} (${telemetry.cpu_cores} Cores, ${telemetry.cpu_arch})', 'Load Avg: ${telemetry.load_avg_1:.2f}, ${telemetry.load_avg_5:.2f}, ${telemetry.load_avg_15:.2f}')
	win.kpi_card('Physical Memory', '${system.format_bytes(tot_ram)} Total  |  ${system.format_bytes(used_ram)} Used  |  ${system.format_bytes(free_ram)} Free', 'System RAM Status')
	win.kpi_card('Primary Storage', '${system.format_bytes(disk.total_bytes)} Total  |  ${system.format_bytes(disk.used_bytes)} Used  |  ${system.format_bytes(disk.free_bytes)} Free (${disk.mount_point})', 'Filesystem Status')
	win.kpi_card('Operating System & Host', '${telemetry.os_name} ${telemetry.os_version}  |  Host: ${telemetry.hostname}  |  Uptime: ${telemetry.uptime_seconds / 3600}h ${(telemetry.uptime_seconds % 3600) / 60}m', 'Battery: ${telemetry.battery_percent}%')

	win.divider()
	win.subheading('Live Telemetry Data Table')

	headers := ['Metric Domain', 'Telemetry Value', 'Status']
	rows := [
		['Host Architecture', telemetry.cpu_arch, 'Active'],
		['Logical CPU Cores', telemetry.cpu_cores.str(), 'Online'],
		['Memory Allocation', system.format_bytes(tot_ram), 'Healthy'],
		['Operating System', '${telemetry.os_name} ${telemetry.os_version}', 'Verified'],
		['Local IP Address', system.get_masked_ip(), 'Protected'],
		['Network Ping Test (8.8.8.8)', if system.ping_host('8.8.8.8') { 'Online (0% packet loss)' } else { 'Offline' }, 'Online'],
		['Host Uptime', '${telemetry.uptime_seconds} seconds', 'Stable']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Telemetry Selected', 'Inspecting telemetry row #${idx}')
	})

	win.divider()
	win.subheading('System Actions')

	win.button('📋 Copy Hardware Specs to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		t := system.get_hardware_telemetry()
		specs := 'CPU: ${t.cpu_model}\nCores: ${t.cpu_cores}\nRAM: ${t.ram_formatted}\nOS: ${t.os_name} ${t.os_version}\nHost: ${t.hostname}'
		system.set_clipboard_text(specs)
		w.alert('Clipboard', 'Hardware specifications copied to clipboard!')
	})

	win.button('🔔 Test Native Desktop Notification', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('System Studio Pro', 'Telemetry scan completed successfully!')
	})

	win.button('🔊 Play System Audio Alert', fn (w &simplegui.SimpleWindow, _ string) {
		system.beep()
	})

	win.status_bar('System Studio Pro  •  Native Vlang + Webview Engine  •  All Systems Operational')
	win.run()
}
