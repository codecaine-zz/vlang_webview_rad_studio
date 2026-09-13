module main

import simplegui
import system
import time

fn is_valid_hostname(host string) bool {
	if host == '' || host.len > 253 {
		return false
	}
	for ch in host {
		if !ch.is_alnum() && ch !in [`.`, `-`, `:`] {
			return false
		}
	}
	return true
}

fn append_net_log(w &simplegui.SimpleWindow, entry string) {
	current := w.get('net_console')
	new_log := if current.trim_space() == '' {
		entry
	} else {
		current + '\n' + entry
	}
	w.set_value('net_console', new_log)
}

fn main() {
	mut probe_count := 0

	mut win := simplegui.new_window(
		title: 'Network Studio Pro Enterprise -- Network Diagnostics & Telemetry'
		width: 1180
		height: 890
		theme: 'navy_blue'
	)

	win.heading('🌐 Network Studio Pro Enterprise')
	win.subheading('Enterprise Network Diagnostics: Ping Latency, DNS Resolution, Port Scanning, Traceroute & Interfaces')
	win.divider()

	local_ip := system.get_masked_ip()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Network Interface', 'Connected', 'IPv4')
	win.kpi_card_named('kpi_ip', 'Local IP Address', local_ip, 'Primary NIC')
	win.kpi_card_named('kpi_ping', 'Last Ping Latency', '0ms', 'Standby')
	win.kpi_card_named('kpi_probes', 'Diagnostic Probes', '0 Run', 'Ready')
	win.row_end()

	// Target Configuration Box
	win.box_start('🎯 Target Host & Diagnostic Presets')
	win.row_start()
	win.input_named('target_host', 'Target Hostname or IP Address...', 'google.com', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Target host updated to: ' + val)
	})
	presets := [
		'Preset: Google DNS (8.8.8.8)',
		'Preset: Cloudflare DNS (1.1.1.1)',
		'Preset: Local Loopback (127.0.0.1)',
		'Preset: Vlang Website (vlang.io)',
		'Preset: GitHub (github.com)',
	]
	win.dropdown_named('target_presets', presets, presets[0], fn (w &simplegui.SimpleWindow, val string) {
		host := match val {
			'Preset: Google DNS (8.8.8.8)' { '8.8.8.8' }
			'Preset: Cloudflare DNS (1.1.1.1)' { '1.1.1.1' }
			'Preset: Local Loopback (127.0.0.1)' { '127.0.0.1' }
			'Preset: Vlang Website (vlang.io)' { 'vlang.io' }
			'Preset: GitHub (github.com)' { 'github.com' }
			else { 'google.com' }
		}
		w.set_value('target_host', host)
		w.toast_info('Loaded host target: ' + host)
	})
	win.row_end()

	// Diagnostic Action Buttons
	win.row_start()
	win.button('⚡ ICMP Ping (3 packets)', fn [mut probe_count] (w &simplegui.SimpleWindow, _ string) {
		host := w.get('target_host').trim_space()
		if !is_valid_hostname(host) {
			w.toast_warning('Invalid host format.')
			return
		}
		w.set_status('Pinging ${host}...')
		now_str := time.now().custom_format('HH:mm:ss')
		args := $if windows { ['-n', '3', host] } $else { ['-c', '3', host] }
		sw := time.new_stopwatch()
		res := system.exec_safe('ping', args)
		dur := sw.elapsed()

		probe_count++
		w.set_kpi('kpi_probes', '${probe_count} Run', '+1 just now')
		w.set_kpi('kpi_ping', '${dur.milliseconds()}ms', if res.exit_code == 0 { 'Reachable' } else { 'Failed' })

		status := if res.exit_code == 0 { 'Reachable (Exit 0)' } else { 'Unreachable (${res.exit_code})' }
		w.add_table_row('diagnostics_table', [now_str, 'ICMP Ping', host, status, '${dur.milliseconds()}ms'])

		append_net_log(w, '[${now_str}] ⚡ PING ${host}\n${res.output.trim_space()}\n------------------------------------------------------------')
		w.toast_success('Ping probe complete for: ' + host)
	})

	win.button('🔍 DNS Lookup (nslookup)', fn [mut probe_count] (w &simplegui.SimpleWindow, _ string) {
		host := w.get('target_host').trim_space()
		if !is_valid_hostname(host) {
			w.toast_warning('Invalid host format.')
			return
		}
		now_str := time.now().custom_format('HH:mm:ss')
		sw := time.new_stopwatch()
		res := system.exec_safe('nslookup', [host])
		dur := sw.elapsed()

		probe_count++
		w.set_kpi('kpi_probes', '${probe_count} Run', '+1 just now')
		status := if res.exit_code == 0 { 'Resolved' } else { 'Failed (${res.exit_code})' }
		w.add_table_row('diagnostics_table', [now_str, 'DNS Lookup', host, status, '${dur.milliseconds()}ms'])

		append_net_log(w, '[${now_str}] 🔍 DNS NSLOOKUP ${host}\n${res.output.trim_space()}\n------------------------------------------------------------')
		w.toast_success('DNS resolution complete for: ' + host)
	})

	win.button('🔌 Port Scanner (Common Ports)', fn [mut probe_count] (w &simplegui.SimpleWindow, _ string) {
		host := w.get('target_host').trim_space()
		if !is_valid_hostname(host) {
			w.toast_warning('Invalid host format.')
			return
		}
		now_str := time.now().custom_format('HH:mm:ss')
		ports_to_test := ['80', '443', '22', '8080']
		mut open_ports := []string{}

		for p in ports_to_test {
			res := system.exec_safe('nc', ['-z', '-G', '1', host, p])
			if res.exit_code == 0 {
				open_ports << p
			}
		}

		status := if open_ports.len > 0 { 'Open: ' + open_ports.join(', ') } else { 'No common open ports' }
		probe_count++
		w.set_kpi('kpi_probes', '${probe_count} Run', '+1 just now')
		w.add_table_row('diagnostics_table', [now_str, 'Port Scan', host, status, '<1s'])

		append_net_log(w, '[${now_str}] 🔌 PORT SCAN ${host}\nScanned ports: ${ports_to_test.join(', ')}\nResult: ${status}\n------------------------------------------------------------')
		w.toast_info('Port scan complete: ' + status)
	})

	win.button('🌐 HTTP Health Check', fn [mut probe_count] (w &simplegui.SimpleWindow, _ string) {
		host := w.get('target_host').trim_space()
		url := if host.starts_with('http://') || host.starts_with('https://') { host } else { 'https://' + host }
		now_str := time.now().custom_format('HH:mm:ss')
		sw := time.new_stopwatch()
		resp := system.http_get(url)
		dur := sw.elapsed()

		probe_count++
		w.set_kpi('kpi_probes', '${probe_count} Run', '+1 just now')
		status := if resp.status_code > 0 { 'HTTP ${resp.status_code}' } else { 'HTTP Error' }
		w.add_table_row('diagnostics_table', [now_str, 'HTTP Probe', url, status, '${dur.milliseconds()}ms'])

		append_net_log(w, '[${now_str}] 🌐 HTTP GET ${url}\nStatus: ${resp.status_code}\nRoundtrip: ${dur.milliseconds()}ms\nBody preview: ${if resp.body.len > 120 { resp.body[..120] + '...' } else { resp.body }}\n------------------------------------------------------------')
		w.toast_success('HTTP Health check: ${status} [${dur.milliseconds()}ms]')
	})
	win.row_end()
	win.box_end()

	// Live Output Console Box
	win.box_start('💻 Real-Time Diagnostic Output Console')
	win.raw_html('<style>
		#net_console {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 160px;
			min-height: 160px;
			background: #0f141c;
			color: #38bdf8;
			border: 1px solid #1e293b;
			border-radius: 6px;
			line-height: 1.45;
			padding: 10px;
		}
	</style>')
	win.textarea_named('net_console', 'Console output from network probes will appear here...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_start()
	win.button('🧹 Clear Console', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('net_console', '')
		w.toast_info('Network console buffer cleared')
	})
	win.button('📋 Copy Console Output', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get('net_console')
		if text == '' {
			w.toast_warning('Console is empty.')
			return
		}
		system.set_clipboard_text(text)
		w.toast_success('Console text copied to clipboard!')
	})
	win.row_end()
	win.box_end()

	// Diagnostic History Table Box
	win.box_start('📋 Diagnostic Probes & History Table')
	diag_headers := ['Timestamp', 'Probe Type', 'Target', 'Result / Status', 'Latency']
	diag_rows := [
		[time.now().custom_format('HH:mm:ss'), 'Interface Check', local_ip, 'Local IP Detected', '0ms'],
	]
	win.table_named('diagnostics_table', diag_headers, diag_rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspected probe row #${idx}')
	})
	win.box_end()

	win.status_bar('Network Studio Pro Enterprise  •  ICMP & Sockets Diagnostics  •  Online')
	win.run()
}
