module main

import simplegui
import json2

fn main() {
	mut win := simplegui.new_window(
		title: 'DataConvert Studio Pro -- Data Format Transformation Workstation'
		width: 1100
		height: 820
		theme: 'catppuccin'
	)

	win.heading('🔄 DataConvert Studio Pro')
	win.label('High-Speed Multi-Format Data Converter: JSON, CSV, Key-Value Pairs, Arrays & Structs')

	sample_json := '[\n  {"id": 1, "name": "Apple", "price": 1.20},\n  {"id": 2, "name": "Banana", "price": 0.50},\n  {"id": 3, "name": "Orange", "price": 0.85}\n]'

	win.subheading('Source Data Input')
	win.textarea('Input data to convert...', sample_json, fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Converted Output')
	win.textarea('Converted representation will display here...', 'Click a conversion button below...', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Conversion Actions')

	win.button('📊 Convert JSON Array to CSV', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get_value('txt_1')
		parsed := json2.decode[json2.Any](raw) or {
			w.alert('Error', 'Invalid JSON input: ${err}')
			return
		}
		if parsed is []json2.Any {
			mut csv_lines := []string{}
			mut headers := []string{}
			if parsed.len > 0 {
				first := parsed[0]
				if first is map[string]json2.Any {
					for k, _ in first {
						headers << k
					}
					csv_lines << headers.join(',')
				}
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
			w.set_value('txt_2', csv_lines.join('\n'))
			w.notification('Conversion Success', 'Converted ${parsed.len} records to CSV')
		} else {
			w.alert('Format Notice', 'Input must be a JSON array of objects')
		}
	})

	win.button('📄 Convert CSV to JSON Lines', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get_value('txt_1')
		lines := raw.split_into_lines()
		if lines.len < 2 {
			w.alert('Notice', 'CSV must have at least header and one row')
			return
		}
		headers := lines[0].split(',').map(it.trim_space().trim('"'))
		mut result := []string{}
		for i in 1 .. lines.len {
			if lines[i].trim_space() == '' {
				continue
			}
			cols := lines[i].split(',')
			mut obj_parts := []string{}
			for j in 0 .. headers.len {
				val := if j < cols.len { cols[j].trim_space().trim('"') } else { '' }
				obj_parts << '${json2.encode(headers[j])}: ${json2.encode(val)}'
			}
			result << '{ ${obj_parts.join(', ')} }'
		}
		w.set_value('txt_2', '[\n  ' + result.join(',\n  ') + '\n]')
		w.notification('CSV Converted', 'Converted CSV to JSON')
	})

	win.status_bar('DataConvert Studio Pro  •  High-Efficiency Parsing  •  Active')
	win.run()
}
