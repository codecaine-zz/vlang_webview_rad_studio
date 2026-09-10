module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Test Window', 800, 600)
	win.add_input('username', 'ada')
		.width(260)
		.placeholder('Enter username...')
		.tooltip('Username')
		.bold(true)
	win.add_button('btn_save', 'Save Document')
		.on_click('btn_save', fn (win &simplegui.SimpleWindow, _ string) {
			println('Click: ${win.get_text('username')}')
		})
	win.add_checkbox('chk_agree', 'Agree', true)
	win.add_slider('volume', 0, 100, 50)
	win.add_dropdown('role', ['Admin', 'User', 'Guest'], 'Admin')
	win.add_date_picker('date_field', '2026-09-10')
	win.add_color_picker('color_field', '#ff007f')
	win.add_search_field('search_field', 'Search...')
	win.add_section_header('sec1', 'Section Title', 'Subtitle')
	win.add_hotkey_badge('hk1', 'Cmd+S', 'Save file')
	win.add_kpi_card('kpi1', 'Total Sales', '$124,500', '+18.4%')
	win.add_progress_indicator('prog1', 75)
	win.add_divider('div1')
	win.add_badge('badge1', 'ACTIVE', '#00ff88')
	win.add_status_bar('status', 'Ready')

	assert win.has_control('username')
	assert win.has_control('btn_save')
	assert win.get_control_kind('username') == 'input'
	assert win.get_text('username') == 'ada'
	win.set_text('username', 'grace_hopper')
	assert win.get_text('username') == 'grace_hopper'
	assert win.get_int('volume') == 50
	assert win.get_bool('chk_agree') == true
	assert win.get_title() == 'Test Window'
	assert win.get_width() == 800
	assert win.get_height() == 600

	html := win.get_html()
	assert html.contains('grace_hopper')
	assert html.contains('btn_save')
	assert html.contains('Save Document')
	println('ALL API TESTS PASSED!')
}
