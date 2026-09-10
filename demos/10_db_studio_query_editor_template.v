module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 10 - Database Studio Query Editor Template'
		width: 980
		height: 720
		theme: 'monokai_pro'
	)

	win.heading('🗃️ Database Studio & SQL Query Console Template')
	win.subheading('Interactive SQLite schema browser, SQL query buffer & result sets:')
	win.divider()

	win.box_start('Active Database Connection')
	win.row_start()
	win.input('Database URL', 'sqlite://production.db', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['sqlite://production.db', 'sqlite://analytics.db', 'sqlite://staging.db'], 'sqlite://production.db', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🔌 Reconnect', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Connected', 'Established SQLite connection.')
	})
	win.row_end()
	win.box_end()

	win.box_start('SQL Query Buffer')
	win.textarea('SQL Query', 'SELECT id, username, email, role, created_at FROM users WHERE active = 1 ORDER BY id DESC LIMIT 10;', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_start()
	win.button('▶ Run Query (Cmd+Enter)', fn (w &simplegui.SimpleWindow, _ string) {
		w.toast_success('Query executed in 0.8ms — 4 records returned')
		w.set_status('Query finished in 0.8ms (Rows: 4, Cache: Hit)')
	})
	win.button('🧹 Clear SQL', fn (w &simplegui.SimpleWindow, _ string) {
		w.eval('const t = document.querySelector("textarea"); if (t) { t.value = ""; }')
		w.toast_warning('SQL Query Buffer cleared')
		w.set_status('SQL buffer empty')
	})
	win.row_end()
	win.box_end()

	win.box_start('Query Results')
	headers := ['ID', 'Username', 'Email', 'Role', 'Created At']
	rows := [
		['1', 'alexm', 'alex@mercer.dev', 'Administrator', '2026-01-15'],
		['2', 'sarahc', 'sarah@connor.ai', 'Security Lead', '2026-02-01'],
		['3', 'elena', 'elena@rostova.org', 'Lead Architect', '2026-03-12'],
		['4', 'marcus', 'marcus@wright.io', 'DevOps Specialist', '2026-04-20'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, row string) {})
	win.box_end()

	win.status_bar('Query status: OK | 4 rows affected | Execution time: 0.8ms')

	win.run()
}
