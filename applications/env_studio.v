module main

import simplegui
import system
import os

fn refresh_env_table(w &simplegui.SimpleWindow, filter_text string) {
	env_map := system.get_all_env()
	lower_filter := filter_text.to_lower().trim_space()

	mut keys := env_map.keys()
	keys.sort()

	mut rows := [][]string{}
	for k in keys {
		v := env_map[k]
		if lower_filter == '' || k.to_lower().contains(lower_filter) || v.to_lower().contains(lower_filter) {
			display_val := if v.len > 50 { v[..47] + '...' } else { v }
			rows << [k, display_val, '${v.len} chars']
		}
	}

	if rows.len == 0 {
		rows << ['(no matches)', 'No environment variables matching "${filter_text}"', '-']
	}

	path_val := system.get_env('PATH')
	path_dirs := path_val.split(os.path_delimiter).filter(it.trim_space() != '')

	w.set_kpi('kpi_total', '${env_map.len} Variables', 'Process Context')
	w.set_kpi('kpi_filtered', '${rows.len} Matches', if lower_filter != '' { 'Filtered' } else { 'All' })
	w.set_kpi('kpi_path_dirs', '${path_dirs.len} Paths', 'PATH variable')
	w.set_kpi('kpi_user', system.get_env('USER'), system.get_user_home_dir())

	w.set_table_rows('env_table', rows)
	w.set_status('Environment variables synced • ${env_map.len} active variables • ${rows.len} displayed')
}

fn export_env_file_format(env_map map[string]string) string {
	mut lines := []string{}
	mut keys := env_map.keys()
	keys.sort()
	for k in keys {
		v := env_map[k]
		escaped := v.replace('\n', '\\n')
		lines << '${k}="${escaped}"'
	}
	return lines.join('\n')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'Env Studio Pro Enterprise -- Environment Variables Workbench'
		width: 1180
		height: 890
		theme: 'kanagawa'
	)

	win.heading('🌱 Env Studio Pro Enterprise')
	win.subheading('Operating System Environment Variables Explorer, Process Context Auditor, PATH Inspector & .env Manager')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_total', 'Active Variables', 'Loading...', 'Process Context')
	win.kpi_card_named('kpi_filtered', 'Filtered Count', '0 Matches', 'Filter')
	win.kpi_card_named('kpi_path_dirs', 'PATH Directories', '0 Paths', 'System PATH')
	win.kpi_card_named('kpi_user', 'Active User', '...', 'Home')
	win.row_end()

	// Search & Add Variable Box
	win.box_start('🔍 Search & Runtime Variable Management')
	win.row_start()
	win.input_named('env_search', 'Filter environment variables by key or value...', '', fn (w &simplegui.SimpleWindow, val string) {
		refresh_env_table(w, val)
	})
	win.button('🔄 Refresh Variables', fn (w &simplegui.SimpleWindow, _ string) {
		filter_val := w.get('env_search')
		refresh_env_table(w, filter_val)
		w.toast_success('Environment variables refreshed!')
	})
	win.row_end()

	win.row_start()
	win.input_named('new_key', 'Variable Name (e.g. RAD_ENV, API_KEY)...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input_named('new_val', 'Variable Value (e.g. production, secret_123)...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('💾 Set / Update Variable', fn (w &simplegui.SimpleWindow, _ string) {
		k := w.get('new_key').trim_space()
		v := w.get('new_val').trim_space()
		if k == '' {
			w.toast_warning('Please enter a variable key.')
			return
		}
		os.setenv(k, v, true)
		w.toast_success('Set ${k}="${v}" in runtime process')
		w.set_value('new_key', '')
		w.set_value('new_val', '')
		refresh_env_table(w, w.get('env_search'))
	})
	win.row_end()

	// Export / Import Controls Row
	win.row_start()
	win.button('💾 Export to .env File...', fn (w &simplegui.SimpleWindow, _ string) {
		save_path := w.save_file_dialog('Export Environment to .env', '.env')
		if save_path != '' {
			env_map := system.get_all_env()
			content := export_env_file_format(env_map)
			os.write_file(save_path, content) or {
				w.toast_error('Failed to export .env: ${err}')
				return
			}
			w.toast_success('Exported environment to: ' + save_path)
		}
	})
	win.button('📂 Load from .env File...', fn (w &simplegui.SimpleWindow, _ string) {
		open_path := w.open_file_dialog('Select .env File', 'env,txt')
		if open_path != '' {
			lines := os.read_lines(open_path) or {
				w.toast_error('Failed to read .env: ${err}')
				return
			}
			mut count := 0
			for line in lines {
				trimmed := line.trim_space()
				if trimmed == '' || trimmed.starts_with('#') {
					continue
				}
				idx := trimmed.index('=') or { continue }
				key := trimmed[..idx].trim_space()
				val := trimmed[idx + 1..].trim_space().trim('"')
				os.setenv(key, val, true)
				count++
			}
			w.toast_success('Imported ${count} variables from: ' + open_path)
			refresh_env_table(w, w.get('env_search'))
		}
	})
	win.button('📋 Copy All as .env', fn (w &simplegui.SimpleWindow, _ string) {
		env_map := system.get_all_env()
		content := export_env_file_format(env_map)
		system.set_clipboard_text(content)
		w.toast_success('Environment variables copied as .env to clipboard!')
	})
	win.row_end()
	win.box_end()

	// Environment Variables Table Box
	win.box_start('📋 Process Environment Context Table')
	headers := ['Variable Key', 'Value Content', 'Length']
	win.table_named('env_table', headers, [['Loading...', 'Detecting...', '-']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Selected variable row #${idx}')
	})
	win.box_end()

	// PATH Inspector Box
	win.box_start('🗂️ System PATH Directories Inspector')
	path_val := system.get_env('PATH')
	path_dirs := path_val.split(os.path_delimiter).filter(it.trim_space() != '')
	path_headers := ['Path Priority', 'Filesystem Directory', 'Disk Existence']
	mut path_rows := [][]string{}
	for i, d in path_dirs {
		exists := if os.is_dir(d) { '✅ Valid Directory' } else { '⚠️ Missing from Disk' }
		path_rows << ['#${i + 1}', d, exists]
	}
	if path_rows.len == 0 {
		path_rows << ['-', 'PATH is empty', '-']
	}
	win.table_named('path_table', path_headers, path_rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Env Studio Pro Enterprise  •  POSIX Environment  •  Ready')

	// Initial populate
	refresh_env_table(win, '')

	win.run()
}
