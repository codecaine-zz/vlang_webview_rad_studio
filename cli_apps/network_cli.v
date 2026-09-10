module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('network_cli')
	fp.version('2.0.0')
	fp.description('Network Diagnostics, Ping & Interface Explorer CLI')
	fp.skip_executable()

	ping_target := fp.string('ping', `p`, '', 'Host or IP to ping')
	show_ip := fp.bool('ip', `i`, false, 'Display local IPv4 address')
	show_dns := fp.string('dns', `d`, '', 'Resolve DNS for hostname')
	show_ports := fp.bool('ports', `l`, false, 'List active listening ports')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	println('====================================================================')
	println('🌐 NETWORK DIAGNOSTICS & TELEMETRY CLI')
	println('====================================================================')

	if show_ip {
		println('Local IP Address: ${system.get_masked_ip()}')
		return
	}

	if ping_target != '' {
		println('Pinging ${ping_target}...')
		ok := system.ping_host(ping_target)
		if ok {
			println('✅ Host ${ping_target} is reachable!')
		} else {
			println('❌ Host ${ping_target} is unreachable or timed out.')
		}
		return
	}

	if show_dns != '' {
		println('Resolving DNS for: ${show_dns}')
		$if windows {
			out, _ := system.exec('nslookup ${show_dns}')
			println(out)
		} $else {
			out, _ := system.exec('dig +short ${show_dns} 2>/dev/null || nslookup ${show_dns}')
			println(out)
		}
		return
	}

	if show_ports {
		println('Active Listening Ports:')
		$if windows {
			out, _ := system.exec('netstat -ano | findstr LISTENING')
			println(out)
		} $else $if macos {
			out, _ := system.exec('lsof -i -P -n | grep LISTEN')
			println(out)
		} $else {
			out, _ := system.exec('ss -tulpn | grep LISTEN')
			println(out)
		}
		return
	}

	// Default: show summary
	println('Local IP:         ${system.get_masked_ip()}')
	println('Gateway Ping:     ${if system.ping_host("1.1.1.1") { "OK (1.1.1.1 reachable)" } else { "Failed" }}')
	println('Google DNS Ping:  ${if system.ping_host("8.8.8.8") { "OK (8.8.8.8 reachable)" } else { "Failed" }}')
	println('====================================================================')
}
