module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 13 - Productivity Controls Studio'
		width: 960
		height: 720
		theme: 'rose_pine'
	)

	win.heading('⚡ Developer Productivity Workstation')
	win.subheading('Pomodoro focus intervals, quick scratchpad & clipboard utilities:')
	win.divider()

	win.row_start()
	win.kpi_card('Focus Session', '25:00', 'Pomodoro #3')
	win.kpi_card('Completed Sprints', '4 Sprints', 'Goal: 6 sprints')
	win.kpi_card('Clipboard Length', '248 chars', 'Ready to paste')
	win.row_end()

	win.box_start('Quick Developer Scratchpad')
	win.textarea('Scratchpad Notes', '// Quick thoughts & code snippets...\nfn compute_hash() string {\n    return "sha256:4a8b9f..."\n}', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_start()
	win.button('📋 Copy to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		val := w.get_value('txt_1')
		system.set_clipboard_text(val)
		w.notification('Clipboard', 'Content copied to system clipboard!')
	})
	win.button('🧹 Clear Scratchpad', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Today Focus Objectives')
	headers := ['Priority', 'Objective', 'Estimated Time', 'Status']
	rows := [
		['P0', 'Finish Vlang Webview RAD Studio Migration', '2h 30m', 'In Progress'],
		['P1', 'Verify Cross-Platform Window Placement API', '45m', 'Completed'],
		['P2', 'Build Standalone macOS .app Bundle and ICNS', '1h', 'Queued'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Productivity Mode: Deep Focus (Do Not Disturb Active)')

	win.run()
}
