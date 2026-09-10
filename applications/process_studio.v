module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Process & Task Manager Studio Pro'
		width: 1100
		height: 820
		theme: 'dracula'
	)

	win.heading('⚡ Process & Task Manager Studio Pro')
	win.label('Real-time Operating System Process Inspection, CPU/RAM Metrics & Task Control')

	// Retrieve running processes using ps
	ps_out := system.exec_or("ps -axo pid,ppid,%cpu,%mem,comm -r | head -n 12", "")
	lines := ps_out.split_into_lines()

	mut headers := ['PID', 'PPID', '% CPU', '% MEM', 'Command Name']
	mut rows := [][]string{}

	for i, l in lines {
		if i == 0 { continue }
		tokens := l.trim_space().split_any(' \t')
		mut clean := []string{}
		for t in tokens {
			if t.trim_space() != '' { clean << t.trim_space() }
		}
		if clean.len >= 5 {
			cmd_name := clean[4..].join(' ')
			rows << [clean[0], clean[1], clean[2], clean[3], cmd_name]
		}
	}

	win.subheading('Active System Processes (Top by CPU)')
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Process Inspected', 'Inspected process row #${idx}')
	})

	win.divider()
	win.subheading('Task Management')
	win.input('Enter Process PID to inspect or signal...', '', fn (w &simplegui.SimpleWindow, _ string) {})

	win.button('🔄 Refresh Process List', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('Process List', 'Refreshed active task table')
	})

	win.button('⚠️ Inspect Selected PID', fn (w &simplegui.SimpleWindow, _ string) {
		pid := w.get_value('inp_1')
		if pid.trim_space() == '' {
			w.alert('Process Info', 'Please enter a valid process PID')
			return
		}
		out := system.exec_or('ps -p ${pid} -o pid,ppid,user,%cpu,%mem,comm', 'Process not found')
		w.alert('Process Details (PID ${pid})', out)
	})

	win.status_bar('Task Manager Studio Pro  •  POSIX Process Management  •  Running')
	win.run()
}
