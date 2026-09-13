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

fn list_processes() ![]ProcessEntry {
	mut procs := []ProcessEntry{}
	$if windows {
		out, code := system.exec('tasklist /FO CSV /NH')
		if code != 0 {
			return error(out)
		}
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
		res := system.exec_safe('ps', ['-eo', 'pid,user,%cpu,%mem,comm'])
		if res.exit_code != 0 {
			return error(res.output)
		}
		out := res.output
		lines := out.split_into_lines()
		for i in 1 .. lines.len {
			line := lines[i].trim_space()
			if line == '' {
				continue
			}
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

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}
	if top_n <= 0 {
		eprintln('Error: --top must be greater than zero')
		exit(2)
	}

	if kill_pid != '' {
		pid := kill_pid.int()
		if pid <= 1 || pid.str() != kill_pid {
			eprintln('Error: --kill requires a numeric PID greater than 1')
			exit(2)
		}
		$if windows {
			res := system.exec_safe('taskkill', ['/PID', kill_pid])
			if res.exit_code != 0 {
				eprintln('Error: Failed to terminate PID ${kill_pid}: ${res.output.trim_space()}')
				exit(1)
			}
		} $else {
			res := system.exec_safe('kill', ['-TERM', kill_pid])
			if res.exit_code != 0 {
				eprintln('Error: Failed to terminate PID ${kill_pid}: ${res.output.trim_space()}')
				exit(1)
			}
		}
		println('Sent termination signal to PID ${kill_pid}')
		return
	}

	procs := list_processes() or {
		eprintln('Error: Unable to list processes: ${err}')
		exit(1)
	}
	mut matched := []ProcessEntry{}
	for p in procs {
		if filter == '' || p.cmd.to_lower().contains(filter.to_lower()) {
			matched << p
		}
	}

	println('====================================================================')
	println('⚡ PROCESS & TASK WORKSTATION CLI (vlang)')
	println('====================================================================')
	println('PID      USER         %CPU     %MEM     COMMAND')
	println('--------------------------------------------------------------------')

	count := if matched.len < top_n { matched.len } else { top_n }
	for i in 0 .. count {
		p := matched[i]
		pid_col := p.pid + ' '.repeat(if p.pid.len < 8 { 8 - p.pid.len } else { 1 })
		user_col := p.user + ' '.repeat(if p.user.len < 12 { 12 - p.user.len } else { 1 })
		cpu_col := p.cpu + ' '.repeat(if p.cpu.len < 8 { 8 - p.cpu.len } else { 1 })
		mem_col := p.mem + ' '.repeat(if p.mem.len < 8 { 8 - p.mem.len } else { 1 })
		println('${pid_col}${user_col}${cpu_col}${mem_col}${p.cmd}')
	}
	println('--------------------------------------------------------------------')
	println('Showing ${count} of ${matched.len} processes matched.')
	println('====================================================================')
}
