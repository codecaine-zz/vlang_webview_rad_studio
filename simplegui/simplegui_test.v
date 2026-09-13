module simplegui

fn noop_handler(_ &SimpleWindow, _ string) {}

fn test_interactive_builders_register_handlers() {
	mut win := new_window()
	win.button('Button', noop_handler)
	win.input('Input', '', noop_handler)
	win.textarea('Textarea', '', noop_handler)
	win.checkbox('Checkbox', false, noop_handler)
	win.radio('group', 'Radio', false, noop_handler)
	win.toggle('Toggle', false, noop_handler)
	win.slider(0, 10, 5, noop_handler)
	win.dropdown(['One'], 'One', noop_handler)
	win.table(['Column'], [['Value']], noop_handler)

	for control in win.controls {
		handler_id := match control.typ {
			.button, .table { control.click_id }
			.input, .textarea, .checkbox, .radio, .toggle, .slider, .dropdown {
				control.change_id
			}
			else {
				continue
			}
		}
		assert handler_id in win.event_handlers, 'missing handler for ${control.id}'
	}
}

fn test_generated_layout_has_small_screen_fallbacks() {
	mut win := new_window()
	win.button('Button', noop_handler)
	html := win.generate_html()

	assert html.contains('@media (max-width: 600px)')
	assert html.contains('.sg-table { min-width: 640px; table-layout: auto; }')
	assert html.contains('padding-bottom: calc(')
}

fn test_action_guard_rejects_overlap_and_can_be_reused() {
	mut win := new_window()
	assert win.try_begin_action()
	assert !win.try_begin_action()
	win.end_action()
	assert win.try_begin_action()
	win.end_action()
}

fn test_set_control_enabled_updates_control_state_without_webview() {
	mut win := new_window()
	win.add_button('submit', 'Submit')

	win.set_control_enabled('submit', false)
	assert !win.controls[0].enabled

	win.set_control_enabled('submit', true)
	assert win.controls[0].enabled
}

fn test_table_row_and_header_state_updates_without_webview() {
	mut win := new_window()
	win.add_table('results', ['Old'], [['one']])

	win.set_table_headers('results', ['First', 'Second'])
	win.set_table_rows('results', [['one', 'two']])
	win.add_table_row('results', ['three', 'four'])
	assert win.table_row_count('results') == 2
	assert win.controls[0].headers == ['First', 'Second']

	win.remove_table_row('results', 0)
	assert win.table_row_count('results') == 1
	assert win.controls[0].rows[0] == ['three', 'four']
}

fn test_table_rows_json_escapes_javascript_sensitive_content() {
	encoded := table_rows_json([['quote"', 'line\nbreak', '</script>']])
	assert encoded == '[["quote\\"","line\\nbreak","</script>"]]'
}
