module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 18 - SimpleGUI Developer Ergonomics'
		width: 880
		height: 640
		theme: 'monokai_pro'
	)

	win.heading('🛠️ Developer Ergonomics & Fluent Chaining')
	win.subheading('Concise declarative API for rapid UI development without boilerplate:')
	win.divider()

	win.box_start('Live Counter State')
	win.row_start()
	win.kpi_card('Counter Value', '0', 'Click buttons to mutate')
	win.row_end()
	win.box_end()

	win.row_start()
	win.button('➕ Increment (+1)', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Increment', 'Counter incremented!')
	})
	win.button('➖ Decrement (-1)', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Decrement', 'Counter decremented!')
	})
	win.button('↺ Reset', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Reset', 'Counter reset back to zero.')
	})
	win.row_end()

	win.box_start('Interactive Settings')
	win.input('Project Name', 'MyAwesomeProject', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Debug', 'Release', 'Test'], 'Release', fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Enable Fast Compilation', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Ergonomics rating: Pure Vlang, zero JS boilerplate')

	win.run()
}
