module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('system_cli')
	fp.version('2.0.0')
	fp.description('Cross-Platform Hardware Telemetry, Subsystem Explorer & OS Inspector')
	fp.skip_executable()

	show_telemetry := fp.bool('telemetry', `t`, false, 'Display full hardware and memory telemetry')
	show_cpu := fp.bool('cpu', `c`, false, 'Display CPU model, cores, and usage')
	show_mem := fp.bool('mem', `m`, false, 'Display RAM metrics (total, used, free)')
	show_battery := fp.bool('battery', `b`, false, 'Display battery percentage and charging state')
	show_network := fp.bool('network', `n`, false, 'Display network interfaces and IPs')
	show_json := fp.bool('json', `j`, false, 'Output telemetry in JSON format')
	run_audit := fp.bool('audit', `a`, false, 'Run comprehensive full-system hardware and OS audit')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	hw := system.get_hardware_telemetry()
	local_ip := system.get_masked_ip()

	if show_json {
		println('{')
		println('  "os": "${hw.os_name}",')
		println('  "release": "${hw.os_version}",')
		println('  "arch": "${hw.cpu_arch}",')
		println('  "hostname": "${hw.hostname}",')
		println('  "cpu_model": "${hw.cpu_model}",')
		println('  "cpu_cores": ${hw.cpu_cores},')
		println('  "cpu_usage_pct": ${hw.cpu_usage:.1f},')
		println('  "ram_total_bytes": ${hw.ram_total_bytes},')
		println('  "ram_used_bytes": ${hw.ram_used_bytes},')
		println('  "ram_free_bytes": ${hw.ram_free_bytes},')
		println('  "uptime_sec": ${hw.uptime_seconds},')
		println('  "local_ip": "${local_ip}"')
		println('}')
		return
	}

	println('====================================================================')
	println('⚡ SYSTEM & HARDWARE WORKSTATION CLI (vlang)')
	println('====================================================================')
	println('🖥️  OS:       ${hw.os_name} ${hw.os_version} (${hw.cpu_arch})')
	println('🏷️  Hostname: ${hw.hostname}')
	println('⏱️  Uptime:   ${hw.uptime_seconds} seconds (~${f64(hw.uptime_seconds) / 3600.0:.1f} hours)')
	println('🌐 IP:       ${local_ip}')

	if show_telemetry || show_cpu || run_audit {
		println('\n[CPU Information]')
		println('  Model: ${hw.cpu_model}')
		println('  Cores: ${hw.cpu_cores}')
		println('  Arch:  ${hw.cpu_arch}')
		println('  Usage: ${hw.cpu_usage:.1f}%')
	}

	if show_telemetry || show_mem || run_audit {
		println('\n[Memory (RAM)]')
		println('  Total: ${system.format_bytes(hw.ram_total_bytes)}')
		println('  Used:  ${system.format_bytes(hw.ram_used_bytes)}')
		println('  Free:  ${system.format_bytes(hw.ram_free_bytes)}')
	}

	if show_telemetry || show_battery || run_audit {
		println('\n[Battery Status]')
		println('  Level:    ${hw.battery_percent}%')
		println('  Charging: ${hw.battery_charging}')
		println('  AC Power: ${hw.ac_connected}')
	}

	if show_telemetry || show_network || run_audit {
		can_ping := system.ping_host('8.8.8.8')
		println('\n[Network Telemetry]')
		println('  Local IP:      ${local_ip}')
		println('  Internet Ping: ${if can_ping { "Connected (8.8.8.8 OK)" } else { "Disconnected" }}')
	}

	println('====================================================================')
}
