module main

import flag
import os
import time
import system

fn get_last_mtime(path string) !u64 {
	if !os.exists(path) {
		return error('watch path no longer exists')
	}
	if os.is_file(path) {
		return u64(os.file_last_mod_unix(path))
	}
	mut max_t := u64(0)
	files := os.ls(path)!
	for f in files {
		sub := os.join_path(path, f)
		t := u64(os.file_last_mod_unix(sub))
		if t > max_t {
			max_t = t
		}
	}
	return max_t
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('watcher_cli')
	fp.version('2.0.0')
	fp.description('File System Watcher & Automated Command Trigger CLI')
	fp.skip_executable()

	path := fp.string('path', `p`, '.', 'Directory or file path to watch')
	exec_cmd := fp.string('exec', `e`, '', 'Command to execute on change')
	interval_ms := fp.int('interval', `i`, 1000, 'Poll interval in ms')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}
	if !os.exists(path) {
		eprintln('Error: Watch path "${path}" does not exist')
		exit(1)
	}
	if interval_ms <= 0 {
		eprintln('Error: --interval must be greater than zero')
		exit(2)
	}

	println('====================================================================')
	println('👀 FILE SYSTEM WATCHER (vlang)')
	println('====================================================================')
	println('Watching path: ${os.real_path(path)}')
	if exec_cmd != '' {
		println('Trigger:       ${exec_cmd}')
	}
	println('Interval:      ${interval_ms} ms')
	println('Press Ctrl+C to terminate.')
	println('--------------------------------------------------------------------')

	mut last_t := get_last_mtime(path) or {
		eprintln('Error: Unable to inspect watch path "${path}": ${err}')
		exit(1)
	}

	for {
		time.sleep(interval_ms * time.millisecond)
		curr_t := get_last_mtime(path) or {
			eprintln('Error: Unable to inspect watch path "${path}": ${err}')
			exit(1)
		}
		if curr_t > last_t && last_t != 0 {
			now_str := time.now().custom_format('HH:mm:ss')
			println('[${now_str}] ⚡ Change detected in ${path}!')
			if exec_cmd != '' {
				println('  Running: ${exec_cmd}')
				out, code := system.exec(exec_cmd)
				println('  Exit: ${code}\n  ${out}')
			}
		}
		last_t = curr_t
	}
}
