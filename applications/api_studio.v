module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'API Studio Pro -- REST Client & HTTP Inspector'
		width: 1150
		height: 850
		theme: 'nord'
	)

	win.heading('🌐 API Studio Pro')
	win.label('Full-Featured Native REST API Client Workstation: GET, POST, PUT, DELETE, Headers & JSON Payload Inspector')

	win.subheading('HTTP Method & Request URL')
	win.input('Request Endpoint URL...', 'https://httpbin.org/get', fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('Request Body (JSON / Text)')
	win.textarea('Request payload for POST/PUT/PATCH...', '{\n  "client": "Vlang Webview RAD Studio",\n  "version": "1.0.0"\n}', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Response Output Inspector')
	win.textarea('Response status and body will appear here...', 'Status: Ready\nClick "Send HTTP GET" to execute a live request.', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Actions')

	win.button('🚀 Send HTTP GET Request', fn (w &simplegui.SimpleWindow, _ string) {
		url := w.get_value('inp_1')
		w.notification('Sending Request', 'GET: ' + url)
		resp := system.http_get(url)
		result_str := 'Status: ${resp.status_code}\n\nHeaders:\n${resp.headers}\n\nBody:\n${resp.body}'
		w.set_value('txt_2', result_str)
		w.alert('HTTP Response', 'Received status: ${resp.status_code}')
	})

	win.button('📤 Send HTTP POST Request', fn (w &simplegui.SimpleWindow, _ string) {
		url := w.get_value('inp_1')
		body := w.get_value('txt_1')
		w.notification('Sending Request', 'POST: ' + url)
		resp := system.http_post(url, body, 'application/json')
		result_str := 'Status: ${resp.status_code}\n\nResponse Body:\n${resp.body}'
		w.set_value('txt_2', result_str)
		w.alert('HTTP Response', 'Received status: ${resp.status_code}')
	})

	win.status_bar('API Studio Pro  •  Native V net.http Engine  •  Ready')
	win.run()
}
