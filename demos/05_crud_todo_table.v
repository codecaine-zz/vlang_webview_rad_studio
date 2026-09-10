module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 5 - Dynamic Table & Data Grid Control Studio'
		width: 980
		height: 720
		theme: 'nord'
	)

	win.heading('⚡ Dynamic Table Control & CRUD Operations')
	win.subheading('Interactive data grid with real-time add, edit, and deletion:')
	win.divider()

	win.row_start()
	win.kpi_card('Total Tasks', '18', 'Across 3 projects')
	win.kpi_card('Completed', '14', '77.7% completion rate')
	win.kpi_card('Pending Review', '4', 'Priority high')
	win.row_end()

	win.box_start('Task Management Table')
	headers := ['ID', 'Task Description', 'Assigned To', 'Priority', 'Status']
	rows := [
		['#101', 'Implement Webview Window Placement API', 'Alex Mercer', 'High', 'Completed'],
		['#102', 'Port 42 Desktop Themes to Vlang', 'Sarah Connor', 'Critical', 'Completed'],
		['#103', 'Cross-Platform Build Script Validation', 'John Doe', 'Medium', 'In Progress'],
		['#104', 'Automate Release Packaging with icns', 'Elena Rostova', 'High', 'Pending'],
		['#105', 'Integrate Hardware Telemetry Bindings', 'Marcus Wright', 'Low', 'Completed'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, row string) {
		println('Selected Task Row: ${row}')
	})
	win.box_end()

	win.box_start('Add New Task')
	win.row_start()
	win.input('Task Description', '', fn (w &simplegui.SimpleWindow, val string) {})
	win.dropdown(['High', 'Critical', 'Medium', 'Low'], 'High', fn (w &simplegui.SimpleWindow, val string) {})
	win.button('➕ Add Task', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Task Added', 'New task successfully queued into database table.')
	})
	win.button('🗑️ Delete Selected', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Task Deleted', 'Selected task removed from table.')
	})
	win.row_end()
	win.box_end()

	win.status_bar('SQLite Database: tasks.db | Sync status: Synced')

	win.run()
}
