module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Git Studio Pro -- Visual Git Workbench'
		width: 1150
		height: 850
		theme: 'github_dark'
	)

	win.heading('🐙 Git Studio Pro')
	win.label('Visual Git Version Control Workbench: Status, Commit Log, Diff Inspector & Branch Management')

	branch := system.exec_or('git rev-parse --abbrev-ref HEAD', 'main')
	status_summary := system.exec_or('git status -s', 'Working tree clean')

	win.kpi_card('Active Branch', branch, 'Git Repository')

	win.subheading('Repository Status Summary')
	win.textarea('Git status output...', status_summary, fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Recent Commits')

	log_out := system.exec_or('git log -n 5 --pretty=format:"%h|%an|%s|%cr"', 'c0d3c0d|codecaine|Initial commit|1 hour ago')
	lines := log_out.split_into_lines()

	headers := ['Commit Hash', 'Author', 'Commit Message', 'Date']
	mut rows := [][]string{}
	for l in lines {
		parts := l.split('|')
		if parts.len >= 4 {
			rows << [parts[0], parts[1], parts[2], parts[3]]
		}
	}
	if rows.len == 0 {
		rows << ['c0d3c0d', 'codecaine', 'Port Bun RAD Studio to Vlang', 'just now']
	}
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Commit Selected', 'Viewing commit #${idx}')
	})

	win.divider()
	win.subheading('Git Actions')

	win.button('🔄 Refresh Repository Status', fn (w &simplegui.SimpleWindow, _ string) {
		st := system.exec_or('git status -s', 'Working tree clean')
		w.set_value('txt_1', st)
		w.notification('Git Refreshed', 'Updated status tree')
	})

	win.button('📋 View Git Diff', fn (w &simplegui.SimpleWindow, _ string) {
		diff := system.exec_or('git diff --stat', 'No unstaged modifications')
		w.alert('Git Diff Summary', diff)
	})

	win.button('🌿 Show Branches', fn (w &simplegui.SimpleWindow, _ string) {
		branches := system.exec_or('git branch -a', '* main')
		w.alert('Repository Branches', branches)
	})

	win.status_bar('Git Studio Pro  •  Native Git CLI Integration  •  Branch: ' + branch)
	win.run()
}
