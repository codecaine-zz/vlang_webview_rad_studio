module main

import os
import time

const cli_names = [
	'api_cli',
	'app_bundler_cli',
	'color_cli',
	'crypto_cli',
	'database_cli',
	'dataconvert_cli',
	'devtools_cli',
	'env_cli',
	'git_cli',
	'json_cli',
	'markdown_cli',
	'network_cli',
	'process_cli',
	'regex_cli',
	'system_cli',
	'watcher_cli',
]

struct CliResult {
	code   int
	stdout string
	stderr string
}

fn run_with_timeout(executable string, args []string, timeout time.Duration) !CliResult {
	mut process := os.new_process(executable)
	process.set_args(args)
	process.set_redirect_stdio()
	process.run()
	deadline := time.now().add(timeout)
	for process.is_alive() && time.now() < deadline {
		time.sleep(10 * time.millisecond)
	}
	if process.is_alive() {
		process.signal_kill()
		process.wait()
		return error('${os.file_name(executable)} ${args.join(' ')} timed out')
	}
	process.wait()
	result := CliResult{
		code: process.code
		stdout: process.stdout_slurp()
		stderr: process.stderr_slurp()
	}
	process.close()
	return result
}

fn assert_terminates_on_signal(executable string, args []string) ! {
	mut process := os.new_process(executable)
	process.set_args(args)
	process.set_redirect_stdio()
	process.run()
	time.sleep(100 * time.millisecond)
	process.signal_term()
	deadline := time.now().add(1 * time.second)
	for process.is_alive() && time.now() < deadline {
		time.sleep(10 * time.millisecond)
	}
	if process.is_alive() {
		process.signal_kill()
		process.wait()
		return error('${os.file_name(executable)} did not terminate after a termination signal')
	}
	process.wait()
	process.close()
}

fn test_all_cli_help_version_and_invalid_flags() {
	project_root := os.dir(os.dir(os.real_path(@FILE)))
	build_dir := os.join_path(os.temp_dir(), 'vlang_gui_cli_test_${os.getpid()}_${time.now().unix_nano()}')
	os.mkdir_all(build_dir) or { panic(err) }
	defer {
		os.rmdir_all(build_dir) or {}
	}
	fixture := os.join_path(build_dir, 'empty_fixture')
	os.write_file(fixture, '') or { panic(err) }
	invalid_cases := {
		'api_cli':         []string{}
		'app_bundler_cli': ['--target', 'plan9']
		'color_cli':       ['--hex', 'not-a-color']
		'crypto_cli':      ['--algo', 'unknown']
		'database_cli':    ['--database', fixture, '--query', 'DELETE FROM records']
		'dataconvert_cli': ['--from', 'xml']
		'devtools_cli':    ['--stats', 'not-a-number']
		'env_cli':         ['unexpected']
		'git_cli':         ['--log', '-1']
		'json_cli':        ['--file', fixture, '{}']
		'markdown_cli':    ['--file', fixture, 'text']
		'network_cli':     ['--ping', ';']
		'process_cli':     ['--top', '0']
		'regex_cli':       []string{}
		'system_cli':      ['unexpected']
		'watcher_cli':     ['--interval', '0']
	}
	sqlite_path := os.find_abs_path_of_executable('sqlite3') or { '' }

	for name in cli_names {
		source := os.join_path(project_root, 'cli_apps', '${name}.v')
		executable := os.join_path(build_dir, name)
		compile := os.execute('${os.quoted_path(@VEXE)} -o ${os.quoted_path(executable)} ${os.quoted_path(source)}')
		assert compile.exit_code == 0, 'failed to compile ${name}: ${compile.output}'

		help := run_with_timeout(executable, ['--help'], 2 * time.second) or { panic(err) }
		assert help.code == 0, '${name} --help exited ${help.code}: ${help.stderr}'
		assert help.stderr == '', '${name} --help wrote to stderr: ${help.stderr}'
		assert help.stdout.contains('Usage:'), '${name} --help did not print usage'

		version := run_with_timeout(executable, ['--version'], 2 * time.second) or { panic(err) }
		assert version.code == 0, '${name} --version exited ${version.code}: ${version.stderr}'
		assert version.stderr == '', '${name} --version wrote to stderr: ${version.stderr}'
		assert version.stdout.contains('2.0.0'), '${name} --version did not print its version'

		invalid := run_with_timeout(executable, ['--definitely-invalid'], 2 * time.second) or {
			panic(err)
		}
		assert invalid.code == 2, '${name} invalid flag exited ${invalid.code}'
		assert invalid.stdout == '', '${name} invalid flag wrote to stdout: ${invalid.stdout}'
		assert invalid.stderr.contains('Unknown flag'), '${name} invalid flag did not explain the error'

		bad_args := invalid_cases[name]
		bad_input := run_with_timeout(executable, bad_args, 2 * time.second) or { panic(err) }
		assert bad_input.code == 2, '${name} invalid input exited ${bad_input.code}'
		assert bad_input.stdout == '', '${name} invalid input wrote to stdout: ${bad_input.stdout}'
		assert bad_input.stderr != '', '${name} invalid input did not explain the error'

		if name == 'watcher_cli' {
			assert_terminates_on_signal(executable, ['--path', fixture, '--interval', '50']) or {
				panic(err)
			}
		}
		if name == 'database_cli' && sqlite_path != '' {
			read_query := run_with_timeout(executable, [
				'--database',
				fixture,
				'--query',
				"SELECT 'created' AS status",
			], 2 * time.second) or { panic(err) }
			assert read_query.code == 0, 'database_cli rejected a valid read-only query: ${read_query.stderr}'
			assert read_query.stdout.contains('created')
		}
	}
}
