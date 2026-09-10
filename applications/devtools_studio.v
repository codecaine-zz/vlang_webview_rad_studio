module main

import simplegui
import system
import time

fn main() {
	mut win := simplegui.new_window(
		title: 'DevTools Studio Pro -- Developer Utilities Suite'
		width: 1120
		height: 850
		theme: 'codefreelance'
	)

	win.heading('🛠️ DevTools Studio Pro')
	win.label('Comprehensive Omnitool Developer Suite: Encoders, Formatters, Timestamps, Word Counter & Text Transformations')

	now := time.now()
	win.kpi_card('Current Unix Timestamp', '${now.unix()}', 'UTC / RFC3339: ${now.format_rfc3339()}')

	win.subheading('Text Transformation Input')
	win.input('Enter text for developer utilities...', 'Antigravity Vlang Webview RAD Studio 2026', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Quick String & Data Transformations')

	headers := ['Utility Transform', 'Output Result', 'Action']
	sample := 'Antigravity Vlang Webview RAD Studio 2026'
	rows := [
		['Slugify', system.slugify(sample), 'URL Friendly'],
		['Reverse String', system.reverse_string(sample), 'Inverted'],
		['Title Case', system.title_case(sample), 'Formatted'],
		['Word Count', system.word_count(sample).str(), 'Words'],
		['Is Palindrome', if system.is_palindrome(sample) { 'Yes' } else { 'No' }, 'Boolean'],
		['SHA-256 Checksum', system.hash_sha256(sample)[..16] + '...', 'Hex Digest'],
		['Base64 Representation', system.encode_base64(sample), 'Encoded']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Selected Transform', 'Selected row #${idx}')
	})

	win.divider()
	win.subheading('Developer Actions')

	win.button('🔄 Transform Text in Input', fn (w &simplegui.SimpleWindow, _ string) {
		txt := w.get_value('inp_1')
		slug := system.slugify(txt)
		w.alert('Slugified Output', 'Slug: ${slug}\nWords: ${system.word_count(txt)}')
	})

	win.button('⏱️ Generate New Unix Timestamp', fn (w &simplegui.SimpleWindow, _ string) {
		t := time.now()
		w.alert('Timestamp', 'Unix: ${t.unix()}\nDate: ${t.format_rfc3339()}')
	})

	win.status_bar('DevTools Studio Pro  •  High-Efficiency V Utilities  •  Active')
	win.run()
}
