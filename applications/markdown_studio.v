module main

import simplegui
import system
import os

fn update_markdown_telemetry(w &simplegui.SimpleWindow, md string) {
	words := system.word_count(md)
	chars := md.len
	lines := md.split_into_lines().len
	read_mins := if words > 0 { (words / 200) + 1 } else { 0 }

	w.set_kpi('kpi_words', '${words} Words', 'Word count')
	w.set_kpi('kpi_chars', '${chars} Chars', '${system.format_bytes(u64(chars))}')
	w.set_kpi('kpi_lines', '${lines} Lines', 'Document lines')
	w.set_kpi('kpi_read_time', '~${read_mins} min read', 'Estimated')

	w.set_status('Document updated • ${words} words • ${chars} characters • ${lines} lines')
}

fn convert_markdown_to_html(md string) string {
	mut out := '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<style>\n' +
		'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; line-height: 1.6; color: #2e3440; max-width: 800px; margin: 20px auto; padding: 0 20px; }\n' +
		'h1, h2, h3 { border-bottom: 1px solid #e5e9f0; padding-bottom: 6px; color: #4c566a; }\n' +
		'code { background: #eceff4; padding: 2px 6px; border-radius: 4px; font-family: monospace; font-size: 0.9em; }\n' +
		'pre { background: #2e3440; color: #eceff4; padding: 12px; border-radius: 6px; overflow-x: auto; }\n' +
		'pre code { background: none; color: inherit; padding: 0; }\n' +
		'blockquote { border-left: 4px solid #88c0d0; margin: 0; padding-left: 16px; color: #4c566a; }\n' +
		'table { border-collapse: collapse; width: 100%; margin: 16px 0; }\n' +
		'th, td { border: 1px solid #d8dee9; padding: 8px 12px; text-align: left; }\n' +
		'th { background: #e5e9f0; }\n' +
		'</style>\n</head>\n<body>\n'

	mut in_code_block := false
	for line in md.split_into_lines() {
		if line.starts_with('```') {
			if in_code_block {
				out += '</code></pre>\n'
				in_code_block = false
			} else {
				out += '<pre><code>'
				in_code_block = true
			}
			continue
		}
		if in_code_block {
			out += line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;') + '\n'
			continue
		}

		if line.starts_with('# ') {
			out += '<h1>' + line[2..] + '</h1>\n'
		} else if line.starts_with('## ') {
			out += '<h2>' + line[3..] + '</h2>\n'
		} else if line.starts_with('### ') {
			out += '<h3>' + line[4..] + '</h3>\n'
		} else if line.starts_with('- ') {
			out += '<li>' + line[2..] + '</li>\n'
		} else if line.starts_with('> ') {
			out += '<blockquote>' + line[2..] + '</blockquote>\n'
		} else if line.trim_space() != '' {
			out += '<p>' + line + '</p>\n'
		}
	}
	if in_code_block {
		out += '</code></pre>\n'
	}
	out += '</body>\n</html>'
	return out
}

fn main() {
	sample_md := '# Welcome to Markdown Studio Pro Enterprise\n\nA modern markdown authoring workstation built with **Vlang Webview RAD Studio**.\n\n## Key Architectural Features\n\n- High-performance zero-latency native rendering\n- Live document statistics and word counting\n- Standalone responsive HTML export\n- Full cross-platform desktop integration\n\n```v\nimport simplegui\n\nfn main() {\n    println("Hello from Vlang Webview RAD Studio!")\n}\n```\n\n> "Simplicity is prerequisite for reliability." — Edsger W. Dijkstra\n'

	mut win := simplegui.new_window(
		title: 'Markdown Studio Pro Enterprise -- Document Authoring Workbench'
		width: 1180
		height: 890
		theme: 'rose_pine'
	)

	win.heading('📝 Markdown Studio Pro Enterprise')
	win.subheading('Live Markdown Editor, Document Formatter, HTML Exporter & Structured Article Workbench')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_words', 'Word Count', '0 Words', 'Words')
	win.kpi_card_named('kpi_chars', 'Character Count', '0 Chars', 'Size')
	win.kpi_card_named('kpi_lines', 'Total Lines', '0 Lines', 'Lines')
	win.kpi_card_named('kpi_read_time', 'Reading Time', '~0 min', 'Estimated')
	win.row_end()

	// Presets Row
	win.row_start()
	templates := [
		'Template: Software README.md',
		'Template: Technical API Documentation',
		'Template: Release Notes & Changelog',
		'Template: Engineering Blog Post',
	]
	win.dropdown_named('md_templates', templates, templates[0], fn (w &simplegui.SimpleWindow, val string) {
		text := match val {
			'Template: Software README.md' {
				'# Project Name\n\n> Short descriptive tagline for the project.\n\n## Features\n\n- Blazing fast native binary\n- Cross-platform support\n- Modular clean architecture\n\n## Installation\n\n```bash\nv install myapp\n```\n'
			}
			'Template: Technical API Documentation' {
				'# API Specification v1\n\n## Endpoints\n\n### `GET /api/v1/status`\n\nReturns current operational health of the system.\n\n**Response:**\n```json\n{\n  "status": "healthy",\n  "uptime": 3600\n}\n```\n'
			}
			'Template: Release Notes & Changelog' {
				'# Release Notes - v1.2.0\n\n## New Features\n\n- Added enterprise telemetry dashboards to all studios\n- Upgraded JSON parsing engine\n\n## Bug Fixes\n\n- Fixed path normalization on macOS and Linux\n'
			}
			'Template: Engineering Blog Post' {
				'# Building Next-Gen Desktop Apps with V\n\n*Published on September 13, 2026*\n\nModern software development demands both speed and simplicity.\n\n## Why Native Matters\n\nBy leveraging OS-native webviews and lightweight compiled binaries, we achieve microsecond startup times.\n'
			}
			else { '# Document\n\nContent here.\n' }
		}
		w.set_value('md_source', text)
		update_markdown_telemetry(w, text)
		w.toast_info('Loaded: ' + val)
	})
	win.button('🎨 Render Markdown to HTML', fn (w &simplegui.SimpleWindow, _ string) {
		md := w.get('md_source')
		html := convert_markdown_to_html(md)
		w.set_value('html_rendered', html)
		w.toast_success('Rendered HTML document successfully!')
	})
	win.row_end()

	// Dual-Pane Editor Box
	win.box_start('📝 Markdown Source & HTML Output Split-Pane')
	win.row_start()
	win.subheading('Markdown Source Document')
	win.subheading('Rendered HTML Markup')
	win.row_end()

	win.row_start()
	win.textarea_named('md_source', 'Write markdown content here...', sample_md, fn (w &simplegui.SimpleWindow, val string) {
		update_markdown_telemetry(w, val)
	})
	win.textarea_named('html_rendered', 'HTML markup will appear here...', convert_markdown_to_html(sample_md), fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	// Action Buttons Row
	win.row_start()
	win.button('📋 Copy HTML to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		html := w.get('html_rendered')
		system.set_clipboard_text(html)
		w.toast_success('HTML markup copied to clipboard!')
	})
	win.button('📋 Copy Markdown Source', fn (w &simplegui.SimpleWindow, _ string) {
		md := w.get('md_source')
		system.set_clipboard_text(md)
		w.toast_success('Markdown source copied to clipboard!')
	})
	win.button('📂 Open Markdown File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Open Markdown Document', 'md,markdown,txt')
		if path != '' {
			content := os.read_file(path) or {
				w.toast_error('Failed to read file: ${err}')
				return
			}
			w.set_value('md_source', content)
			w.set_value('html_rendered', convert_markdown_to_html(content))
			update_markdown_telemetry(w, content)
			w.toast_success('Opened: ' + path)
		}
	})
	win.button('💾 Save Markdown File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.save_file_dialog('Save Markdown File', 'document.md')
		if path != '' {
			md := w.get('md_source')
			os.write_file(path, md) or {
				w.toast_error('Failed to save file: ${err}')
				return
			}
			w.toast_success('Markdown saved to: ' + path)
		}
	})
	win.button('🌐 Export HTML Page...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.save_file_dialog('Export HTML Page', 'document.html')
		if path != '' {
			html := w.get('html_rendered')
			os.write_file(path, html) or {
				w.toast_error('Failed to export HTML: ${err}')
				return
			}
			w.toast_success('Exported standalone HTML page to: ' + path)
		}
	})
	win.row_end()
	win.box_end()

	win.status_bar('Markdown Studio Pro Enterprise  •  High-Performance Document Authoring  •  Ready')

	// Initial telemetry
	update_markdown_telemetry(win, sample_md)

	win.run()
}
