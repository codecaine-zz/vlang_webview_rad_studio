module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 3 - Data Grid, Timer & Code View'
		width: 960
		height: 700
		theme: 'dracula'
	)

	win.heading('🗄️ Enterprise Data Grid & Live Controls')
	win.subheading('Data-aware controls, system audio alerts & live records:')
	win.divider()

	win.box_start('Database Navigation & Operations')
	win.row_start()
	win.button('⏮ First', fn (w &simplegui.SimpleWindow, _ string) { println('First record') })
	win.button('◀ Prior', fn (w &simplegui.SimpleWindow, _ string) { println('Prior record') })
	win.button('▶ Next', fn (w &simplegui.SimpleWindow, _ string) { println('Next record') })
	win.button('⏭ Last', fn (w &simplegui.SimpleWindow, _ string) { println('Last record') })
	win.button('➕ Insert', fn (w &simplegui.SimpleWindow, _ string) { println('Insert record') })
	win.button('🗑️ Delete', fn (w &simplegui.SimpleWindow, _ string) { println('Delete record') })
	win.button('🔔 Play Chime', fn (w &simplegui.SimpleWindow, _ string) {
		system.play_system_sound('Hero')
	})
	win.row_end()
	win.box_end()

	win.box_start('Customer Records Data View')
	headers := ['ID', 'Customer Name', 'Email', 'Plan', 'Balance']
	rows := [
		['101', 'Acme Corporation', 'billing@acme.corp', 'Enterprise', '$14,250.00'],
		['102', 'Stark Industries', 'tony@stark.com', 'Enterprise', '$89,500.00'],
		['103', 'Wayne Enterprises', 'bruce@wayne.tech', 'Enterprise', '$62,100.00'],
		['104', 'Cyberdyne Systems', 'miles@cyberdyne.ai', 'Pro', '$4,800.00'],
		['105', 'Umbrella Biotech', 'albert@umbrella.lab', 'Pro', '$12,400.00'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, row string) {
		w.alert('Record Selected', 'You selected customer row index: ${row}')
	})
	win.box_end()

	win.box_start('SQL Query Console')
	win.textarea('SQL Query', 'SELECT id, name, email, balance FROM customers WHERE balance > 5000 ORDER BY balance DESC;', fn (w &simplegui.SimpleWindow, val string) {})
	win.row_start()
	win.button('⚡ Execute SQL', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Query Executed', '5 rows returned in 1.4ms.')
	})
	win.row_end()
	win.box_end()

	win.status_bar('Connected to: sqlite://production_customers.db (Read/Write)')

	win.run()
}
