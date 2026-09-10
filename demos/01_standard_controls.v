module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 1 - Standard RAD Controls & Helpers'
		width: 900
		height: 700
		theme: 'monokai_pro'
	)

	win.heading('👤 User Registration & Account Setup')
	win.subheading('Fill out the developer registration form with standard controls:')
	win.divider()

	win.box_start('Account Details')
	win.row_start()
	win.input('Full Name', 'Alex Mercer', fn (w &simplegui.SimpleWindow, val string) {
		println('Name changed: ${val}')
	})
	win.input('Email Address', 'alex@example.com', fn (w &simplegui.SimpleWindow, val string) {
		println('Email changed: ${val}')
	})
	win.row_end()

	win.row_start()
	win.password('Password', 'secret123', fn (w &simplegui.SimpleWindow, val string) {})
	win.dropdown(['Developer (Free)', 'Pro ($19/mo)', 'Enterprise ($99/mo)'], 'Pro ($19/mo)', fn (w &simplegui.SimpleWindow, val string) {})
	win.row_end()

	win.textarea('Developer Bio', 'Passionate V and Webview systems architect.', fn (w &simplegui.SimpleWindow, val string) {})
	win.box_end()

	win.box_start('Preferences & Options')
	win.row_start()
	win.checkbox('Agree to Terms of Service', true, fn (w &simplegui.SimpleWindow, val string) {})
	win.toggle('Enable Email Alerts', true, fn (w &simplegui.SimpleWindow, val string) {})
	win.row_end()

	win.subheading('Experience Level (Years):')
	win.slider(1, 20, 5, fn (w &simplegui.SimpleWindow, val string) {
		println('Slider: ${val}')
	})
	win.box_end()

	win.row_start()
	win.button('🚀 Submit Profile', fn (w &simplegui.SimpleWindow, _ string) {
		println('Form submitted!')
	})
	win.button('↺ Clear Form', fn (w &simplegui.SimpleWindow, _ string) {
		println('Form cleared!')
	})
	win.row_end()

	win.run()
}
