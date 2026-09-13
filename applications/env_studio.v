module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Env Studio Pro -- Environment Variables Workbench'
		width: 1100
		height: 820
		theme: 'kanagawa'
	)

	win.heading('🌱 Env Studio Pro')
	win.label('System Environment Variables Explorer, Process Context Auditor & Path Inspector')

	env_vars := system.get_all_env()
	path := system.get_env('PATH')
	path_preview := if path.len > 35 { path[..35] + '...' } else { path }
	win.kpi_card('Total Active Variables', '${env_vars.len}', 'Process Environment Context')

	win.subheading('Variable Lookup / Search')
	win.input('Enter environment variable name (e.g. PATH, HOME, USER)...', 'PATH', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Core Environment Variables Table')

	headers := ['Variable Key', 'Value Preview', 'Status']
	rows := [
		['USER', system.get_env('USER'), 'Defined'],
		['HOME', system.get_user_home_dir(), 'Defined'],
		['SHELL', system.get_env('SHELL'), 'Defined'],
		['TERM', system.get_env('TERM'), 'Defined'],
		['PATH', path_preview, if path == '' { 'Not defined' } else { 'Multi-entry' }],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Variable Selected', 'Viewing row #${idx}')
	})

	win.divider()
	win.subheading('Actions')

	win.button('🔍 Lookup Variable Value', fn (w &simplegui.SimpleWindow, _ string) {
		key := w.get_value('inp_1')
		val := system.get_env(key)
		if val != '' {
			w.alert('Environment Variable: ' + key, val)
		} else {
			w.alert('Notice', 'Variable "${key}" is not set in current process.')
		}
	})

	win.button('📋 Copy Full PATH to Clipboard', fn (w &simplegui.SimpleWindow, _ string) {
		path := system.get_env('PATH')
		system.set_clipboard_text(path)
		w.alert('Clipboard', 'PATH copied to clipboard!')
	})

	win.status_bar('Env Studio Pro  •  POSIX Process Environment  •  Loaded')
	win.run()
}
