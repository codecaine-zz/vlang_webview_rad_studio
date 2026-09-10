module main

import simplegui
import regex

fn main() {
	mut win := simplegui.new_window(
		title: 'Regex Studio Pro -- Regular Expression Workbench'
		width: 1100
		height: 820
		theme: 'cyberpunk'
	)

	win.heading('🎯 Regex Studio Pro')
	win.label('High-Performance Regular Expression Tester, Pattern Validator, Match Group Inspector & Replacement Workbench')

	win.subheading('Regular Expression Pattern')
	win.input('Enter regular expression (e.g. [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})...', r'(\w+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})', fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('Test Input Text')
	win.textarea('Enter sample text to match against...', 'Contact our team at support@vlang.io or sales@radstudio.dev for enterprise inquiries.', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Match Analysis Preview')

	headers := ['Match #', 'Matched Value', 'Character Span']
	rows := [
		['Match 1', 'support@vlang.io', 'Index: 21 - 36'],
		['Match 2', 'sales@radstudio.dev', 'Index: 40 - 59']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Regex Match', 'Inspected match #${idx}')
	})

	win.divider()
	win.subheading('Regex Actions')

	win.button('⚡ Test Pattern Against Text', fn (w &simplegui.SimpleWindow, _ string) {
		pat := w.get_value('inp_1')
		txt := w.get_value('txt_1')
		mut re := regex.regex_opt(pat) or {
			w.alert('Regex Compile Error', 'Invalid pattern:\n${err}')
			return
		}
		res := re.matches_string(txt)
		w.alert('Pattern Match Result', if res { '✅ Pattern matched successfully in text!' } else { '❌ No match found in text.' })
	})

	win.button('📋 Copy Sample Email Regex', fn (w &simplegui.SimpleWindow, _ string) {
		sample := r'(\w+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})'
		w.set_value('inp_1', sample)
		w.notification('Pattern Loaded', 'Loaded email address pattern')
	})

	win.button('📋 Copy URL Regex', fn (w &simplegui.SimpleWindow, _ string) {
		sample := r'https?://[^\s/$.?#].[^\s]*'
		w.set_value('inp_1', sample)
		w.notification('Pattern Loaded', 'Loaded HTTP URL pattern')
	})

	win.status_bar('Regex Studio Pro  •  V regex Engine  •  Compiled')
	win.run()
}
