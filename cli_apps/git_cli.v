module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('git_cli')
	fp.version('2.0.0')
	fp.description('Visual Git Workstation CLI: Status, Branches, Diffs & Log')
	fp.skip_executable()

	show_status := fp.bool('status', `s`, false, 'Show git status short')
	show_branch := fp.bool('branch', `b`, false, 'List local and remote branches')
	show_log := fp.int('log', `l`, 0, 'Show last N commit logs')
	show_diff := fp.bool('diff', `d`, false, 'Show git diff')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	println('====================================================================')
	println('🌿 GIT WORKBENCH CLI (vlang)')
	println('====================================================================')

	if show_branch {
		out, _ := system.exec('git branch -a')
		println('Branches:\n${out}')
		return
	}

	if show_log > 0 {
		out, _ := system.exec('git log -n ${show_log} --oneline --graph --decorate')
		println('Recent ${show_log} Commits:\n${out}')
		return
	}

	if show_diff {
		out, _ := system.exec('git diff')
		println('Working Tree Diff:\n${out}')
		return
	}

	// Default: status + current branch + last commit
	branch, _ := system.exec('git rev-parse --abbrev-ref HEAD')
	last_commit, _ := system.exec('git log -1 --oneline')
	status_out, _ := system.exec('git status -s')

	println('Branch:      ${branch}')
	println('Last Commit: ${last_commit}')
	println('--------------------------------------------------------------------')
	println('Changed Files:')
	if status_out.trim_space() == '' {
		println('  (working tree clean)')
	} else {
		println(status_out)
	}
	println('====================================================================')
}
