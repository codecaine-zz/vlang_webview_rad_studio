module main

import flag
import os
import system

struct ProcessEntry {
	pid  string
	user string
	cpu  string
	mem  string
	cmd  string
}

fn list_processes() []ProcessEntry {
	mut procs := []ProcessEntry{}
	$if windows {
		out, _ := system.exec('tasklist /FO CSV /NH')
		lines := out.split_into_lines()
		for line in lines {
			parts := line.split('","')
			if parts.len >= 5 {
				cmd := parts[0].trim('"')
				pid := parts[1].trim('"')
				mem := parts[4].trim('"')
				procs << ProcessEntry{
					pid: pid
					user: 'User'
					cpu: '0.0'
					mem: mem
					cmd: cmd
				}
			}
		}
	} $else {
		out, _ := system.exec('ps -eo pid,user,%cpu,%mem,comm')
		lines := out.split_into_lines()
		for i in 1 .. lines.len {
			line := lines[i].trim_space()
			if line == '' { continue }
			tokens := line.split_any(' \t').filter(it != '')
			if tokens.len >= 5 {
				procs << ProcessEntry{
					pid: tokens[0]
					user: tokens[1]
					cpu: tokens[2]
					mem: tokens[3]
					cmd: tokens[4..].join(' ')
				}
			}
		}
	}
	return procs
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('process_cli')
	fp.version('2.0.0')
	fp.description('Cross-Platform Process & Task Manager CLI')
	fp.skip_executable()

	filter := fp.string('filter', `f`, '', 'Filter processes by name')
	kill_pid := fp.string('kill', `k`, '', 'Kill process by PID')
	top_n := fp.int('top', `t`, 20, 'Show top N processes (default: 20)')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	if kill_pid != '' {
		$if windows {
			system.exec('taskkill /F /PID ${kill_pid}')
		} $else {
			system.exec('kill -9 ${kill_pid}')
		}
		println('Sent termination signal to PID ${kill_pid}')
		return
	}

	procs := list_processes()
	mut matched := []ProcessEntry{}
	for p in procs {
		if filter == '' || p.cmd.to_lower().contains(filter.to_lower()) {
			matched << p
		}
	}

	println('====================================================================')
	println('⚡ PROCESS & TASK WORKSTATION CLI (vlang)')
	println('====================================================================')
	println('${"PID":<8} ${"USER":<12} ${"%CPU":<8} ${"%MEM":<8} ${"COMMAND"}')
	println('--------------------------------------------------------------------')

	count := if matched.len < top_n { matched.len } else { top_n }
	for i in 0 .. count {
		p := matched[i]
		println('${p.pid:<8} ${p.user:<12} ${p.cpu:<8} ${p.mem:<8} ${p.cmd}')
	}
	println('--------------------------------------------------------------------')
	println('Showing ${count} of ${matched.len} processes matched.')
	println('====================================================================')
}
