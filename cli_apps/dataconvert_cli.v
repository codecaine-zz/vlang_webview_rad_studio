module main

import flag
import os
import x.json2

fn csv_to_json(csv string) string {
	lines := csv.split_into_lines().filter(it.trim_space() != '')
	if lines.len < 2 {
		return '[]'
	}
	headers := lines[0].split(',').map(it.trim_space().trim('"'))
	mut list := []map[string]string{}
	for i in 1 .. lines.len {
		row := lines[i].split(',')
		mut obj := map[string]string{}
		for j in 0 .. headers.len {
			val := if j < row.len { row[j].trim_space().trim('"') } else { '' }
			obj[headers[j]] = val
		}
		list << obj
	}
	return json2.encode[[]map[string]string](list, prettify: true)
}

fn json_to_csv(json_str string) !string {
	raw := json2.decode[json2.Any](json_str)!
	if raw !is []json2.Any {
		return error('JSON input must be an array of objects')
	}
	arr := raw as []json2.Any
	if arr.len == 0 {
		return ''
	}
	first := arr[0]
	if first !is map[string]json2.Any {
		return error('JSON input must be an array of objects')
	}
	headers := (first as map[string]json2.Any).keys()
	mut out := headers.join(',') + '\n'
	for item in arr {
		if item is map[string]json2.Any {
			m := item as map[string]json2.Any
			mut row := []string{}
			for h in headers {
				val := m[h] or { json2.Any('') }
				row << val.str().replace(',', ' ')
			}
			out += row.join(',') + '\n'
		} else {
			return error('JSON input must be an array of objects')
		}
	}
	return out
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('dataconvert_cli')
	fp.version('2.0.0')
	fp.description('Data Format Converter: JSON <-> CSV <-> TSV')
	fp.skip_executable()

	from_fmt := fp.string('from', `f`, 'csv', 'Source format: csv, json')
	to_fmt := fp.string('to', `t`, 'json', 'Target format: csv, json')
	file_path := fp.string('file', `i`, '', 'Input file path')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if file_path != '' && additional_args.len > 0 {
		eprintln('Error: Specify input with --file or as arguments, not both')
		exit(2)
	}

	mut input := ''
	if file_path != '' {
		input = os.read_file(file_path) or {
			eprintln('Error: Could not read file: ${err}')
			exit(1)
		}
	} else if additional_args.len > 0 {
		input = additional_args.join(' ')
	} else {
		input = 'name,role,level\nAlice,Lead,5\nBob,Engineer,3'
	}

	if from_fmt.to_lower() == 'csv' && to_fmt.to_lower() == 'json' {
		println(csv_to_json(input))
	} else if from_fmt.to_lower() == 'json' && to_fmt.to_lower() == 'csv' {
		println(json_to_csv(input) or {
			eprintln('Error: Invalid JSON input: ${err}')
			exit(2)
		})
	} else {
		eprintln('Unsupported conversion: ${from_fmt} to ${to_fmt}')
		exit(2)
	}
}
