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

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}
	if show_log < 0 {
		eprintln('Error: --log cannot be negative')
		exit(2)
	}
	mode_count := int(show_status) + int(show_branch) + int(show_log > 0) + int(show_diff)
	if mode_count > 1 {
		eprintln('Error: Git operation flags are mutually exclusive')
		exit(2)
	}

	println('====================================================================')
	println('🌿 GIT WORKBENCH CLI (vlang)')
	println('====================================================================')

	if show_branch {
		res := system.exec_safe('git', ['branch', '-a'])
		if res.exit_code != 0 {
			eprintln('Error: git branch failed: ${res.output.trim_space()}')
			exit(1)
		}
		out := res.output.trim_space()
		println('Branches:\n${out}')
		return
	}

	if show_log > 0 {
		res := system.exec_safe('git', ['log', '-n', show_log.str(), '--oneline', '--graph',
			'--decorate'])
		if res.exit_code != 0 {
			eprintln('Error: git log failed: ${res.output.trim_space()}')
			exit(1)
		}
		out := res.output.trim_space()
		println('Recent ${show_log} Commits:\n${out}')
		return
	}

	if show_diff {
		res := system.exec_safe('git', ['diff'])
		if res.exit_code != 0 {
			eprintln('Error: git diff failed: ${res.output.trim_space()}')
			exit(1)
		}
		out := res.output.trim_space()
		println('Working Tree Diff:\n${out}')
		return
	}

	// Default: status + current branch + last commit
	branch_res := system.exec_safe('git', ['rev-parse', '--abbrev-ref', 'HEAD'])
	last_commit_res := system.exec_safe('git', ['log', '-1', '--oneline'])
	status_res := system.exec_safe('git', ['status', '-s'])
	if branch_res.exit_code != 0 || last_commit_res.exit_code != 0 || status_res.exit_code != 0 {
		eprintln('Error: Unable to inspect the current Git repository')
		exit(1)
	}
	branch := branch_res.output.trim_space()
	last_commit := last_commit_res.output.trim_space()
	status_out := status_res.output.trim_space()

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
