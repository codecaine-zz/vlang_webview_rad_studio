module main

import simplegui
import system

fn is_valid_host(host string) bool {
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

fn main() {
	mut win := simplegui.new_window(
		title: 'Network Studio Pro -- Network Intelligence & Telemetry'
		width: 1120
		height: 840
		theme: 'navy_blue'
	)

	win.heading('🌐 Network Studio Pro')
	win.label('Comprehensive Network Diagnostics: Ping Latency, DNS Resolution, Interfaces & Local IP Inspection')

	masked_ip := system.get_masked_ip()
	win.kpi_card('Network Interface', masked_ip, 'IPv4 Protected (Privacy Mode)')

	win.subheading('Target Hostname or IP')
	win.input('Target hostname (e.g. google.com, 1.1.1.1)...', 'google.com', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Diagnostic Probes')

	headers := ['Diagnostic Test', 'Target Address', 'Result Status']
	rows := [
		['Ping ICMP Echo', '8.8.8.8', 'Run a probe to check'],
		['Ping Cloudflare DNS', '1.1.1.1', 'Run a probe to check'],
		['Local Loopback', '127.0.0.1', 'Connected (Local)'],
		['Local IPv4 Interface', masked_ip, 'Active (Protected)'],
	]
	win.table_named('network_diagnostics', headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Probe Selected', 'Inspected test row #${idx}')
	})

	win.divider()
	win.subheading('Actions')

	win.button('⚡ Ping Target Host', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1').trim_space()
		if !is_valid_host(host) {
			w.alert('Invalid Host', 'Enter a hostname or IP address without shell characters.')
			return
		}
		w.notification('Pinging...', 'Sending ICMP packets to ' + host)
		args := $if windows { ['-n', '3', host] } $else { ['-c', '3', host] }
		res := system.exec_safe('ping', args)
		status := if res.exit_code == 0 { 'Reachable' } else { 'Failed (exit ${res.exit_code})' }
		w.set_table_rows('network_diagnostics', [['Ping ICMP Echo', host, status]])
		w.alert('Ping Result (Exit Code ${res.exit_code})', res.output)
	})

	win.button('🔍 DNS Lookup (nslookup)', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1').trim_space()
		if !is_valid_host(host) {
			w.alert('Invalid Host', 'Enter a hostname or IP address without shell characters.')
			return
		}
		res := system.exec_safe('nslookup', [host])
		w.alert('DNS Resolution Result (Exit Code ${res.exit_code})', res.output)
	})

	win.button('📊 Traceroute Host', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1').trim_space()
		if !is_valid_host(host) {
			w.alert('Invalid Host', 'Enter a hostname or IP address without shell characters.')
			return
		}
		w.notification('Traceroute', 'Tracing route to ' + host)
		res := $if windows { system.exec_safe('tracert', ['-h', '5', host]) } $else { system.exec_safe('traceroute', [
			'-m',
			'5',
			host,
		]) }
		w.alert('Route Trace (Exit Code ${res.exit_code})', res.output)
	})

	win.status_bar('Network Studio Pro  •  TCP/IP Sockets & Diagnostics  •  Online')
	win.run()
}
