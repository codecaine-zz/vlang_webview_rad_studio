module main

import simplegui
import system
import json2
import os
import time

fn analyze_json_document(w &simplegui.SimpleWindow, raw string) {
	if raw.trim_space() == '' {
		w.set_kpi('kpi_status', 'Empty', 'No document')
		w.set_kpi('kpi_size', '0 B', 'Empty')
		w.set_kpi('kpi_keys', '0 Keys', 'No elements')
		w.set_kpi('kpi_speed', '0ms', 'Standby')
		w.set_table_rows('json_keys_table', [['--', 'No data', '--']])
		return
	}

	sw := time.new_stopwatch()
	parsed := json2.decode[json2.Any](raw) or {
		w.set_kpi('kpi_status', 'Invalid Syntax', 'Error')
		w.set_kpi('kpi_size', system.format_bytes(u64(raw.len)), 'Raw bytes')
		w.set_kpi('kpi_speed', '${sw.elapsed().milliseconds()}ms', 'Failed')
		w.set_status('❌ JSON Syntax Error: ${err}')
		w.toast_error('Invalid JSON syntax: ${err}')
		w.set_table_rows('json_keys_table', [['Error', '${err}', 'Invalid']])
		return
	}
	elapsed := sw.elapsed()

	w.set_kpi('kpi_status', 'Valid JSON', 'Syntax Verified')
	w.set_kpi('kpi_size', system.format_bytes(u64(raw.len)), '${raw.len} Bytes')
	w.set_kpi('kpi_speed', '${elapsed.milliseconds()}ms', 'Fast V json2')

	mut rows := [][]string{}

	if parsed is map[string]json2.Any {
		w.set_kpi('kpi_keys', '${parsed.len} Keys', 'Object Root')
		for k, v in parsed {
			typ_str := match v {
				string { 'string' }
				int, i64, f64 { 'number' }
				bool { 'boolean' }
				[]json2.Any { 'array (${v.len} items)' }
				map[string]json2.Any { 'object (${v.len} keys)' }
				else { 'null' }
			}
			preview := v.json_str()
			display_prev := if preview.len > 40 { preview[..37] + '...' } else { preview }
			rows << [k, typ_str, display_prev]
		}
	} else if parsed is []json2.Any {
		w.set_kpi('kpi_keys', '${parsed.len} Elements', 'Array Root')
		for i, item in parsed {
			if i >= 15 {
				rows << ['...', 'array items truncated', '(${parsed.len - 15} more items)']
				break
			}
			preview := item.json_str()
			display_prev := if preview.len > 40 { preview[..37] + '...' } else { preview }
			rows << ['[${i}]', 'element', display_prev]
		}
	} else {
		w.set_kpi('kpi_keys', '1 Primitive', 'Scalar')
		rows << ['(root)', 'primitive', parsed.json_str()]
	}

	if rows.len == 0 {
		rows << ['(empty)', 'empty structure', '0 entries']
	}
	w.set_table_rows('json_keys_table', rows)
	w.set_status('JSON document analyzed • ${raw.len} bytes • Syntax Valid')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'JSON Query Studio Pro Enterprise -- High-Performance JSON Workbench'
		width: 1180
		height: 890
		theme: 'tokyo_night'
	)

	win.heading('⚡ JSON Query Studio Pro Enterprise')
	win.subheading('Enterprise JSON Workstation: Syntax Validation, Prettification, Filtering, Tree Metrics & CSV Export')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Syntax Validation', 'Ready', 'Syntax')
	win.kpi_card_named('kpi_size', 'Document Size', '0 B', 'Payload')
	win.kpi_card_named('kpi_keys', 'Structure Elements', '0 Keys', 'Nodes')
	win.kpi_card_named('kpi_speed', 'Parse Latency', '0ms', 'V json2')
	win.row_end()

	default_json := '{\n  "project": "Vlang Webview RAD Studio",\n  "version": "1.0.0",\n  "author": "codecaine",\n  "enterprise": true,\n  "features": [\n    "Delphi Docking System",\n    "70+ Named Controls",\n    "42 Curated Themes",\n    "Live Watcher Engine",\n    "Zero-Lag Native Windowing"\n  ],\n  "metrics": {\n    "memory_mb": 14.2,\n    "startup_ms": 12,\n    "studios_count": 16\n  }\n}'

	// Workstation Editor Boxes
	win.box_start('📝 JSON Source Workspace & Filter Controls')
	win.row_start()
	win.subheading('Source JSON Document')
	win.subheading('JSON Query / Key Filter Expression')
	win.row_end()

	win.row_start()
	win.textarea_named('json_input', 'Paste or load JSON content here...', default_json, fn (w &simplegui.SimpleWindow, val string) {
		analyze_json_document(w, val)
	})
	win.textarea_named('json_output', 'Filtered or formatted output representation...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.input_named('query_key', 'Filter key or property (e.g. features, metrics, project)...', 'features', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('🔍 Filter by Key', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('json_input')
		key := w.get('query_key').trim_space()
		if key == '' {
			w.toast_warning('Enter a key to filter.')
			return
		}
		parsed := json2.decode[json2.Any](raw) or {
			w.toast_error('Invalid JSON: ${err}')
			return
		}
		if parsed is map[string]json2.Any {
			if val := parsed[key] {
				w.set_value('json_output', json2.encode[json2.Any](val, prettify: true))
				w.toast_success('Filtered key: "${key}"')
			} else {
				w.toast_warning('Key "${key}" not found in JSON root object.')
			}
		} else {
			w.toast_warning('Root is not a JSON object.')
		}
	})
	win.button('✨ Prettify JSON', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('json_input')
		parsed := json2.decode[json2.Any](raw) or {
			w.toast_error('JSON Error: ${err}')
			return
		}
		pretty := json2.encode[json2.Any](parsed, prettify: true)
		w.set_value('json_input', pretty)
		w.set_value('json_output', pretty)
		w.toast_success('JSON prettified!')
		analyze_json_document(w, pretty)
	})
	win.button('📦 Minify JSON', fn (w &simplegui.SimpleWindow, _ string) {
		raw := w.get('json_input')
		parsed := json2.decode[json2.Any](raw) or {
			w.toast_error('JSON Error: ${err}')
			return
		}
		compact := json2.encode[json2.Any](parsed)
		w.set_value('json_input', compact)
		w.set_value('json_output', compact)
		w.toast_success('JSON minified (${compact.len} bytes)!')
		analyze_json_document(w, compact)
	})
	win.row_end()

	// File Actions Row
	win.row_start()
	win.button('📂 Load from File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select JSON File', 'json,txt')
		if path != '' {
			content := os.read_file(path) or {
				w.toast_error('Failed to read file: ${err}')
				return
			}
			w.set_value('json_input', content)
			w.toast_success('Loaded JSON: ' + path)
			analyze_json_document(w, content)
		}
	})
	win.button('💾 Save Output File...', fn (w &simplegui.SimpleWindow, _ string) {
		out := w.get('json_output')
		content := if out.trim_space() != '' { out } else { w.get('json_input') }
		if content.trim_space() == '' {
			w.toast_warning('Nothing to save.')
			return
		}
		path := w.save_file_dialog('Save JSON Document', 'document.json')
		if path != '' {
			os.write_file(path, content) or {
				w.toast_error('Failed to save file: ${err}')
				return
			}
			w.toast_success('JSON saved to: ' + path)
		}
	})
	win.button('📋 Copy Output to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		out := w.get('json_output')
		content := if out.trim_space() != '' { out } else { w.get('json_input') }
		system.set_clipboard_text(content)
		w.toast_success('Copied JSON to clipboard!')
	})
	win.row_end()
	win.box_end()

	// Key Structure Inspector Table
	win.box_start('📊 JSON Document Schema & Key Structure Telemetry')
	headers := ['Field / Key Name', 'Detected Type', 'Value Preview / Subtree']
	win.table_named('json_keys_table', headers, [['--', 'Loading schema...', '--']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspecting field #${idx}')
	})
	win.box_end()

	win.status_bar('JSON Query Studio Pro Enterprise  •  High-Performance json2 Engine  •  Ready')

	// Initial analyze
	analyze_json_document(win, default_json)

	win.run()
}
