module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 21 - Vlang Parity Controls Showcase'
		width: 960
		height: 700
		theme: 'matrix'
	)

	win.heading('⚡ Vlang Native GUI Parity Controls Showcase')
	win.subheading('Direct parity with simple_gg and vlang_simplegui controls:')
	win.divider()

	win.row_start()
	win.kpi_card('Language', 'V 0.4.x', 'Pure native binary')
	win.kpi_card('GUI Latency', '< 1 ms', 'Hardware FFI accelerated')
	win.kpi_card('Binary Size', '~2.8 MB', 'Zero bundle overhead')
	win.row_end()

	win.box_start('Parity Benchmark Form Controls')
	win.row_start()
	win.input('V Function Name', 'fn compute_metrics()', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Struct Method', 'Free Function', 'Anonymous Closure'], 'Struct Method', fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('Inline Optimization', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.subheading('Optimization Passes:')
	win.slider(1, 10, 3, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.row_start()
	win.button('🚀 Benchmark FFI Call', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Benchmark Finished', '10,000 IPC calls processed in 4.2ms!')
	})
	win.row_end()

	win.status_bar('Vlang Parity Engine: 100% Compatible with simple_gg and vlang_simplegui')

	win.run()
}
