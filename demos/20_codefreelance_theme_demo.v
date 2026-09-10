module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 20 - Codefreelance Desktop Theme Showcase'
		width: 960
		height: 720
		theme: 'monokai_pro'
	)

	win.heading('🎨 42 Desktop Form Themes Showcase')
	win.subheading('Pixel-perfect modern, retro, and hacker themes for enterprise apps:')
	win.divider()

	win.box_start('Theme Catalog Highlights')
	headers := ['Category', 'Themes Included', 'Style Aesthetic']
	rows := [
		['Modern IDE', 'Monokai Pro, Tokyo Night, Dracula, Nord, One Dark', 'High-contrast vibrant palettes'],
		['Operating Systems', 'macOS Sonoma, Windows 11 Fluent, Ubuntu Yaru', 'Native OS mimicry & rounded corners'],
		['Retro Computing', 'Windows 95, Commodore 64, Amiga 500, Mac System 7', 'Authentic 90s beveled borders'],
		['Hacker & Synth', 'Cyberpunk 2077, Synthwave 84, Matrix Phosphor', 'Neon glows & phosphor green scanlines'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.box_start('Theme Demonstration Controls')
	win.row_start()
	win.button('Theme: Monokai Pro', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('monokai_pro')
		w.toast_info('Theme switched to Monokai Pro')
		w.set_status('Active Theme: Monokai Pro')
	})
	win.button('Theme: Tokyo Night', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('tokyo_night')
		w.toast_info('Theme switched to Tokyo Night')
		w.set_status('Active Theme: Tokyo Night')
	})
	win.button('Theme: Cyberpunk', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('cyberpunk')
		w.toast_info('Theme switched to Cyberpunk')
		w.set_status('Active Theme: Cyberpunk')
	})
	win.button('Theme: macOS Sonoma', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('macos_sonoma')
		w.toast_info('Theme switched to macOS Sonoma')
		w.set_status('Active Theme: macOS Sonoma')
	})
	win.row_end()

	win.row_start()
	win.input('Theme Testing Input', 'Type something here...', fn (w &simplegui.SimpleWindow, _ string) {})
	win.dropdown(['Monokai Pro', 'Dracula', 'Nord', 'Gruvbox', 'Cyberpunk'], 'Monokai Pro', fn (w &simplegui.SimpleWindow, _ string) {})
	win.toggle('High Contrast Glow', true, fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()
	win.box_end()

	win.status_bar('Theme Engine: 42 Built-in Desktop Form Themes Available')

	win.run()
}
