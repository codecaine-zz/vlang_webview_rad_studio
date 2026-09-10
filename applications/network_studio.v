module main

import simplegui
import system

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
		['Ping ICMP Echo', '8.8.8.8', if system.ping_host('8.8.8.8') { 'Reachable (Online)' } else { 'Unreachable' }],
		['Ping Cloudflare DNS', '1.1.1.1', if system.ping_host('1.1.1.1') { 'Reachable (Online)' } else { 'Unreachable' }],
		['Local Loopback', '127.0.0.1', 'Connected (Local)'],
		['Local IPv4 Interface', masked_ip, 'Active (Protected)']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Probe Selected', 'Inspected test row #${idx}')
	})

	win.divider()
	win.subheading('Actions')

	win.button('⚡ Ping Target Host', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1')
		w.notification('Pinging...', 'Sending ICMP packets to ' + host)
		out, code := system.exec('ping -c 3 "${host}"')
		w.alert('Ping Result (Exit Code ${code})', out)
	})

	win.button('🔍 DNS Lookup (nslookup)', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1')
		out, _ := system.exec('nslookup "${host}"')
		w.alert('DNS Resolution Result', out)
	})

	win.button('📊 Traceroute Host', fn (w &simplegui.SimpleWindow, _ string) {
		host := w.get_value('inp_1')
		w.notification('Traceroute', 'Tracing route to ' + host)
		out, _ := system.exec('traceroute -m 5 "${host}" 2>/dev/null || ping -c 1 "${host}"')
		w.alert('Route Trace', out)
	})

	win.status_bar('Network Studio Pro  •  TCP/IP Sockets & Diagnostics  •  Online')
	win.run()
}
