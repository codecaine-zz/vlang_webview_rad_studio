module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 14 - SimpleGUI Fluent User Form Demo'
		width: 840
		height: 660
		theme: 'monokai_pro'
	)

	win.heading('👤 User Account & Profile Setup')
	win.subheading('Fill out your developer profile details below:')
	win.divider()

	win.box_start('Personal Details')
	win.row_start()
	win.label('Full Name:')
	win.input('e.g. Alex Mercer', 'Alex Mercer', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.label('Email Address:')
	win.input('alex@example.com', 'alex@example.com', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.label('Account Plan:')
	win.dropdown(['Developer (Free)', 'Pro ($19/mo)', 'Enterprise ($99/mo)'], 'Pro ($19/mo)', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.box_start('Preferences')
	win.row_start()
	win.toggle('Enable Email Notifications', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Two-Factor Authentication', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.row_start()
	win.button('🚀 Submit Profile', fn (w &simplegui.SimpleWindow, _ string) {
		w.simulate_form_submit('🎉 Profile Submitted Successfully!')
	})
	win.button('↺ Clear Inputs', fn (w &simplegui.SimpleWindow, _ string) {
		w.clear_form()
		w.toast_warning('↺ Form inputs cleared and reset to blank state.')
		w.set_status('↺ All inputs cleared — form is now blank.')
	})
	win.row_end()

	win.status_bar('Status: Ready for user input')

	win.run()
}
