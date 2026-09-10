module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 15 - SimpleGUI All Controls Showcase'
		width: 1040
		height: 760
		theme: 'tokyo_night'
	)

	win.heading('🎨 SimpleGUI All-Controls Gallery')
	win.subheading('Comprehensive showcase of all native widgets rendered via declarative V API:')
	win.divider()

	win.row_start()
	win.kpi_card('Total Components', '70+', 'Standard, Modern & Data')
	win.kpi_card('Active Themes', '42 Themes', 'Sonoma, Fluent, Retro')
	win.kpi_card('Render Backend', 'Webview C', 'Hardware Accelerated')
	win.row_end()

	win.box_start('Input & Selector Controls')
	win.row_start()
	win.input('Text Input', 'Sample text', fn (w &simplegui.SimpleWindow, _ string) {})
	win.password('Password', 'password123', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Option Alpha', 'Option Beta', 'Option Gamma'], 'Option Alpha', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.checkbox('Standard Checkbox', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Modern Toggle Switch', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.slider(0, 100, 50, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Progress & Metrics')
	win.subheading('System Capacity Utilization (68%):')
	win.progress(68, 100)
	win.box_end()

	win.box_start('Tabular Data Grid')
	headers := ['ID', 'Component', 'Category', 'Supported Platform']
	rows := [
		['01', 'Button & Actions', 'Standard', 'macOS, Windows, Linux'],
		['02', 'Data Table Grid', 'Data-Aware', 'Cross-Platform'],
		['03', 'Window Management', 'System/FFI', 'Cocoa, Win32, GTK'],
		['04', 'Hardware Telemetry', 'Subsystems', 'sysctl, wmic, /proc'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('SimpleGUI v2.0 | Status: All systems nominal')

	win.run()
}
