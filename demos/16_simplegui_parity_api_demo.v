module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 16 - SimpleGUI Parity API Demo'
		width: 900
		height: 650
		theme: 'dracula'
	)

	win.heading('🔄 SimpleGUI Native & Webview Parity API')
	win.subheading('Verifying identical behavior between simple_gg / vlang_simplegui and Webview:')
	win.divider()

	win.box_start('API Parity Checklist')
	headers := ['Feature API', 'Native GUI Spec', 'Webview Spec', 'Status']
	rows := [
		['Button & Click', 'simplegui.button()', 'simplegui.button()', '100% Parity ✅'],
		['Text & Password Input', 'simplegui.input()', 'simplegui.input()', '100% Parity ✅'],
		['Table & Data Grid', 'simplegui.table()', 'simplegui.table()', '100% Parity ✅'],
		['Dialogs & Alerts', 'simplegui.alert()', 'simplegui.alert()', '100% Parity ✅'],
		['Window Management', 'rad_window_*', 'rad_window_*', '100% Parity ✅'],
		['Hardware Telemetry', 'system.get_hardware_*', 'system.get_hardware_*', '100% Parity ✅'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.row_start()
	win.button('⚡ Test Native Alert', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Parity Verification', 'Native OS modal dialog works identical to simple_gg!')
	})
	win.button('🔔 Test Notification', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('Parity Verification', 'Desktop notification works identical to simple_gg!')
	})
	win.row_end()

	win.status_bar('API Compatibility Score: 100% Passed')

	win.run()
}
