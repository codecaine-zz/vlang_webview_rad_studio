module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 6 - Timer Control Studio & Event Intervals'
		width: 900
		height: 650
		theme: 'cyberpunk'
	)

	win.heading('⏱️ Timer Control Studio & Event Intervals')
	win.subheading('High-precision recurring intervals & background tick events:')
	win.divider()

	win.row_start()
	win.kpi_card('Elapsed Time', '00:04:32', 'Timer #1 active')
	win.kpi_card('Tick Frequency', '100 ms', '10 ticks/sec')
	win.kpi_card('Total Events', '2,720', 'Zero drift detected')
	win.row_end()

	win.box_start('Stopwatch & Interval Controls')
	win.row_start()
	win.button('▶ Start Timer', fn (w &simplegui.SimpleWindow, _ string) {
		println('Timer Started')
	})
	win.button('⏸ Pause Timer', fn (w &simplegui.SimpleWindow, _ string) {
		println('Timer Paused')
	})
	win.button('↺ Reset Timer', fn (w &simplegui.SimpleWindow, _ string) {
		println('Timer Reset')
	})
	win.row_end()

	win.subheading('Timer Interval (ms):')
	win.slider(50, 2000, 250, fn (w &simplegui.SimpleWindow, val string) {
		println('Timer interval: ${val} ms')
	})
	win.box_end()

	win.box_start('Scheduled Event Log')
	headers := ['Timestamp', 'Event Type', 'Trigger Count', 'Duration']
	rows := [
		['10:14:02.100', 'Telemetry Tick', '100', '10.0s'],
		['10:14:12.100', 'Telemetry Tick', '200', '20.0s'],
		['10:14:22.100', 'Telemetry Tick', '300', '30.0s'],
		['10:14:32.100', 'Heartbeat Ping', '301', '30.1s'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Timer Status: Running | Precision: 1ms')

	win.run()
}
