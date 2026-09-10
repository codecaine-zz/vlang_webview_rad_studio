module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 12 - Advanced Desktop App Controls'
		width: 960
		height: 700
		theme: 'windows_11_fluent'
	)

	win.heading('🖥️ Advanced Desktop App Controls & Navigation')
	win.subheading('Desktop system tray, modal dialogs, status monitors & feedback:')
	win.divider()

	win.row_start()
	win.kpi_card('Cluster Status', 'Healthy', 'All 8 pods healthy')
	win.kpi_card('Network IO', '124 MB/s', 'Symmetric throughput')
	win.kpi_card('CPU Load', '2.8%', 'Idle baseline')
	win.row_end()

	win.box_start('Desktop System Triggers')
	win.row_start()
	win.button('🔔 Desktop Notification', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('RAD Studio Demo 12', 'Native notification sent to OS notification center.')
	})
	win.button('⚠️ Confirmation Dialog', fn (w &simplegui.SimpleWindow, _ string) {
		ok := w.confirm('Confirm Operation', 'Do you wish to proceed with server deployment?')
		if ok {
			w.alert('Action Confirmed', 'Deployment pipeline triggered.')
		}
	})
	win.button('🎯 Center Window', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.button('⛶ Fullscreen', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.row_end()
	win.box_end()

	win.box_start('Batch Task Queue Monitor')
	win.subheading('Worker Progress: 64%')
	win.progress(64, 100)

	headers := ['Job ID', 'Worker', 'Status', 'Payload', 'Run Time']
	rows := [
		['#4901', 'worker-gpu-01', 'Running', 'ResNet50 Inference', '42s'],
		['#4902', 'worker-cpu-04', 'Completed', 'Data Pipeline ETL', '1m 12s'],
		['#4903', 'worker-cpu-08', 'Queued', 'Nightly DB Backup', '-'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('System Ready | Queue depth: 3 jobs | Memory headroom: 12.4 GB')

	win.run()
}
