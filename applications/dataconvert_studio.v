module main

import simplegui
import system
import json2
import os

fn main() {
	mut win := simplegui.new_window(
		title: 'DataConvert Studio Pro Enterprise -- Data Format Transformation Workstation'
		width: 1180
		height: 890
		theme: 'catppuccin'
	)

	win.heading('🔄 DataConvert Studio Pro Enterprise')
	win.subheading('Multi-Format Data Converter: JSON, CSV, SQL INSERT, Key-Value Pairs, HTML Tables & Base64')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Conversion Status', 'Ready', 'Standby')
	win.kpi_card_named('kpi_records', 'Records Processed', '3 Records', 'Array')
	win.kpi_card_named('kpi_input_size', 'Input Size', '180 B', 'Source')
	win.kpi_card_named('kpi_output_size', 'Output Size', '0 B', 'Result')
	win.row_end()

	sample_json := '[\n  {"id": 1, "sku": "PRD-001", "name": "Mechanical Keyboard", "category": "Hardware", "price": 129.99},\n  {"id": 2, "sku": "PRD-002", "name": "Ergonomic Mouse", "category": "Hardware", "price": 79.50},\n  {"id": 3, "sku": "PRD-003", "name": "USB-C Display Cable", "category": "Accessories", "price": 19.95}\n]'

	// Editor Workspace Box
	win.box_start('🔄 Data Transformation Workspace')
	win.row_start()
	win.subheading('Source Data Input')
	win.subheading('Converted Output Data')
	win.row_end()

	win.row_start()
	win.textarea_named('data_input', 'Enter raw data to convert...', sample_json, fn (w &simplegui.SimpleWindow, _ string) {})
	win.textarea_named('data_output', 'Converted representation will display here...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	// Conversion Actions Row
	win.row_start()
	win.button('📊 JSON Array ➔ CSV', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('data_input')
		parsed := json2.decode[json2.Any](raw) or {
			w.toast_error('Invalid JSON: ${err}')
			return
		}
		if parsed is []json2.Any {
			mut headers := []string{}
			mut csv_lines := []string{}
			if parsed.len > 0 && parsed[0] is map[string]json2.Any {
				first_map := parsed[0] as map[string]json2.Any
				for k, _ in first_map {
					headers << k
				}
				csv_lines << headers.join(',')
			}
			for item in parsed {
				if item is map[string]json2.Any {
					mut row := []string{}
					for h in headers {
						val := item[h] or { json2.Any('') }
						row << val.json_str()
					}
					csv_lines << row.join(',')
				}
			}
			result := csv_lines.join('\n')
			w.set_value('data_output', result)
			w.set_kpi('kpi_status', 'JSON ➔ CSV Done', 'Success')
			w.set_kpi('kpi_records', '${parsed.len} Records', 'Rows')
			w.set_kpi('kpi_input_size', system.format_bytes(u64(raw.len)), 'Input')
			w.set_kpi('kpi_output_size', system.format_bytes(u64(result.len)), 'CSV')
			w.toast_success('Converted ${parsed.len} JSON records to CSV!')
		} else {
			w.toast_warning('JSON input must be an array of objects.')
		}
	})

	win.button('📄 CSV ➔ JSON Array', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('data_input')
		lines := raw.split_into_lines().filter(it.trim_space() != '')
		if lines.len < 2 {
			w.toast_warning('CSV must have at least a header row and 1 data row.')
			return
		}
		headers := lines[0].split(',').map(it.trim_space().trim('"'))
		mut result_objs := []string{}
		for i in 1 .. lines.len {
			cols := lines[i].split(',')
			mut parts := []string{}
			for j in 0 .. headers.len {
				val := if j < cols.len { cols[j].trim_space().trim('"') } else { '' }
				parts << '  ${json2.encode(headers[j])}: ${json2.encode(val)}'
			}
			result_objs << '{\n' + parts.join(',\n') + '\n}'
		}
		out_json := '[\n  ' + result_objs.join(',\n  ').replace('\n', '\n  ') + '\n]'
		w.set_value('data_output', out_json)
		w.set_kpi('kpi_status', 'CSV ➔ JSON Done', 'Success')
		w.set_kpi('kpi_records', '${lines.len - 1} Records', 'Parsed')
		w.set_kpi('kpi_input_size', system.format_bytes(u64(raw.len)), 'Input')
		w.set_kpi('kpi_output_size', system.format_bytes(u64(out_json.len)), 'JSON')
		w.toast_success('Converted ${lines.len - 1} CSV rows to JSON array!')
	})

	win.button('🗄️ JSON ➔ SQL INSERT', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('data_input')
		parsed := json2.decode[json2.Any](raw) or {
			w.toast_error('Invalid JSON: ${err}')
			return
		}
		if parsed is []json2.Any {
			mut sql_statements := []string{}
			for item in parsed {
				if item is map[string]json2.Any {
					mut cols := []string{}
					mut vals := []string{}
					for k, v in item {
						cols << k
						vals << match v {
							string { "'${v.replace("'", "''")}'" }
							int, i64, f64 { v.str() }
							bool { if v { '1' } else { '0' } }
							else { "'${v.json_str()}'" }
						}
					}
					sql_statements << 'INSERT INTO records (${cols.join(', ')}) VALUES (${vals.join(', ')});'
				}
			}
			result := sql_statements.join('\n')
			w.set_value('data_output', result)
			w.set_kpi('kpi_status', 'SQL INSERT Done', 'Generated')
			w.set_kpi('kpi_records', '${parsed.len} Rows', 'SQL')
			w.set_kpi('kpi_output_size', system.format_bytes(u64(result.len)), 'SQL')
			w.toast_success('Generated ${parsed.len} SQL INSERT statements!')
		} else {
			w.toast_warning('Input must be a JSON array of objects.')
		}
	})

	win.button('🌐 CSV ➔ HTML Table', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('data_input')
		lines := raw.split_into_lines().filter(it.trim_space() != '')
		if lines.len == 0 {
			w.toast_warning('Enter CSV content to convert.')
			return
		}
		mut html := '<table class="table">\n  <thead>\n    <tr>\n'
		headers := lines[0].split(',')
		for h in headers {
			html += '      <th>' + h.trim_space().trim('"') + '</th>\n'
		}
		html += '    </tr>\n  </thead>\n  <tbody>\n'
		for i in 1 .. lines.len {
			html += '    <tr>\n'
			for col in lines[i].split(',') {
				html += '      <td>' + col.trim_space().trim('"') + '</td>\n'
			}
			html += '    </tr>\n'
		}
		html += '  </tbody>\n</table>'
		w.set_value('data_output', html)
		w.set_kpi('kpi_status', 'HTML Table Done', 'Markup')
		w.toast_success('Generated HTML <table> markup!')
	})
	win.row_end()

	// File Actions Row
	win.row_start()
	win.button('📂 Load Source File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Load Data File', 'json,csv,txt,sql')
		if path != '' {
			content := os.read_file(path) or {
				w.toast_error('Could not read file: ${err}')
				return
			}
			w.set_value('data_input', content)
			w.set_kpi('kpi_input_size', system.format_bytes(u64(content.len)), 'Loaded')
			w.toast_success('Loaded file: ' + path)
		}
	})
	win.button('💾 Save Converted Output...', fn (w &simplegui.SimpleWindow, _ string) {
		out := w.get('data_output')
		if out.trim_space() == '' {
			w.toast_warning('Output buffer is empty.')
			return
		}
		path := w.save_file_dialog('Save Output File', 'converted_data.txt')
		if path != '' {
			os.write_file(path, out) or {
				w.toast_error('Failed to save file: ${err}')
				return
			}
			w.toast_success('Saved converted output to: ' + path)
		}
	})
	win.button('📋 Copy Output to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		out := w.get('data_output')
		if out == '' {
			w.toast_warning('Output is empty.')
			return
		}
		system.set_clipboard_text(out)
		w.toast_success('Output copied to clipboard!')
	})
	win.button('🔄 Swap Input & Output', fn (w &simplegui.SimpleWindow, _ string) {
		inp := w.get('data_input')
		out := w.get('data_output')
		w.set_value('data_input', out)
		w.set_value('data_output', inp)
		w.toast_info('Swapped input and output buffers')
	})
	win.row_end()
	win.box_end()

	win.status_bar('DataConvert Studio Pro Enterprise  •  High-Efficiency Parsing  •  Ready')
	win.run()
}
