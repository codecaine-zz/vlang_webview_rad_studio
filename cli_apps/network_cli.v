module main

import flag
import os
import system

fn is_valid_host(host string) bool {
	return host != '' && !host.starts_with('-')
		&& host.bytes().all(it.is_alnum() || it in [`.`, `-`, `:`, `_`])
}

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

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}
	mode_count := int(show_ip) + int(ping_target != '') + int(show_dns != '') + int(show_ports)
	if mode_count > 1 {
		eprintln('Error: Network operation flags are mutually exclusive')
		exit(2)
	}
	if ping_target != '' && !is_valid_host(ping_target) {
		eprintln('Error: Invalid ping target "${ping_target}"')
		exit(2)
	}
	if show_dns != '' && !is_valid_host(show_dns) {
		eprintln('Error: Invalid DNS hostname "${show_dns}"')
		exit(2)
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
			eprintln('❌ Host ${ping_target} is unreachable or timed out.')
			exit(1)
		}
		return
	}

	if show_dns != '' {
		println('Resolving DNS for: ${show_dns}')
		$if windows {
			res := system.exec_safe('nslookup', [show_dns])
			if res.exit_code != 0 {
				eprintln('Error: DNS lookup failed: ${res.output.trim_space()}')
				exit(1)
			}
			println(res.output.trim_space())
		} $else {
			mut res := system.exec_safe('dig', ['+short', show_dns])
			if res.exit_code != 0 || res.output.trim_space() == '' {
				res = system.exec_safe('nslookup', [show_dns])
			}
			if res.exit_code != 0 {
				eprintln('Error: DNS lookup failed: ${res.output.trim_space()}')
				exit(1)
			}
			println(res.output.trim_space())
		}
		return
	}

	if show_ports {
		println('Active Listening Ports:')
		$if windows {
			out, code := system.exec('netstat -ano | findstr LISTENING')
			if code !in [0, 1] {
				eprintln('Error: Unable to list ports: ${out}')
				exit(1)
			}
			println(out)
		} $else $if macos {
			out, code := system.exec('lsof -i -P -n | grep LISTEN')
			if code !in [0, 1] {
				eprintln('Error: Unable to list ports: ${out}')
				exit(1)
			}
			println(out)
		} $else {
			out, code := system.exec('ss -tulpn | grep LISTEN')
			if code !in [0, 1] {
				eprintln('Error: Unable to list ports: ${out}')
				exit(1)
			}
			println(out)
		}
		return
	}

	// Default: show summary
	println('Local IP:         ${system.get_masked_ip()}')
	println('Gateway Ping:     ${if system.ping_host('1.1.1.1') {
		'OK (1.1.1.1 reachable)'
	} else {
		'Failed'
	}}')
	println('Google DNS Ping:  ${if system.ping_host('8.8.8.8') {
		'OK (8.8.8.8 reachable)'
	} else {
		'Failed'
	}}')
	println('====================================================================')
}
