module main

import simplegui
import system

fn refresh_git_state(w &simplegui.SimpleWindow) {
	branch := system.exec_or('git rev-parse --abbrev-ref HEAD', 'main').trim_space()
	status_s := system.exec_or('git status -s', '').trim_space()

	mut unstaged_count := 0
	mut staged_count := 0
	mut status_rows := [][]string{}

	if status_s != '' {
		for line in status_s.split_into_lines() {
			if line.len < 3 {
				continue
			}
			x := line[0..1]
			y := line[1..2]
			file := line[3..].trim_space()

			mut state := 'Untracked'
			if x != ' ' && x != '?' {
				staged_count++
				state = 'Staged (${x})'
			}
			if y != ' ' && y != '?' {
				unstaged_count++
				state = if state.starts_with('Staged') { 'Partially Staged' } else { 'Modified (${y})' }
			}
			if x == '?' && y == '?' {
				unstaged_count++
				state = 'Untracked'
			}
			status_rows << [x + y, file, state]
		}
	}

	if status_rows.len == 0 {
		status_rows << ['--', 'Working tree clean', 'Clean']
	}

	commit_count := system.exec_or('git rev-list --count HEAD', '0').trim_space()

	w.set_kpi('kpi_branch', branch, 'Git Repository')
	w.set_kpi('kpi_unstaged', '${unstaged_count} Files', if unstaged_count > 0 { 'Needs action' } else { 'Clean' })
	w.set_kpi('kpi_staged', '${staged_count} Files', if staged_count > 0 { 'Ready to commit' } else { 'Empty index' })
	w.set_kpi('kpi_commits', '${commit_count} Commits', 'HEAD')

	w.set_table_rows('git_status_table', status_rows)

	// Refresh commit log
	log_raw := system.exec_or('git log -n 12 --pretty=format:"%h|%an|%s|%cr"', '')
	mut log_rows := [][]string{}
	for line in log_raw.split_into_lines() {
		parts := line.split('|')
		if parts.len >= 4 {
			log_rows << [parts[0], parts[1], parts[2], parts[3]]
		}
	}
	if log_rows.len == 0 {
		log_rows << ['-', 'Git', 'No commits recorded', 'Standby']
	}
	w.set_table_rows('git_commit_table', log_rows)

	// Update Diff viewer
	diff_raw := system.exec_or('git diff HEAD', '')
	if diff_raw.trim_space() == '' {
		w.set_value('git_diff_view', 'No modified lines in working tree (clean).')
	} else {
		w.set_value('git_diff_view', diff_raw)
	}

	w.set_status('Git repository synchronized • Branch: ${branch} • ${unstaged_count} unstaged • ${staged_count} staged')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Git Studio Pro Enterprise -- Visual Git Version Control Workbench'
		width: 1180
		height: 890
		theme: 'github_dark'
	)

	win.heading('🐙 Git Studio Pro Enterprise')
	win.subheading('Visual Git Version Control Workbench: Status, Staging, Diffs, Commit Logs & Branch Operations')
	win.divider()

	// Top Telemetry KPI Cards
	win.row_start()
	win.kpi_card_named('kpi_branch', 'Active Branch', 'main', 'Git Repository')
	win.kpi_card_named('kpi_unstaged', 'Unstaged Files', '0 Files', 'Clean')
	win.kpi_card_named('kpi_staged', 'Staged Files', '0 Files', 'Empty index')
	win.kpi_card_named('kpi_commits', 'Commit Count', '0 Commits', 'HEAD')
	win.row_end()

	// Operations Toolbar Box
	win.box_start('⚡ Git Workstation Controls & Staging Pipeline')
	win.row_start()
	win.button('🔄 Refresh Status', fn (w &simplegui.SimpleWindow, _ string) {
		refresh_git_state(w)
		w.toast_success('Repository status refreshed')
	})
	win.button('➕ Stage All Changes (git add -A)', fn (w &simplegui.SimpleWindow, _ string) {
		res := system.exec_safe('git', ['add', '-A'])
		if res.exit_code == 0 {
			w.toast_success('All modified and untracked files staged!')
		} else {
			w.toast_error('Failed to stage files: ' + res.output)
		}
		refresh_git_state(w)
	})
	win.button('➖ Unstage All (git reset)', fn (w &simplegui.SimpleWindow, _ string) {
		res := system.exec_safe('git', ['reset', 'HEAD'])
		if res.exit_code == 0 {
			w.toast_warning('Unstaged all staged files')
		} else {
			w.toast_error('Unstage error: ' + res.output)
		}
		refresh_git_state(w)
	})
	win.button('📦 Stash Changes (git stash)', fn (w &simplegui.SimpleWindow, _ string) {
		res := system.exec_safe('git', ['stash'])
		w.toast_info('Git stash: ' + res.output.trim_space())
		refresh_git_state(w)
	})
	win.button('⬇️ Git Pull', fn (w &simplegui.SimpleWindow, _ string) {
		res := system.exec_safe('git', ['pull'])
		if res.exit_code == 0 {
			w.toast_success('Git pull complete: ' + res.output.trim_space())
		} else {
			w.toast_warning('Git pull: ' + res.output.trim_space())
		}
		refresh_git_state(w)
	})
	win.button('⬆️ Git Push', fn (w &simplegui.SimpleWindow, _ string) {
		res := system.exec_safe('git', ['push'])
		if res.exit_code == 0 {
			w.toast_success('Git push succeeded!')
		} else {
			w.toast_warning('Git push result: ' + res.output.trim_space())
		}
		refresh_git_state(w)
	})
	win.row_end()

	// Commit Section
	win.row_start()
	win.input_named('commit_msg', 'Enter commit message...', 'feat: update application workbench', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🚀 Commit Staged Changes', fn (w &simplegui.SimpleWindow, _ string) {
		msg := w.get('commit_msg').trim_space()
		if msg == '' {
			w.toast_warning('Please write a commit message.')
			return
		}
		res := system.exec_safe('git', ['commit', '-m', msg])
		if res.exit_code == 0 {
			w.toast_success('Commit created: ' + res.output.trim_space())
			w.set_value('commit_msg', '')
		} else {
			w.toast_error('Commit failed: ' + res.output.trim_space())
		}
		refresh_git_state(w)
	})
	win.row_end()
	win.box_end()

	// Dual-Pane: Working Tree Status & Diff Inspector
	win.box_start('📋 Working Tree Status & Unified Diff Inspector')
	win.subheading('Modified & Untracked Files')
	status_headers := ['Flag', 'File Path', 'Staging Status']
	win.table_named('git_status_table', status_headers, [['--', 'Loading status...', 'Pending']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspecting file row #${idx}')
	})

	win.subheading('Unified Diff (git diff HEAD)')
	win.raw_html('<style>
		#git_diff_view {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 170px;
			min-height: 170px;
			background: #0d1117;
			color: #58a6ff;
			border: 1px solid #30363d;
			border-radius: 6px;
			line-height: 1.45;
			padding: 10px;
		}
	</style>')
	win.textarea_named('git_diff_view', 'Git diff view...', 'Loading diff...', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	// Commit History Box
	win.box_start('📜 Recent Commit History (git log)')
	commit_headers := ['Hash', 'Author', 'Commit Message', 'Date']
	win.table_named('git_commit_table', commit_headers, [['-', 'Loading...', 'Fetching history', '-']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Viewing commit #${idx}')
	})
	win.box_end()

	win.status_bar('Git Studio Pro Enterprise  •  Native Git CLI Engine  •  Ready')

	// Initial population on launch
	refresh_git_state(win)

	win.run()
}
