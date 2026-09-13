module main

import simplegui
import system
import json2
import time
import os

struct RequestHistoryItem {
	timestamp   string
	method      string
	url         string
	status_code int
	duration_ms i64
	size_bytes  int
}

fn parse_headers_input(raw string) map[string]string {
	mut headers := map[string]string{}
	for line in raw.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed == '' || trimmed.starts_with('#') || trimmed.starts_with('//') {
			continue
		}
		idx := trimmed.index(':') or { continue }
		k := trimmed[..idx].trim_space()
		v := trimmed[idx + 1..].trim_space()
		if k != '' {
			headers[k] = v
		}
	}
	return headers
}

fn generate_curl_command(method string, url string, headers map[string]string, body string) string {
	mut parts := ['curl -X ${method}']
	for k, v in headers {
		parts << '-H "${k}: ${v}"'
	}
	if method in ['POST', 'PUT', 'PATCH'] && body.trim_space() != '' {
		escaped_body := body.replace('"', '\\"')
		parts << '-d "${escaped_body}"'
	}
	parts << '"${url}"'
	return parts.join(' \\\n  ')
}

fn execute_api_request(w &simplegui.SimpleWindow, mut history []RequestHistoryItem) {
	method := w.get('req_method').trim_space()
	url := w.get('req_url').trim_space()

	if url == '' {
		w.toast_warning('Please enter a target request URL.')
		return
	}
	if !system.is_safe_url(url) {
		w.toast_error('Invalid URL protocol. Must start with http:// or https://')
		return
	}

	raw_headers := w.get('req_headers')
	headers := parse_headers_input(raw_headers)
	body := w.get('req_body')

	w.set_kpi('kpi_status', 'Sending...', 'In Flight')
	w.set_status('Sending HTTP ${method} to: ${url}')

	sw := time.new_stopwatch()
	resp := system.http_request(method, url, body, headers)
	elapsed := sw.elapsed()
	dur_ms := elapsed.milliseconds()

	status_str := if resp.status_code == 0 {
		'Network Error'
	} else {
		'${resp.status_code} ' + match resp.status_code {
			200 { 'OK' }
			201 { 'Created' }
			204 { 'No Content' }
			400 { 'Bad Request' }
			401 { 'Unauthorized' }
			403 { 'Forbidden' }
			404 { 'Not Found' }
			500 { 'Internal Error' }
			else { 'Response' }
		}
	}

	size_bytes := resp.body.len
	size_str := system.format_bytes(u64(size_bytes))
	now_str := time.now().custom_format('HH:mm:ss')

	// Format response body (prettify if valid JSON)
	mut display_body := resp.body
	if parsed_json := json2.decode[json2.Any](resp.body) {
		display_body = json2.encode[json2.Any](parsed_json, prettify: true)
	}

	// Update GUI state
	w.set_value('res_body', display_body)
	w.set_kpi('kpi_status', status_str, if resp.status_code >= 200 && resp.status_code < 300 { 'Success' } else { 'Attention' })
	w.set_kpi('kpi_latency', '${dur_ms}ms', 'Roundtrip')
	w.set_kpi('kpi_size', size_str, '${size_bytes} Bytes')

	// Update Headers Table
	mut header_rows := [][]string{}
	for k, v in resp.headers {
		header_rows << [k, v]
	}
	if header_rows.len == 0 {
		header_rows << ['(None)', 'No response headers returned']
	}
	w.set_table_rows('res_headers_table', header_rows)

	// Append to History
	history << RequestHistoryItem{
		timestamp: now_str
		method: method
		url: url
		status_code: resp.status_code
		duration_ms: dur_ms
		size_bytes: size_bytes
	}
	w.set_kpi('kpi_requests', '${history.len} Total', '+1 just now')
	w.add_table_row('req_history_table', [now_str, method, '${resp.status_code}', '${dur_ms}ms', size_str, url])

	if resp.status_code >= 200 && resp.status_code < 400 {
		w.toast_success('HTTP ${resp.status_code} received [${dur_ms}ms]')
		w.set_status('HTTP ${resp.status_code} • ${size_str} received in ${dur_ms}ms')
	} else {
		w.toast_warning('HTTP ${status_str} [${dur_ms}ms]')
		w.set_status('HTTP ${status_str} • ${size_str} received in ${dur_ms}ms')
	}
}

fn main() {
	mut history := []RequestHistoryItem{}

	mut win := simplegui.new_window(
		title: 'API Studio Pro Enterprise -- REST Client & HTTP Inspector'
		width: 1180
		height: 890
		theme: 'nord'
	)

	win.heading('🌐 API Studio Pro Enterprise')
	win.subheading('Full-Featured Native REST API Client Workstation: Methods, Headers, Payloads & Response Telemetry')
	win.divider()

	// Top Telemetry KPI Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Status Code', 'Ready', 'Standby')
	win.kpi_card_named('kpi_latency', 'Response Latency', '0ms', 'Awaiting request')
	win.kpi_card_named('kpi_size', 'Payload Size', '0 B', 'No response yet')
	win.kpi_card_named('kpi_requests', 'Total Requests', '0 Total', 'Session Ready')
	win.row_end()

	// Request Configuration Box
	win.box_start('🚀 HTTP Request Configuration')

	// Row 1: Method + URL + Quick Presets
	win.row_start()
	methods := ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD']
	win.dropdown_named('req_method', methods, 'GET', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('HTTP Method changed to: ' + val)
	})
	win.input_named('req_url', 'Endpoint URL (e.g. https://httpbin.org/get)...', 'https://httpbin.org/get', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Endpoint URL: ' + val)
	})
	presets := [
		'Quick Endpoint: httpbin GET',
		'Quick Endpoint: httpbin POST',
		'Quick Endpoint: JSONPlaceholder Todo',
		'Quick Endpoint: Localhost 8080',
	]
	win.dropdown_named('endpoint_presets', presets, presets[0], fn (w &simplegui.SimpleWindow, val string) {
		match val {
			'Quick Endpoint: httpbin GET' {
				w.set_value('req_method', 'GET')
				w.set_value('req_url', 'https://httpbin.org/get')
			}
			'Quick Endpoint: httpbin POST' {
				w.set_value('req_method', 'POST')
				w.set_value('req_url', 'https://httpbin.org/post')
				w.set_value('req_body', '{\n  "message": "Hello from API Studio Pro!",\n  "timestamp": "${time.now().unix()}"\n}')
			}
			'Quick Endpoint: JSONPlaceholder Todo' {
				w.set_value('req_method', 'GET')
				w.set_value('req_url', 'https://jsonplaceholder.typicode.com/todos/1')
			}
			'Quick Endpoint: Localhost 8080' {
				w.set_value('req_method', 'GET')
				w.set_value('req_url', 'http://127.0.0.1:8080/api')
			}
			else {}
		}
		w.toast_info('Loaded endpoint: ' + val)
	})
	win.button('🚀 Send Request', fn [mut history] (w &simplegui.SimpleWindow, _ string) {
		execute_api_request(w, mut history)
	})
	win.row_end()

	// Row 2: Headers & Body Split
	win.row_start()
	win.subheading('Headers (Key: Value per line)')
	win.subheading('Request Body (JSON / Form / Text)')
	win.row_end()

	win.row_start()
	default_headers := 'Content-Type: application/json\nUser-Agent: Vlang-Webview-RAD-Studio/1.0\nAccept: application/json'
	win.textarea_named('req_headers', 'Enter headers (Header-Name: Value)...', default_headers, fn (w &simplegui.SimpleWindow, _ string) {})
	default_body := '{\n  "app": "API Studio Pro",\n  "action": "test_request",\n  "active": true\n}'
	win.textarea_named('req_body', 'Request payload (POST, PUT, PATCH)...', default_body, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.button('📋 Copy as cURL', fn (w &simplegui.SimpleWindow, _ string) {
		method := w.get('req_method')
		url := w.get('req_url')
		headers := parse_headers_input(w.get('req_headers'))
		body := w.get('req_body')
		curl_cmd := generate_curl_command(method, url, headers, body)
		system.set_clipboard_text(curl_cmd)
		w.toast_success('cURL command copied to clipboard!')
		w.set_status('cURL command generated and copied to clipboard')
	})
	win.button('🧹 Clear Request Payload', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('req_body', '')
		w.toast_info('Request payload cleared')
	})
	win.row_end()
	win.box_end()

	// Response Inspector Box
	win.box_start('📥 Live HTTP Response Inspector')
	win.raw_html('<style>
		#res_body {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 180px;
			min-height: 180px;
			background: #1e222a;
			color: #88c0d0;
			border: 1px solid #2e3440;
			border-radius: 6px;
			line-height: 1.45;
			padding: 10px;
		}
	</style>')
	win.textarea_named('res_body', 'Response body will appear here after request execution...', 'Status: Ready\nClick "🚀 Send Request" to execute.', fn (w &simplegui.SimpleWindow, _ string) {})

	win.row_start()
	win.button('📋 Copy Response Body', fn (w &simplegui.SimpleWindow, _ string) {
		body := w.get('res_body')
		if body == '' {
			w.toast_warning('Response body is empty.')
			return
		}
		system.set_clipboard_text(body)
		w.toast_success('Response body copied to clipboard!')
	})
	win.button('💾 Save Response Body', fn (w &simplegui.SimpleWindow, _ string) {
		body := w.get('res_body')
		if body == '' {
			w.toast_warning('Nothing to save.')
			return
		}
		save_path := w.save_file_dialog('Save HTTP Response', 'response.json')
		if save_path != '' {
			os.write_file(save_path, body) or {
				w.toast_error('Failed to save response: ${err}')
				return
			}
			w.toast_success('Response saved to: ' + save_path)
		}
	})
	win.row_end()
	win.box_end()

	// Response Headers Table Box
	win.box_start('📋 Response Headers & Request History')
	win.subheading('Response Headers Table')
	headers_head := ['Header Name', 'Header Value']
	headers_init := [
		['Connection', 'Ready'],
	]
	win.table_named('res_headers_table', headers_head, headers_init, fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('Request History & Audit Log')
	hist_headers := ['Timestamp', 'Method', 'Status', 'Duration', 'Size', 'Endpoint URL']
	hist_init := [
		[time.now().custom_format('HH:mm:ss'), 'INIT', '-', '0ms', '0 B', 'Ready for requests'],
	]
	win.table_named('req_history_table', hist_headers, hist_init, fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Selected history entry #${idx}')
	})
	win.box_end()

	win.status_bar('API Studio Pro Enterprise  •  Native V net.http Engine  •  Ready')
	win.run()
}
