module main

import flag
import os

fn md_to_html(md string) string {
	lines := md.split_into_lines()
	mut out := []string{}
	out << '<!DOCTYPE html><html><head><meta charset="utf-8">'
	out << '<style>body{font-family:sans-serif;max-width:800px;margin:2rem auto;padding:0 1rem;line-height:1.6;color:#e2e8f0;background:#0f172a;}code{background:#1e293b;padding:0.2rem 0.4rem;border-radius:4px;}pre{background:#1e293b;padding:1rem;border-radius:6px;overflow-x:auto;}h1,h2,h3{color:#38bdf8;}</style></head><body>'

	for line in lines {
		trimmed := line.trim_space()
		if trimmed.starts_with('### ') {
			out << '<h3>${trimmed[4..]}</h3>'
		} else if trimmed.starts_with('## ') {
			out << '<h2>${trimmed[3..]}</h2>'
		} else if trimmed.starts_with('# ') {
			out << '<h1>${trimmed[2..]}</h1>'
		} else if trimmed.starts_with('- ') || trimmed.starts_with('* ') {
			out << '<li>${trimmed[2..]}</li>'
		} else if trimmed == '' {
			out << '<br/>'
		} else {
			out << '<p>${trimmed}</p>'
		}
	}
	out << '</body></html>'
	return out.join('\n')
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('markdown_cli')
	fp.version('2.0.0')
	fp.description('Markdown to HTML Converter & Preview CLI')
	fp.skip_executable()

	file_path := fp.string('file', `f`, '', 'Input markdown file')
	out_file := fp.string('out', `o`, '', 'Output HTML file (optional)')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	mut input := ''
	if file_path != '' {
		input = os.read_file(file_path) or {
			eprintln('Error: Could not read file "${file_path}": ${err}')
			exit(1)
		}
	} else if additional_args.len > 0 {
		input = additional_args.join(' ')
	} else {
		input = '# RAD Studio Markdown\n\nWelcome to **vlang_webview_rad_studio**!\n\n- Fast\n- Modern\n- Cross-Platform'
	}

	html := md_to_html(input)
	if out_file != '' {
		os.write_file(out_file, html) or {
			eprintln('Error: Failed to write to "${out_file}": ${err}')
			exit(1)
		}
		println('✅ HTML saved to: ${out_file}')
	} else {
		println(html)
	}
}
