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
		w.set_status('Full Name updated to: "${val}"')
	})
	win.input('Email Address', 'alex@example.com', fn (w &simplegui.SimpleWindow, val string) {
		println('Email changed: ${val}')
		w.set_status('Email Address updated to: "${val}"')
	})
	win.row_end()

	win.row_start()
	win.password('Password', 'secret123', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Password modified (${val.len} characters)')
	})
	win.dropdown(['Developer (Free)', 'Pro ($19/mo)', 'Enterprise ($99/mo)'], 'Pro ($19/mo)', fn (w &simplegui.SimpleWindow, val string) {
		w.toast_info('Account tier changed to: ${val}')
		w.set_status('Selected subscription: ${val}')
	})
	win.row_end()

	win.textarea('Developer Bio', 'Passionate V and Webview systems architect.', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Bio modified (${val.len} chars)')
	})
	win.box_end()

	win.box_start('Preferences & Options')
	win.row_start()
	win.checkbox('Agree to Terms of Service', true, fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Terms agreement: ${val}')
	})
	win.toggle('Enable Email Alerts', true, fn (w &simplegui.SimpleWindow, val string) {
		if val == 'true' {
			w.toast_success('Email notifications enabled')
			w.set_status('Email alerts: ON')
		} else {
			w.toast_warning('Email notifications disabled')
			w.set_status('Email alerts: OFF')
		}
	})
	win.row_end()

	win.subheading('Experience Level (Years):')
	win.slider(1, 20, 5, fn (w &simplegui.SimpleWindow, val string) {
		println('Slider: ${val}')
		w.set_status('Experience level set to: ${val} years')
	})
	win.box_end()

	win.row_start()
	win.button('🚀 Submit Profile', fn (w &simplegui.SimpleWindow, _ string) {
		println('Form submitted!')
		w.simulate_form_submit('🎉 Profile Submitted Successfully!')
	})
	win.button('↺ Clear Form', fn (w &simplegui.SimpleWindow, _ string) {
		println('Form cleared!')
		w.clear_form()
		w.toast_warning('↺ Form inputs cleared and reset to blank state.')
		w.set_status('↺ All form fields have been cleared.')
	})
	win.row_end()

	win.status_bar('Ready — type in inputs or click Submit / Clear Form to see live simulated actions.')

	win.run()
}
