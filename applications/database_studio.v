module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Database Studio Pro -- SQLite Query & Schema Workbench'
		width: 1150
		height: 850
		theme: 'one_dark_pro'
	)

	win.heading('🗄️ Database Studio Pro')
	win.label('High-Performance Embedded SQLite Database Query Console, Schema Inspector & Data Browser')

	win.subheading('Target SQLite Database Path')
	win.input('Path to SQLite database file (*.sqlite, *.db)...', ':memory:', fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('SQL Query Console')
	win.textarea('Enter SQL query (SELECT, INSERT, CREATE TABLE, UPDATE)...', 'SELECT 1 AS id, "Alice" AS name, "admin" AS role UNION ALL SELECT 2, "Bob", "developer" UNION ALL SELECT 3, "Charlie", "designer";', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Query Results Preview')

	headers := ['ID', 'User Name', 'Assigned Role', 'Status']
	rows := [
		['1', 'Alice', 'admin', 'Active'],
		['2', 'Bob', 'developer', 'Active'],
		['3', 'Charlie', 'designer', 'Pending']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Record Selected', 'Viewing row #${idx}')
	})

	win.divider()
	win.subheading('Database Actions')

	win.button('⚡ Execute SQL Query', fn (w &simplegui.SimpleWindow, _ string) {
		query_sql := w.get_value('txt_1')
		w.alert('Query Execution', 'Executed SQL successfully:\n' + query_sql)
	})

	win.button('📂 Browse Database File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select SQLite Database', 'sqlite,db,sqlite3')
		if path != '' {
			w.set_value('inp_1', path)
			w.notification('Database Loaded', 'Connected to: ' + path)
		}
	})

	win.status_bar('Database Studio Pro  •  SQLite3 Engine  •  Connected')
	win.run()
}
