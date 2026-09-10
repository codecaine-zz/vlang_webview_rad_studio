module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 23 - All 42 Themes & 70+ Controls Ultimate Mega-Showcase'
		width: 1100
		height: 800
		theme: 'monokai_pro'
	)

	win.heading('👑 The Ultimate RAD Studio Mega-Showcase')
	win.subheading('70+ Delphi/VB Style Native Controls across all 42 Desktop Themes:')
	win.divider()

	win.row_start()
	win.kpi_card('Visual Controls', '70+ Types', 'Anchors & Docking')
	win.kpi_card('Built-in Themes', '42 Desktop', 'Pixel-perfect CSS')
	win.kpi_card('Window Placement', '9 Presets', 'Cocoa, Win32, GTK')
	win.kpi_card('FFI System APIs', '60+ Tools', 'Native Telemetry')
	win.row_end()

	win.box_start('42 Desktop Form Themes Selector & Style Mode')
	win.row_start()
	win.dropdown(simplegui.get_theme_names(), 'monokai_pro', fn (w &simplegui.SimpleWindow, val string) {
		println('Switching showcase theme: ${val}')
		w.set_theme(val)
	})
	win.radio('theme_mode', 'Dark Engine', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.radio('theme_mode', 'Light Engine', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('CSS Transitions', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Interactive Component Playground')
	win.row_start()
	win.input('User Input', 'Hello, Cross-Platform V Webview!', fn (w &simplegui.SimpleWindow, _ string) {})
	win.password('Secure Input', 'hunter2', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Desktop Client', 'Cloud Node', 'Embedded Edge'], 'Desktop Client', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.checkbox('Auto-start at Boot', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.radio('network_mode', 'Direct P2P', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.radio('network_mode', 'Relay Mesh', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Hardware Acceleration', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.slider(0, 100, 85, fn (w &simplegui.SimpleWindow, val string) {
		println('Volume: ${val}')
	})
	win.row_end()

	win.label('Active Workspace & Runtime Telemetry Notes:')
	win.textarea('Telemetry Logs', 'Webview FFI bridge initialized.\n42 theme styles injected.\nHardware acceleration active.\nAnchors and docking layout operational.', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.box_start('Overall System Health & Performance (94%)')
	win.progress(94, 100)
	win.box_end()

	win.box_start('System Telemetry & Architecture Parity')
	headers := ['Subsystem', 'Engine Driver', 'Status', 'Parity']
	rows := [
		['Webview FFI', 'C/C++ Native Wrapper', 'Active', '100%'],
		['Window Management', 'Cocoa / Win32 / GTK', 'Active', '100%'],
		['Hardware Telemetry', 'sysctl / wmic / /proc', 'Active', '100%'],
		['Theme Catalog', '42 Built-in CSS Engines', 'Active', '100%'],
		['RAD Form Designer', 'Delphi Visual Anchors/Dock', 'Active', '100%'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.row_start()
	win.button('🚀 Launch System Studio', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Studio Launcher', 'Launching System Studio Pro...')
	})
	win.button('🔔 Desktop Notification', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('RAD Studio', 'All 42 Themes and 70+ Controls Fully Operational!')
	})
	win.button('🎯 Center Window', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.row_end()

	win.status_bar('Vlang Webview RAD Studio Pro v2.0 | Delphi & VB Style Native IDE | All systems operational')

	win.run()
}
