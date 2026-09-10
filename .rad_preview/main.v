module main

import webview
import os

fn main() {
	mut w := webview.create(debug: true)
	w.set_title("RAD Studio - Live Form Preview")
	w.set_size(900, 650, .@none)
	w.attach_window_management_bindings()
	html := os.read_file(os.join_path(@DIR, "preview.html")) or { "<h1>Preview Error</h1>" }
	w.set_html(html)
	w.run()
}
