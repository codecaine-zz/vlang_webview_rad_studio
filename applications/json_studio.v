module main

import simplegui
import system
import json2
import os

fn main() {
	mut win := simplegui.new_window(
		title: 'JSON Query Studio Pro -- High Performance JSON Workbench'
		width: 1100
		height: 820
		theme: 'tokyo_night'
	)

	win.heading('⚡ JSON Query Studio Pro')
	win.label('High-Performance JSON Formatter, Validator, Minifier & Query Workstation')

	default_json := '{\n  "project": "Vlang Webview RAD Studio",\n  "version": "1.0.0",\n  "author": "codecaine",\n  "features": ["Delphi Docking", "70+ Controls", "42 Themes", "Native Windowing"]\n}'

	win.subheading('JSON Input / Workspace')
	win.textarea('Paste or enter valid JSON here...', default_json, fn (w &simplegui.SimpleWindow, _ string) {
		println('JSON text modified')
	})

	win.divider()
	win.subheading('Format & Query Actions')

	win.button('✨ Format & Prettify JSON', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get_value('txt_1')
		parsed := json2.decode[json2.Any](raw) or {
			w.alert('JSON Syntax Error', 'Invalid JSON syntax:\n${err}')
			return
		}
		pretty := json2.encode[json2.Any](parsed, prettify: true)
		w.set_value('txt_1', pretty)
		w.notification('JSON Formatted', 'Formatted JSON successfully')
	})

	win.button('📦 Minify / Compact JSON', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get_value('txt_1')
		parsed := json2.decode[json2.Any](raw) or {
			w.alert('JSON Syntax Error', 'Invalid JSON syntax:\n${err}')
			return
		}
		compact := json2.encode[json2.Any](parsed)
		w.set_value('txt_1', compact)
		w.notification('JSON Minified', 'Minified JSON (${compact.len} bytes)')
	})

	win.button('📋 Copy to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get_value('txt_1')
		system.set_clipboard_text(raw)
		w.alert('Clipboard', 'JSON content copied to clipboard!')
	})

	win.button('📂 Load JSON from File', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select JSON File', 'json,txt')
		if path != '' {
			content := os.read_file(path) or {
				w.alert('Open Failed', 'Could not read "${path}":\n${err}')
				return
			}
			w.set_value('txt_1', content)
			w.notification('Loaded', 'Loaded file: ${path}')
		}
	})

	win.status_bar('JSON Studio Pro  •  Zero-latency V Native Engine  •  Ready')
	win.run()
}
