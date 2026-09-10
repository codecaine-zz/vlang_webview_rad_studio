module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 17 - SimpleGUI Layout Types Showcase'
		width: 960
		height: 720
		theme: 'gruvbox'
	)

	win.heading('📐 SimpleGUI Modern Layout Architecture')
	win.subheading('Flexible container paradigms: Rows, Cards, KPI Grids and Flexbox:')
	win.divider()

	win.subheading('1. KPI Summary Card Row:')
	win.row_start()
	win.kpi_card('Metric Alpha', '1,024', '+4.2%')
	win.kpi_card('Metric Beta', '2,048', '+8.1%')
	win.kpi_card('Metric Gamma', '4,096', '+16.5%')
	win.row_end()

	win.box_start('2. Form Inputs in Flexbox Row Container')
	win.row_start()
	win.input('First Name', 'Sarah', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input('Last Name', 'Connor', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Engineering', 'Operations', 'Security'], 'Security', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('3. Stacked Controls Container')
	win.label('Continuous volume level:')
	win.slider(0, 100, 75, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Mute Audio Output', false, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Layout System: Flexbox & CSS Grid responsive tokens')

	win.run()
}
