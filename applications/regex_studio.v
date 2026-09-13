module main

import simplegui
import system
import regex

fn test_and_evaluate_regex(w &simplegui.SimpleWindow) {
	pat := w.get('regex_pat').trim_space()
	txt := w.get('regex_text')

	if pat == '' {
		w.set_kpi('kpi_status', 'Empty Pattern', 'Input needed')
		w.set_kpi('kpi_matches', '0 Matches', 'Standby')
		w.set_kpi('kpi_groups', '0 Groups', 'None')
		w.set_kpi('kpi_chars', '${txt.len} Chars', 'Source text')
		w.set_table_rows('regex_table', [['--', 'Enter pattern', '--', '--']])
		return
	}

	mut re := regex.regex_opt(pat) or {
		w.set_kpi('kpi_status', 'Compile Error', 'Invalid syntax')
		w.set_kpi('kpi_matches', '0 Matches', 'Error')
		w.set_kpi('kpi_groups', '0 Groups', 'Error')
		w.set_table_rows('regex_table', [['Error', '${err}', '-', '-']])
		w.set_status('❌ Regex Syntax Error: ${err}')
		w.toast_error('Regex syntax error: ${err}')
		return
	}

	w.set_kpi('kpi_status', 'Compiled OK', 'Valid Pattern')
	w.set_kpi('kpi_chars', '${txt.len} Chars', 'Input text')

	// Execute matching
	mut rows := [][]string{}
	mut match_count := 0

	// Find all non-overlapping matches
	mut start_pos := 0
	for start_pos < txt.len {
		mut re_iter := regex.regex_opt(pat) or { break }
		sub := txt[start_pos..]
		if re_iter.matches_string(sub) {
			match_count++
			start_idx := start_pos + re_iter.groups[0]
			end_idx := start_pos + re_iter.groups[1]

			if start_idx >= txt.len || end_idx > txt.len || end_idx <= start_idx {
				break
			}
			matched_str := txt[start_idx..end_idx]

			mut group_1 := '-'
			if re_iter.groups.len >= 4 {
				g1_start := start_pos + re_iter.groups[2]
				g1_end := start_pos + re_iter.groups[3]
				if g1_start >= 0 && g1_end <= txt.len && g1_end >= g1_start {
					group_1 = txt[g1_start..g1_end]
				}
			}

			rows << ['#${match_count}', matched_str, '[${start_idx}..${end_idx}]', group_1]
			start_pos = end_idx
		} else {
			break
		}
	}

	if rows.len == 0 {
		rows << ['(no match)', 'Pattern did not match any text in input', '-', '-']
	}

	w.set_kpi('kpi_matches', '${match_count} Matches', if match_count > 0 { 'Found' } else { 'None' })
	w.set_kpi('kpi_groups', '${re.group_csave.len} Groups', 'Defined')
	w.set_table_rows('regex_table', rows)
	w.set_status('Regex evaluated • ${match_count} match(es) found • ${txt.len} chars scanned')

	if match_count > 0 {
		w.toast_success('Found ${match_count} match(es)!')
	} else {
		w.toast_warning('No matches found for pattern.')
	}
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Regex Studio Pro Enterprise -- Regular Expression Tester & Debugger'
		width: 1180
		height: 890
		theme: 'cyberpunk'
	)

	win.heading('🎯 Regex Studio Pro Enterprise')
	win.subheading('High-Performance Regular Expression Tester, Pattern Validator, Match Group Inspector & Replacement Workbench')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Regex Engine', 'Ready', 'Standby')
	win.kpi_card_named('kpi_matches', 'Matches Found', '0 Matches', 'Scanning')
	win.kpi_card_named('kpi_groups', 'Capture Groups', '0 Groups', 'Groups')
	win.kpi_card_named('kpi_chars', 'Input Length', '0 Chars', 'Source')
	win.row_end()

	// Pattern Configuration Box
	win.box_start('⚙️ Regular Expression Pattern & Preset Library')
	win.row_start()
	presets := [
		'Preset: Email Address',
		'Preset: Web URL (http/https)',
		'Preset: IPv4 Address',
		'Preset: Date (YYYY-MM-DD)',
		'Preset: UUID v4 Format',
		'Preset: Hex Color Code',
		'Preset: Numbers / Decimals',
	]
	win.dropdown_named('regex_presets', presets, presets[0], fn (w &simplegui.SimpleWindow, val string) {
		pat := match val {
			'Preset: Email Address' { r'(\w+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})' }
			'Preset: Web URL (http/https)' { r'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[a-zA-Z0-9._~:/?#@!$&()*+,;=-]*)?' }
			'Preset: IPv4 Address' { r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' }
			'Preset: Date (YYYY-MM-DD)' { r'\b\d{4}-\d{2}-\d{2}\b' }
			'Preset: UUID v4 Format' { r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}' }
			'Preset: Hex Color Code' { r'#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})' }
			'Preset: Numbers / Decimals' { r'\b\d+(\.\d+)?\b' }
			else { r'\w+' }
		}
		w.set_value('regex_pat', pat)
		w.toast_info('Loaded pattern: ' + val)
		test_and_evaluate_regex(w)
	})
	win.input_named('regex_pat', 'Regular expression pattern...', r'(\w+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})', fn (w &simplegui.SimpleWindow, _ string) {
		test_and_evaluate_regex(w)
	})
	win.button('⚡ Test Pattern', fn (w &simplegui.SimpleWindow, _ string) {
		test_and_evaluate_regex(w)
	})
	win.row_end()
	win.box_end()

	// Test Text Box
	win.box_start('📝 Target Test Text & Replacement Workbench')
	sample_text := 'Contact the engineering team at dev@radstudio.io or sales@enterprise.vlang.org for technical inquiries. Also reach out to support@cloud.net.'
	win.textarea_named('regex_text', 'Enter sample text to match against...', sample_text, fn (w &simplegui.SimpleWindow, _ string) {
		test_and_evaluate_regex(w)
	})

	win.row_start()
	win.input_named('replace_pat', 'Replacement text (e.g. [REDACTED_EMAIL])...', '[REDACTED_EMAIL]', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🔄 Execute Replace All', fn (w &simplegui.SimpleWindow, _ string) {
		pat := w.get('regex_pat').trim_space()
		txt := w.get('regex_text')
		rep := w.get('replace_pat')
		mut re := regex.regex_opt(pat) or {
			w.toast_error('Invalid pattern: ${err}')
			return
		}
		replaced_text := re.replace(txt, rep)
		w.set_value('replace_output', replaced_text)
		w.toast_success('Replaced matches in text!')
	})
	win.button('📋 Copy Replaced Text', fn (w &simplegui.SimpleWindow, _ string) {
		txt := w.get('replace_output')
		if txt == '' {
			w.toast_warning('Replacement output is empty.')
			return
		}
		system.set_clipboard_text(txt)
		w.toast_success('Replaced text copied to clipboard!')
	})
	win.row_end()

	win.textarea_named('replace_output', 'Text with replacements applied will appear here...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	// Matches Table Box
	win.box_start('📊 Detected Pattern Matches & Capture Groups')
	headers := ['Match #', 'Matched Value', 'Span [Start..End]', 'Group 1 Capture']
	win.table_named('regex_table', headers, [['Loading...', 'Scanning...', '-', '-']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspecting match #${idx}')
	})
	win.box_end()

	win.status_bar('Regex Studio Pro Enterprise  •  Native V regex Engine  •  Ready')

	// Initial evaluate
	test_and_evaluate_regex(win)

	win.run()
}
