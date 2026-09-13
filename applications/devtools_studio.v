module main

import simplegui
import system
import time

fn to_camel_case(s string) string {
	words := s.split_any(' _-').filter(it != '')
	if words.len == 0 {
		return ''
	}
	mut res := words[0].to_lower()
	for i in 1 .. words.len {
		w := words[i].to_lower()
		res += if w.len > 0 { w[0..1].to_upper() + w[1..] } else { '' }
	}
	return res
}

fn to_snake_case(s string) string {
	words := s.split_any(' _-').filter(it != '')
	return words.map(it.to_lower()).join('_')
}

fn to_kebab_case(s string) string {
	words := s.split_any(' _-').filter(it != '')
	return words.map(it.to_lower()).join('-')
}

fn decode_jwt_preview(token string) string {
	parts := token.trim_space().split('.')
	if parts.len < 2 {
		return 'Not a valid JWT (requires at least Header.Payload)'
	}
	header := system.decode_base64(parts[0])
	payload := system.decode_base64(parts[1])
	return 'Header:\n${header}\n\nPayload:\n${payload}'
}

fn update_devtools_table(w &simplegui.SimpleWindow, input_text string) {
	now := time.now()
	w.set_kpi('kpi_unix', '${now.unix()}', 'Epoch Seconds')
	w.set_kpi('kpi_rfc', now.format_rfc3339(), 'UTC / ISO')
	w.set_kpi('kpi_words', '${system.word_count(input_text)} Words', 'Word Count')
	w.set_kpi('kpi_bytes', '${input_text.len} Bytes', '${input_text.len * 8} bits')

	sample := if input_text.trim_space() != '' { input_text } else { 'Antigravity Vlang Webview RAD Studio 2026' }

	rows := [
		['Slugify (URL Friendly)', system.slugify(sample), 'Lowercase slug'],
		['camelCase', to_camel_case(sample), 'Identifier'],
		['snake_case', to_snake_case(sample), 'Variable'],
		['kebab-case', to_kebab_case(sample), 'CSS / URL'],
		['Title Case', system.title_case(sample), 'Capitalized words'],
		['UPPERCASE', sample.to_upper(), 'Uppercase'],
		['lowercase', sample.to_lower(), 'Lowercase'],
		['Reverse String', system.reverse_string(sample), 'Inverted characters'],
		['Is Palindrome', if system.is_palindrome(sample) { 'Yes (True)' } else { 'No (False)' }, 'Symmetry'],
		['SHA-256 Digest', system.hash_sha256(sample), 'Digest Hex'],
		['Base64 Representation', system.encode_base64(sample), 'Base64'],
	]
	w.set_table_rows('transforms_table', rows)
	w.set_status('DevTools transforms updated • ${rows.len} utilities calculated')
}

fn main() {
	default_text := 'Antigravity Vlang Webview RAD Studio 2026'

	mut win := simplegui.new_window(
		title: 'DevTools Studio Pro Enterprise -- Developer Utilities Suite'
		width: 1180
		height: 890
		theme: 'codefreelance'
	)

	win.heading('🛠️ DevTools Studio Pro Enterprise')
	win.subheading('Comprehensive Omnitool Developer Suite: Encoders, Formatters, Timestamps, Casing & Data Codecs')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_unix', 'Current Unix Epoch', '0', 'Epoch Seconds')
	win.kpi_card_named('kpi_rfc', 'RFC3339 Timestamp', '...', 'ISO 8601')
	win.kpi_card_named('kpi_words', 'Word Count', '0 Words', 'Words')
	win.kpi_card_named('kpi_bytes', 'Input Size', '0 Bytes', 'Bytes')
	win.row_end()

	// Input Text Box
	win.box_start('✏️ Text Transformation Workspace')
	win.row_start()
	win.input_named('dev_input', 'Enter text or tokens to transform...', default_text, fn (w &simplegui.SimpleWindow, val string) {
		update_devtools_table(w, val)
	})
	win.button('🔄 Refresh Clock', fn (w &simplegui.SimpleWindow, _ string) {
		txt := w.get('dev_input')
		update_devtools_table(w, txt)
		w.toast_success('Timestamp updated!')
	})
	win.button('🧹 Clear Input', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('dev_input', '')
		update_devtools_table(w, '')
		w.toast_info('Input cleared')
	})
	win.row_end()
	win.box_end()

	// Transformations Table Box
	win.box_start('📊 Computed String Transformations & Codecs')
	headers := ['Utility Transform', 'Computed Output', 'Format Type']
	win.table_named('transforms_table', headers, [['Loading...', 'Calculating...', '-']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspected transform #${idx}')
	})
	win.box_end()

	// JWT & Timestamp Toolkit Box
	win.box_start('🔓 JWT Token Decoder & Timestamp Inspector')
	win.row_start()
	win.input_named('jwt_input', 'Paste JWT token (e.g. eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...)...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🔍 Decode JWT Payload', fn (w &simplegui.SimpleWindow, _ string) {
		token := w.get('jwt_input')
		decoded := decode_jwt_preview(token)
		w.set_value('jwt_output', decoded)
		w.toast_success('JWT token decoded!')
	})
	win.button('📋 Copy Decoded JWT', fn (w &simplegui.SimpleWindow, _ string) {
		out := w.get('jwt_output')
		if out == '' {
			w.toast_warning('Nothing to copy.')
			return
		}
		system.set_clipboard_text(out)
		w.toast_success('Decoded JWT payload copied to clipboard!')
	})
	win.row_end()

	win.raw_html('<style>
		#jwt_output {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 110px;
			min-height: 110px;
			background: #181c24;
			color: #61afef;
			border: 1px solid #282c34;
			border-radius: 6px;
			line-height: 1.45;
			padding: 8px;
		}
	</style>')
	win.textarea_named('jwt_output', 'Decoded JWT header and payload will display here...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('DevTools Studio Pro Enterprise  •  High-Efficiency V Utilities  •  Ready')

	// Initial population
	update_devtools_table(win, default_text)

	win.run()
}
