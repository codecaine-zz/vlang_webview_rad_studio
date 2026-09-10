module main

import os
import webview

fn main() {
	println('⚡ Launching Vlang RAD Studio (Delphi / Visual Basic Style IDE)...')

	// Load IDE HTML template
	html_path := os.join_path(os.getwd(), 'resources', 'ide.html')
	mut html := if os.exists(html_path) {
		os.read_file(html_path) or { $embed_file('resources/ide.html').to_string() }
	} else {
		$embed_file('resources/ide.html').to_string()
	}

	// Default form specification
	default_spec := '{"title": "Form1", "width": 800, "height": 600, "background_color": "#0f172a", "font_color": "#e2e8f0", "padding": 20, "spacing": 12, "controls": []}'
	html = html.replace('__SPEC_JSON__', default_spec)

	mut w := webview.create(debug: true)
	w.set_title('Vlang RAD Studio (Delphi/VB Style)')
	w.set_size(1400, 900, .@none)

	// Attach window management bindings (fullscreen, minimize, pin, center, placement)
	w.attach_window_management_bindings()

	// Attach full system tools and hardware telemetry bindings
	w.attach_system_bindings()

	// Attach standard library bindings (HTTP, crypto, encoders, stats)
	w.attach_stdlib_bindings()

	// RAD Studio Exporter Binding
	w.bind('exportProject', fn (e &webview.Event) string {
		spec_json := e.get_arg[string](0) or { '{}' }
		return export_project_helper(spec_json)
	})

	// RAD Studio Live Preview Runner Binding
	w.bind('runPreview', fn (e &webview.Event) string {
		spec_json := e.get_arg[string](0) or { '{}' }
		return run_preview_helper(spec_json)
	})

	// Backend Alert Binding
	w.bind('backendAlert', fn (e &webview.Event) string {
		msg := e.get_arg[string](0) or { '' }
		println('⚡ [RAD Studio Alert]: ${msg}')
		return 'ok'
	})

	w.set_html(html)
	w.set_fullscreen(true)
	println('🚀 Vlang RAD Studio running on native Webview...')
	w.run()
}
