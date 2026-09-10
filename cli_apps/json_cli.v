module main

import flag
import os
import x.json2

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('json_cli')
	fp.version('2.0.0')
	fp.description('Enterprise JSON Inspector, Validator & Formatter')
	fp.skip_executable()

	file_path := fp.string('file', `f`, '', 'Input JSON file path')
	minify := fp.bool('minify', `m`, false, 'Minify JSON output')
	validate_only := fp.bool('validate', `v`, false, 'Validate JSON without printing body')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	mut json_str := ''
	if file_path != '' {
		json_str = os.read_file(file_path) or {
			eprintln('Error: Unable to read file "${file_path}": ${err}')
			exit(1)
		}
	} else if additional_args.len > 0 {
		json_str = additional_args.join(' ')
	} else {
		json_str = '{"name": "RAD Studio", "platform": "vlang", "version": 2.0, "active": true}'
	}

	raw := json2.decode[json2.Any](json_str) or {
		eprintln('❌ Invalid JSON syntax: ${err}')
		exit(1)
	}

	if validate_only {
		println('✅ JSON is valid!')
		return
	}

	if minify {
		println(json2.encode[json2.Any](raw))
	} else {
		println(json2.encode[json2.Any](raw, prettify: true))
	}
}
