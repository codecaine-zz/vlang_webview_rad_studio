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
	win.add_table('tasks_table', headers, rows).on_click('tasks_table', fn (w &simplegui.SimpleWindow, row string) {
		w.set_value('selected_task', row)
		w.select_table_row('tasks_table', row.int())
		w.set_status('Selected task row ${row.int() + 1}.')
	})
	win.box_end()

	win.box_start('Add New Task')
	win.row_start()
	win.add_input('task_description', '')
	win.placeholder('Task Description')
	win.add_dropdown('task_priority', ['High', 'Critical', 'Medium', 'Low'], 'High')
	win.add_button('add_task', '➕ Add Task').on_click('add_task', fn (w &simplegui.SimpleWindow, _ string) {
		description := w.get_value('task_description').trim_space()
		if description.len == 0 {
			w.alert('Task Required', 'Enter a task description before adding it.')
			return
		}
		task_id := 101 + w.table_row_count('tasks_table')
		priority := w.get_value('task_priority')
		w.add_table_row('tasks_table', ['#${task_id}', description, 'Current User', priority, 'Pending'])
		w.set_value('task_description', '')
		w.set_status('Added task #${task_id}: ${description}')
		w.alert('Task Added', 'Task #${task_id} was added to the table.')
	})
	win.add_button('delete_task', '🗑️ Delete Selected').on_click('delete_task', fn (w &simplegui.SimpleWindow, _ string) {
		selected_row := w.get_value('selected_task')
		if selected_row == '' {
			w.alert('Select a Task', 'Click a table row before deleting it.')
			return
		}
		w.remove_table_row('tasks_table', selected_row.int())
		w.set_value('selected_task', '')
		w.select_table_row('tasks_table', -1)
		w.set_status('Deleted the selected task.')
		w.alert('Task Deleted', 'The selected task was removed from the table.')
	})
	win.row_end()
	win.box_end()

	win.status_bar('SQLite Database: tasks.db | Sync status: Synced')

	win.run()
}
