module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'App Bundler Studio Pro -- Cross-Platform Desktop Packager'
		width: 1100
		height: 820
		theme: 'sonoma_dark'
	)

	win.heading('📦 App Bundler Studio Pro')
	win.label('Standalone Desktop Application Packaging, macOS .app Bundles, Custom Icons & Binary Optimization')

	win.subheading('Application Name & Bundle ID')
	win.input('Application Display Name...', 'My Vlang App', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input('Bundle Identifier (e.g. com.company.app)...', 'com.vlang.myapp', fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('Source Entry File')
	win.input('Entry .v source file...', 'main.v', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Packaging Target Profiles')

	headers := ['Platform Target', 'Binary Format', 'Optimization']
	rows := [
		['macOS Apple Silicon & Intel', '.app Bundle with ICNS Icon', 'Production (-prod)'],
		['Linux x86_64 / arm64', 'Standalone ELF Executable', 'Stripped (-prod)'],
		['Windows 64-bit', 'PE Executable (.exe) + Icon', 'Embedded (-prod)']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Target Selected', 'Target profile row #${idx}')
	})

	win.divider()
	win.subheading('Bundler Actions')

	win.button('🚀 Build macOS .app Bundle', fn (w &simplegui.SimpleWindow, _ string) {
		name := w.get_value('inp_1')
		entry := w.get_value('inp_3')
		w.notification('Building', 'Packaging ${name}.app from ${entry}...')
		res := system.exec_or('v -prod -o "${name}" "${entry}"', 'Build completed')
		w.alert('Build Result', 'Compiled standalone binary:\n' + res)
	})

	win.button('🎨 Select Custom PNG Icon...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select App Icon PNG', 'png')
		if path != '' {
			w.notification('Icon Selected', 'Set app icon: ' + path)
		}
	})

	win.status_bar('App Bundler Studio Pro  •  Multi-Target Cross Compilation  •  Ready')
	win.run()
}
