module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 19 - State Persistence & Reactive Bindings'
		width: 900
		height: 660
		theme: 'nord'
	)

	win.heading('💾 State Persistence & Two-Way Bindings')
	win.subheading('Live synchronized form fields and state restoration across renders:')
	win.divider()

	win.box_start('Persisted User Profile')
	win.row_start()
	win.input('Username', 'alex_mercer', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input('Company', 'Antigravity Systems', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.dropdown(['Engineer', 'Manager', 'Architect', 'Director'], 'Architect', fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Remember Session on Exit', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Dynamic Live Value Preview')
	win.row_start()
	win.kpi_card('Stored State Key', 'user_profile_v1', 'Local Storage')
	win.kpi_card('Sync Status', 'Synchronized', 'Auto-saved')
	win.row_end()
	win.box_end()

	win.row_start()
	win.button('💾 Force Save State', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('State Saved', 'Session state persisted to local storage.')
	})
	win.button('🔄 Reload State', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('State Reloaded', 'Values refreshed from storage cache.')
	})
	win.row_end()

	win.status_bar('Storage Driver: LocalStorage / JSON backend')

	win.run()
}
