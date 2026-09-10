module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 11 - Application Settings & Preferences'
		width: 900
		height: 700
		theme: 'macos_sonoma'
	)

	win.heading('⚙️ Application Settings & Preferences')
	win.subheading('System preferences, runtime environment and visual theme customizer:')
	win.divider()

	win.box_start('Appearance & Window Behavior')
	win.row_start()
	win.dropdown(['monokai_pro', 'tokyo_night', 'dracula', 'nord', 'macos_sonoma', 'windows_11_fluent', 'cyberpunk', 'gruvbox'], 'macos_sonoma', fn (w &simplegui.SimpleWindow, val string) {
		println('Selected Theme: ${val}')
	})
	win.toggle('Always on Top', false, fn (w &simplegui.SimpleWindow, val string) {
		w.set_always_on_top(val == 'true')
	})
	win.toggle('Hardware WebGL Acceleration', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Network & Telemetry')
	win.row_start()
	win.input('Proxy Host', '127.0.0.1:8080', fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Enable Auto-Update Checks', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Send Anonymous Crash Telemetry', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Performance & Memory')
	win.subheading('Worker Thread Pool Size (Cores):')
	win.slider(1, 32, 14, fn (w &simplegui.SimpleWindow, val string) {
		println('Thread count: ${val}')
	})
	win.box_end()

	win.row_start()
	win.button('💾 Save Preferences', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('Settings Saved', 'Application preferences written to configuration store.')
	})
	win.button('↺ Reset to Defaults', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Defaults Restored', 'All settings restored to default values.')
	})
	win.row_end()

	win.status_bar('Preferences synchronized with ~/.config/radstudio/settings.json')

	win.run()
}
