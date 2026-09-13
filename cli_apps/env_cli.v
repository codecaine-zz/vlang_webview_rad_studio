module main

import flag
import os
import system
import x.json2

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('env_cli')
	fp.version('2.0.0')
	fp.description('Environment Variables Inspector & Manager CLI')
	fp.skip_executable()

	get_key := fp.string('get', `g`, '', 'Get value of specific environment variable')
	filter := fp.string('filter', `f`, '', 'Filter environment variables by name')
	json_out := fp.bool('json', `j`, false, 'Output environment variables in JSON format')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}

	if get_key != '' {
		val := system.get_env(get_key)
		println(val)
		return
	}

	all_vars := system.get_all_env()
	mut keys := all_vars.keys()
	keys.sort()

	if json_out {
		mut filtered := map[string]string{}
		for k in keys {
			if filter == '' || k.to_lower().contains(filter.to_lower()) {
				filtered[k] = all_vars[k]
			}
		}
		println(json2.encode[map[string]string](filtered, prettify: true))
		return
	}

	println('====================================================================')
	println('🌍 ENVIRONMENT VARIABLES INSPECTOR')
	println('====================================================================')
	mut count := 0
	for k in keys {
		if filter == '' || k.to_lower().contains(filter.to_lower()) {
			val := all_vars[k]
			runes := val.runes()
			display_val := if runes.len > 60 { runes[..57].string() + '...' } else { val }
			padded_key := k + ' '.repeat(if k.len < 30 { 30 - k.len } else { 1 })
			println('${padded_key} = ${display_val}')
			count++
		}
	}
	println('--------------------------------------------------------------------')
	println('Total Variables: ${count}')
	println('====================================================================')
}
