module main

import simplegui
import system

fn load_process_rows() ![][]string {
	res := system.exec_safe('ps', ['-axo', 'pid,ppid,%cpu,%mem,comm', '-r'])
	if res.exit_code != 0 {
		return error(res.output)
	}
	lines := res.output.split_into_lines()
	mut rows := [][]string{}
	for i, line in lines {
		if i == 0 || rows.len >= 11 {
			continue
		}
		tokens := line.trim_space().split_any(' \t').filter(it != '')
		if tokens.len >= 5 {
			rows << [tokens[0], tokens[1], tokens[2], tokens[3], tokens[4..].join(' ')]
		}
	}
	return rows
}

fn is_valid_pid(pid string) bool {
	return pid != '' && pid.bytes().all(it.is_digit())
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Process & Task Manager Studio Pro'
		width: 1100
		height: 820
		theme: 'dracula'
	)

	win.heading('⚡ Process & Task Manager Studio Pro')
	win.label('Real-time Operating System Process Inspection, CPU/RAM Metrics & Task Control')

	win.subheading('Active System Processes (Top by CPU)')
	win.table_named('process_table', ['PID', 'PPID', '% CPU', '% MEM', 'Command Name'], [
		['-', '-', '-', '-', 'Click Refresh Process List to load processes'],
	], fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Process Inspected', 'Inspected process row #${idx}')
	})

	win.divider()
	win.subheading('Task Management')
	win.input('Enter Process PID to inspect or signal...', '', fn (w &simplegui.SimpleWindow, _ string) {})

	win.button('🔄 Refresh Process List', fn (w &simplegui.SimpleWindow, _ string) {
		rows := load_process_rows() or {
			w.alert('Refresh Failed', 'Could not load processes:\n${err}')
			return
		}
		w.set_table_rows('process_table', rows)
		w.notification('Process List', 'Loaded ${rows.len} active processes')
	})

	win.button('⚠️ Inspect Selected PID', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('inp_1').trim_space()
		if !is_valid_pid(pid) {
			w.alert('Process Info', 'Enter a numeric process PID.')
			return
		}
		res := system.exec_safe('ps', ['-p', pid, '-o', 'pid,ppid,user,%cpu,%mem,comm'])
		if res.exit_code != 0 {
			w.alert('Process Not Found', res.output)
			return
		}
		w.alert('Process Details (PID ${pid})', res.output)
	})

	win.status_bar('Task Manager Studio Pro  •  POSIX Process Management  •  Running')
	win.run()
}
