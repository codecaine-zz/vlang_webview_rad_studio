module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('env_cli')
	fp.version('2.0.0')
	fp.description('Environment Variables Inspector & Manager CLI')
	fp.skip_executable()

	get_key := fp.string('get', `g`, '', 'Get value of specific environment variable')
	filter := fp.string('filter', `f`, '', 'Filter environment variables by name')
	json_out := fp.bool('json', `j`, false, 'Output environment variables in JSON format')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
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
		println('{')
		mut first := true
		for k in keys {
			if filter == '' || k.to_lower().contains(filter.to_lower()) {
				if !first { println(',') }
				v := all_vars[k].replace('"', '\\"').replace('\n', '\\n')
				print('  "${k}": "${v}"')
				first = false
			}
		}
		println('\n}')
		return
	}

	println('====================================================================')
	println('🌍 ENVIRONMENT VARIABLES INSPECTOR')
	println('====================================================================')
	mut count := 0
	for k in keys {
		if filter == '' || k.to_lower().contains(filter.to_lower()) {
			val := all_vars[k]
			display_val := if val.len > 60 { val[..57] + '...' } else { val }
			println('${k:<30} = ${display_val}')
			count++
		}
	}
	println('--------------------------------------------------------------------')
	println('Total Variables: ${count}')
	println('====================================================================')
}
