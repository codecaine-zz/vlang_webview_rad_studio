module main

import flag
import os
import regex

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('regex_cli')
	fp.version('2.0.0')
	fp.description('Regular Expression Tester, Matcher & Replacement CLI')
	fp.skip_executable()

	pattern := fp.string('pattern', `p`, '', 'Regular expression pattern')
	replace_str := fp.string('replace', `r`, '', 'Replacement text (optional)')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	if pattern == '' {
		eprintln('Error: --pattern (-p) is required')
		println(fp.usage())
		exit(1)
	}

	text := if additional_args.len > 0 { additional_args.join(' ') } else { 'The quick brown fox jumps over 42 lazy dogs' }

	mut re := regex.regex_opt(pattern) or {
		eprintln('Invalid regex: ${err}')
		exit(1)
	}

	println('====================================================================')
	println('🔍 REGEX CLI TESTER')
	println('====================================================================')
	println('Pattern: ${pattern}')
	println('Target:  ${text}')
	println('--------------------------------------------------------------------')

	if replace_str != '' {
		replaced := re.replace(text, replace_str)
		println('Replaced result:')
		println(replaced)
	} else {
		matches := re.find_all_str(text)
		println('Matches found: ${matches.len}')
		for i, m in matches {
			println('  [${i + 1}] ${m}')
		}
	}
	println('====================================================================')
}
