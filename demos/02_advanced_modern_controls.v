module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 2 - Advanced Modern Controls & Helper Wrappers'
		width: 960
		height: 720
		theme: 'tokyo_night'
	)

	win.heading('🚀 Advanced Modern Control Palette & Dynamic Helpers')
	win.subheading('Enterprise modern desktop widgets & telemetry KPI metrics:')
	win.divider()

	win.row_start()
	win.kpi_card('Active Users', '24,582', '+12.4% vs last week')
	win.kpi_card('Server Uptime', '99.98%', 'Optimal (30 days)')
	win.kpi_card('System Load', '1.14', 'Normal (14 cores)')
	win.row_end()

	win.box_start('Modern Interactive Controls')
	win.row_start()
	win.dropdown(['Overview', 'Analytics', 'Realtime', 'Reports', 'Audit Logs'], 'Overview', fn (w &simplegui.SimpleWindow, val string) {
		println('Selected Tab: ${val}')
	})
	win.toggle('Hardware Acceleration', true, fn (w &simplegui.SimpleWindow, val string) {})
	win.toggle('Cloud Telemetry Sync', false, fn (w &simplegui.SimpleWindow, val string) {})
	win.row_end()

	win.subheading('Deployment Progress (75% Complete):')
	win.progress(75, 100)

	win.row_start()
	win.slider(0, 100, 75, fn (w &simplegui.SimpleWindow, val string) {
		println('Progress slider: ${val}')
	})
	win.button('⚡ Trigger Notification', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('RAD Studio Demo 2', 'Modern desktop notification triggered successfully!')
	})
	win.row_end()
	win.box_end()

	win.box_start('Active Server Cluster Nodes')
	headers := ['Node ID', 'Region', 'Status', 'Load', 'Memory']
	rows := [
		['us-east-1a', 'N. Virginia', 'Online', '24%', '4.2 / 16 GB'],
		['eu-central-1', 'Frankfurt', 'Online', '38%', '8.1 / 16 GB'],
		['ap-southeast-1', 'Singapore', 'Online', '15%', '2.8 / 16 GB'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, row string) {
		println('Selected Node: ${row}')
	})
	win.box_end()

	win.status_bar('Cluster Health: 100% Operational | Latency: 18ms')

	win.run()
}
