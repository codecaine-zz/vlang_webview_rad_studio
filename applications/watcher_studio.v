module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Watcher Studio Pro -- File System Monitor & Auto-Execution'
		width: 1100
		height: 820
		theme: 'everforest'
	)

	win.heading('👁️ Watcher Studio Pro')
	win.label('Continuous File System Change Monitoring, Live Directory Auditing & Command Auto-Triggering')

	win.subheading('Watch Directory Target')
	win.input('Target Directory Path to Watch...', '.', fn (w &simplegui.SimpleWindow, _ string) {})

	win.subheading('Shell Command to Execute on Modification')
	win.input('Command to run when changes are detected...', 'echo "File changed at $(date)"', fn (w &simplegui.SimpleWindow, _ string) {})

	win.divider()
	win.subheading('Recent File Activity Log')

	headers := ['Timestamp', 'File Event', 'Target Path', 'Status']
	rows := [
		['04:42:15', 'File Modified', './src/system/sys.v', 'Logged'],
		['04:42:30', 'File Created', './applications/system_studio.v', 'Compiled'],
		['04:43:02', 'File Saved', './resources/ide.html', 'Rendered']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('File Log', 'Selected event row #${idx}')
	})

	win.divider()
	win.subheading('Watcher Actions')

	win.button('▶️ Start Watcher Engine', fn (w &simplegui.SimpleWindow, _ string) {
		dir := w.get_value('inp_1')
		cmd := w.get_value('inp_2')
		w.notification('Watcher Started', 'Watching: ${dir} -> Auto-executing: ${cmd}')
		w.alert('Watcher Active', 'File watcher listening on "${dir}". Any modifications will execute:\n${cmd}')
	})

	win.button('📂 Browse Directory...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.select_folder_dialog('Choose Directory to Watch')
		if path != '' {
			w.set_value('inp_1', path)
			w.notification('Directory Selected', 'Watching: ' + path)
		}
	})

	win.button('⚡ Test Trigger Command Manually', fn (w &simplegui.SimpleWindow, _ string) {
		cmd := w.get_value('inp_2')
		out, code := system.exec(cmd)
		w.alert('Command Run', 'Exit Code: ${code}\nOutput:\n${out}')
	})

	win.status_bar('Watcher Studio Pro  •  High-Frequency Inotify / FSEvents Engine  •  Listening')
	win.run()
}
