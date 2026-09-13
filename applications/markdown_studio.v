module main

import simplegui
import system
import os

fn main() {
	mut win := simplegui.new_window(
		title: 'Markdown Studio Pro -- Markdown Editor & HTML Previewer'
		width: 1150
		height: 850
		theme: 'rose_pine'
	)

	win.heading('📝 Markdown Studio Pro')
	win.label('Live Markdown Editor, Document Formatter, HTML Exporter & Structured Article Workbench')

	sample_md := '# Welcome to Markdown Studio Pro\n\nA modern markdown authoring workstation built with **Vlang Webview RAD Studio**.\n\n## Key Capabilities\n\n- Real-time editing\n- Fast native performance\n- Export to HTML\n- Cross-platform desktop integration\n\n```v\nimport simplegui\n\nfn main() {\n    println("Hello from V!")\n}\n```\n'

	win.subheading('Markdown Source Code')
	win.textarea('Write markdown content...', sample_md, fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Rendered HTML Document')
	win.textarea('Rendered output...', 'Click "Render Markdown to HTML" below to generate live document representation...', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Document Actions')

	win.button('🎨 Render Markdown to HTML', fn (w &simplegui.SimpleWindow, _ string) {
		md := w.get_value('txt_1')
		// Basic HTML conversion
		mut html_render := '<div style="font-family:sans-serif; line-height:1.6;">\n'
		for line in md.split_into_lines() {
			if line.starts_with('# ') {
				html_render += '<h1>' + line[2..] + '</h1>\n'
			} else if line.starts_with('## ') {
				html_render += '<h2>' + line[3..] + '</h2>\n'
			} else if line.starts_with('- ') {
				html_render += '<li>' + line[2..] + '</li>\n'
			} else if line.trim_space() != '' {
				html_render += '<p>' + line + '</p>\n'
			}
		}
		html_render += '</div>'
		w.set_value('txt_2', html_render)
		w.notification('Rendered', 'Converted markdown to HTML')
	})

	win.button('📋 Copy HTML to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		html := w.get_value('txt_2')
		system.set_clipboard_text(html)
		w.alert('Clipboard', 'HTML copied to clipboard!')
	})

	win.button('📂 Open Markdown File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select Markdown File', 'md,markdown,txt')
		if path != '' {
			content := os.read_file(path) or {
				w.alert('Open Failed', 'Could not read "${path}":\n${err}')
				return
			}
			w.set_value('txt_1', content)
			w.notification('Loaded', 'Opened: ' + path)
		}
	})

	win.button('💾 Save Markdown File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.save_file_dialog('Save Markdown File', 'document.md')
		if path != '' {
			md := w.get_value('txt_1')
			os.write_file(path, md) or {
				w.alert('Save Failed', 'Could not write "${path}":\n${err}')
				return
			}
			w.alert('File Saved', 'Saved markdown document to: ' + path)
		}
	})

	win.status_bar('Markdown Studio Pro  •  High-Performance Document Authoring  •  Ready')
	win.run()
}
