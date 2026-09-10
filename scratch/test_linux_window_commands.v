module main

import webview

fn main() {
	mut window := webview.create(debug: true)
	window.set_title('Linux Window Command Smoke Test')
	window.set_size(640, 480, .@none)
	window.attach_window_management_bindings()
	window.set_html('<!doctype html><html><body><script>
		setTimeout(() => window.toggleNativeFullscreen(), 200);
		setTimeout(() => window.toggleNativeFullscreen(), 500);
		setTimeout(() => window.setAlwaysOnTop(true), 700);
		setTimeout(() => window.centerWindow(), 900);
	</script></body></html>')
	window.run()
}