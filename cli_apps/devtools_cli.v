module main

import flag
import os
import time
import rand
import system

fn generate_uuid() string {
	mut b := []u8{len: 16}
	for i in 0 .. 16 {
		b[i] = u8(rand.intn(256) or { 0 })
	}
	b[6] = (b[6] & 0x0f) | 0x40 // version 4
	b[8] = (b[8] & 0x3f) | 0x80 // variant
	return '${b[0..4].hex()}-${b[4..6].hex()}-${b[6..8].hex()}-${b[8..10].hex()}-${b[10..16].hex()}'
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('devtools_cli')
	fp.version('2.0.0')
	fp.description('Omnitool Developer CLI: UUIDs, Timestamps, String Utilities & Stats')
	fp.skip_executable()

	gen_uuid := fp.bool('uuid', `u`, false, 'Generate a random UUID v4')
	show_time := fp.bool('timestamp', `t`, false, 'Show current Unix epoch timestamp')
	do_slug := fp.bool('slug', `s`, false, 'Slugify input text')
	do_title := fp.bool('title', `T`, false, 'Convert input text to Title Case')
	do_reverse := fp.bool('reverse', `r`, false, 'Reverse input text')
	do_words := fp.bool('words', `w`, false, 'Count words in input text')
	do_stats := fp.bool('stats', `S`, false, 'Calculate statistics on comma-separated numbers')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	input := if additional_args.len > 0 { additional_args.join(' ') } else { '' }

	if gen_uuid {
		println(generate_uuid())
		return
	}

	if show_time {
		now := time.now()
		println('Unix Timestamp: ${now.unix()}')
		println('UTC String:     ${now.utc_string()}')
		return
	}

	if do_slug {
		if input == '' { eprintln('Error: Input text required'); exit(1) }
		println(system.slugify(input))
		return
	}

	if do_title {
		if input == '' { eprintln('Error: Input text required'); exit(1) }
		println(system.title_case(input))
		return
	}

	if do_reverse {
		if input == '' { eprintln('Error: Input text required'); exit(1) }
		println(system.reverse_string(input))
		return
	}

	if do_words {
		if input == '' { eprintln('Error: Input text required'); exit(1) }
		println('Word count: ${system.word_count(input)}')
		return
	}

	if do_stats {
		if input == '' { eprintln('Error: Provide numbers like: devtools_cli -S 10,20,30,40'); exit(1) }
		mut nums := []f64{}
		for item in input.split(',') {
			trimmed := item.trim_space()
			if trimmed != '' {
				nums << trimmed.f64()
			}
		}
		st := system.calculate_stats(nums) or {
			eprintln('Error: ${err}')
			exit(1)
		}
		println('====================================================================')
		println('📊 STATISTICAL ANALYSIS')
		println('====================================================================')
		println('Count:    ${st.count}')
		println('Sum:      ${st.sum:.2f}')
		println('Min:      ${st.min:.2f}')
		println('Max:      ${st.max:.2f}')
		println('Mean:     ${st.mean:.2f}')
		println('Median:   ${st.median:.2f}')
		println('Variance: ${st.variance:.4f}')
		println('StdDev:   ${st.std_dev:.4f}')
		println('====================================================================')
		return
	}

	println(fp.usage())
}
