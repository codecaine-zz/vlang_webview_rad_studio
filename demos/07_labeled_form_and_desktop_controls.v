module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 7 - Labeled Form & Desktop Controls'
		width: 920
		height: 700
		theme: 'one_dark'
	)

	win.heading('📋 Labeled Form & Desktop Controls Showcase')
	win.subheading('Delphi-style field groups, labeled inputs and desktop switches:')
	win.divider()

	win.box_start('Server Network Configuration')
	win.row_start()
	win.input('Hostname', 'prod-api-cluster.internal', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input('Port', '8080', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['IPv4', 'IPv6', 'Dual Stack'], 'IPv4', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Security & Authentication Policy')
	win.row_start()
	win.toggle('Enforce TLS 1.3 Strict Mode', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Enable Mutex Pinning', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Audit Log Streaming', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.subheading('Session Inactivity Timeout (Minutes):')
	win.slider(5, 120, 30, fn (w &simplegui.SimpleWindow, val string) {
		println('Timeout: ${val}')
	})
	win.box_end()

	win.row_start()
	win.button('💾 Save Configuration', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Saved', 'Configuration parameters written to disk.')
	})
	win.button('↺ Revert Defaults', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Reverted', 'Reset all fields back to factory presets.')
	})
	win.row_end()

	win.status_bar('Configuration State: Unsaved changes | TLS: Enabled')

	win.run()
}
