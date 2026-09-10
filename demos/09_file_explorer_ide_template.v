module main

import simplegui
import os

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 9 - File Explorer & Workspace IDE Template'
		width: 1000
		height: 720
		theme: 'gruvbox'
	)

	win.heading('📂 File Explorer & Lightweight Workspace IDE')
	win.subheading('Desktop file dialogs, directory browser & monospaced code viewer:')
	win.divider()

	win.box_start('Workspace Toolbar')
	win.row_start()
	win.button('📂 Open File', fn (w &simplegui.SimpleWindow, _ string) {
		selected := w.open_file_dialog('Select file to edit', 'v;txt;json;md')
		if selected != '' {
			content := os.read_file(selected) or { 'Error reading file' }
			w.alert('File Loaded', 'Loaded ${selected} (${content.len} bytes)')
		}
	})
	win.button('📁 Open Directory', fn (w &simplegui.SimpleWindow, _ string) {
		selected := w.select_folder_dialog('Select workspace folder')
		if selected != '' {
			w.alert('Workspace Selected', selected)
		}
	})
	win.button('💾 Save File', fn (w &simplegui.SimpleWindow, _ string) {
		save_path := w.save_file_dialog('Save file as', 'untitled.v')
		if save_path != '' {
			w.alert('File Saved', 'Saved to ${save_path}')
		}
	})
	win.row_end()
	win.box_end()

	win.box_start('Editor Code Buffer')
	sample_code := 'module main\n\nimport webview\n\nfn main() {\n\tmut w := webview.create(debug: true)\n\tw.set_title(\'Hello from Vlang Webview!\')\n\tw.set_size(800, 600, .@none)\n\tw.set_html(\'<h1>Fast, Simple, Native</h1>\')\n\tw.run()\n}'
	win.textarea('Source Code Buffer', sample_code, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Workspace: /Users/codecaine/vlang_webview_rad_studio | UTF-8 | LF | Vlang')

	win.run()
}
