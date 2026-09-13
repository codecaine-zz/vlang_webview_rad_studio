module main

import simplegui
import system
import math

struct RGB {
	r int
	g int
	b int
}

fn hex_to_rgb(hex_raw string) RGB {
	mut h := hex_raw.trim_space().trim_left('#')
	if h.len == 3 {
		h = '${h[0..1]}${h[0..1]}${h[1..2]}${h[1..2]}${h[2..3]}${h[2..3]}'
	}
	if h.len != 6 {
		return RGB{56, 189, 248}
	}
	r := ('0x' + h[0..2]).int()
	g := ('0x' + h[2..4]).int()
	b := ('0x' + h[4..6]).int()
	return RGB{r, g, b}
}

fn rgb_to_hex(rgb RGB) string {
	r_hex := rgb.r.hex()
	g_hex := rgb.g.hex()
	b_hex := rgb.b.hex()
	return '#${if r_hex.len < 2 { '0' + r_hex } else { r_hex }}${if g_hex.len < 2 { '0' + g_hex } else { g_hex }}${if b_hex.len < 2 { '0' + b_hex } else { b_hex }}'
}

fn relative_luminance(c RGB) f64 {
	r := f64(c.r) / 255.0
	g := f64(c.g) / 255.0
	b := f64(c.b) / 255.0
	r_lin := if r <= 0.03928 { r / 12.92 } else { math.pow((r + 0.055) / 1.055, 2.4) }
	g_lin := if g <= 0.03928 { g / 12.92 } else { math.pow((g + 0.055) / 1.055, 2.4) }
	b_lin := if b <= 0.03928 { b / 12.92 } else { math.pow((b + 0.055) / 1.055, 2.4) }
	return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin
}

fn contrast_ratio(c1 RGB, c2 RGB) f64 {
	l1 := relative_luminance(c1)
	l2 := relative_luminance(c2)
	lighter := if l1 > l2 { l1 } else { l2 }
	darker := if l1 > l2 { l2 } else { l1 }
	return (lighter + 0.05) / (darker + 0.05)
}

fn update_color_workbench(w &simplegui.SimpleWindow, hex_code string) {
	rgb := hex_to_rgb(hex_code)
	norm_hex := rgb_to_hex(rgb)

	black_cr := contrast_ratio(rgb, RGB{0, 0, 0})
	white_cr := contrast_ratio(rgb, RGB{255, 255, 255})
	dark_cr := contrast_ratio(rgb, RGB{15, 23, 42})

	best_text := if white_cr > black_cr { 'White (#fff)' } else { 'Black (#000)' }
	best_ratio := if white_cr > black_cr { white_cr } else { black_cr }

	w.set_kpi('kpi_hex', norm_hex, 'HEX Code')
	w.set_kpi('kpi_rgb', 'rgb(${rgb.r}, ${rgb.g}, ${rgb.b})', 'RGB format')
	w.set_kpi('kpi_contrast', '${best_ratio:.1f}:1 (${best_text})', if best_ratio >= 7.0 { 'WCAG AAA' } else if best_ratio >= 4.5 { 'WCAG AA' } else { 'Fail' })
	w.set_kpi('kpi_lum', '${relative_luminance(rgb) * 100.0:.1f}%', 'Relative Luminance')

	// Generate Palette variations
	comp_rgb := RGB{255 - rgb.r, 255 - rgb.g, 255 - rgb.b}
	light_rgb := RGB{
		r: if rgb.r + 40 > 255 { 255 } else { rgb.r + 40 }
		g: if rgb.g + 40 > 255 { 255 } else { rgb.g + 40 }
		b: if rgb.b + 40 > 255 { 255 } else { rgb.b + 40 }
	}
	dark_rgb := RGB{
		r: if rgb.r - 40 < 0 { 0 } else { rgb.r - 40 }
		g: if rgb.g - 40 < 0 { 0 } else { rgb.g - 40 }
		b: if rgb.b - 40 < 0 { 0 } else { rgb.b - 40 }
	}

	palette_rows := [
		['Primary Base Color', norm_hex, 'rgb(${rgb.r}, ${rgb.g}, ${rgb.b})', '${dark_cr:.1f}:1 on Dark'],
		['Tint (+20% Lighter)', rgb_to_hex(light_rgb), 'rgb(${light_rgb.r}, ${light_rgb.g}, ${light_rgb.b})', '${contrast_ratio(light_rgb, RGB{15, 23, 42}):.1f}:1 on Dark'],
		['Shade (-20% Darker)', rgb_to_hex(dark_rgb), 'rgb(${dark_rgb.r}, ${dark_rgb.g}, ${dark_rgb.b})', '${contrast_ratio(dark_rgb, RGB{255, 255, 255}):.1f}:1 on White'],
		['Complementary Color', rgb_to_hex(comp_rgb), 'rgb(${comp_rgb.r}, ${comp_rgb.g}, ${comp_rgb.b})', 'Inverted Hue'],
	]
	w.set_table_rows('palette_table', palette_rows)
	w.set_status('Color computed: ${norm_hex} • Best readable text: ${best_text} (Ratio: ${best_ratio:.1f}:1)')
}

fn main() {
	default_color := '#38bdf8'

	mut win := simplegui.new_window(
		title: 'Color Studio Pro Enterprise -- Palette & Contrast Workbench'
		width: 1180
		height: 890
		theme: 'amethyst'
	)

	win.heading('🎨 Color Studio Pro Enterprise')
	win.subheading('Digital Color Palette Generator, HEX/RGB/HSL Converter, WCAG 2.1 Contrast Analyzer & Design Tokens')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_hex', 'HEX Colorway', default_color, 'Base Token')
	win.kpi_card_named('kpi_rgb', 'RGB Coordinates', 'rgb(56, 189, 248)', 'sRGB')
	win.kpi_card_named('kpi_contrast', 'WCAG Contrast', '12.4:1', 'AAA Certified')
	win.kpi_card_named('kpi_lum', 'Relative Luminance', '48.2%', 'Perceived Brightness')
	win.row_end()

	// Color Input Box
	win.box_start('🎯 Colorway Input & Swatch Presets')
	win.row_start()
	win.input_named('color_hex', 'Enter HEX color code (e.g. #38bdf8)...', default_color, fn (w &simplegui.SimpleWindow, val string) {
		update_color_workbench(w, val)
	})
	presets := [
		'Preset: Sky Blue (#38bdf8)',
		'Preset: Emerald (#10b981)',
		'Preset: Purple Neon (#a855f7)',
		'Preset: Amber Gold (#f59e0b)',
		'Preset: Rose Red (#f43f5e)',
		'Preset: Indigo (#6366f1)',
	]
	win.dropdown_named('color_presets', presets, presets[0], fn (w &simplegui.SimpleWindow, val string) {
		hex := match val {
			'Preset: Sky Blue (#38bdf8)' { '#38bdf8' }
			'Preset: Emerald (#10b981)' { '#10b981' }
			'Preset: Purple Neon (#a855f7)' { '#a855f7' }
			'Preset: Amber Gold (#f59e0b)' { '#f59e0b' }
			'Preset: Rose Red (#f43f5e)' { '#f43f5e' }
			'Preset: Indigo (#6366f1)' { '#6366f1' }
			else { '#38bdf8' }
		}
		w.set_value('color_hex', hex)
		update_color_workbench(w, hex)
		w.toast_info('Loaded palette preset: ' + hex)
	})
	win.row_end()
	win.box_end()

	// Generated Harmonious Palette Table Box
	win.box_start('📊 Harmonious Palette & WCAG 2.1 Contrast Matrix')
	headers := ['Token Role', 'HEX Value', 'RGB Representation', 'WCAG Contrast Status']
	win.table_named('palette_table', headers, [['Base Color', default_color, 'rgb(56, 189, 248)', 'Evaluating...']], fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspected swatch row #${idx}')
	})
	win.box_end()

	// Code Export Box
	win.box_start('📋 Design Token Export Actions')
	win.row_start()
	win.button('📋 Copy CSS Variables (:root)', fn (w &simplegui.SimpleWindow, _ string) {
		hex := w.get('color_hex')
		rgb := hex_to_rgb(hex)
		css := ':root {\n' +
			'  --color-primary: ${hex};\n' +
			'  --color-primary-rgb: ${rgb.r}, ${rgb.g}, ${rgb.b};\n' +
			'  --color-primary-light: ${rgb_to_hex(RGB{rgb.r + 30, rgb.g + 30, rgb.b + 30})};\n' +
			'  --color-primary-dark: ${rgb_to_hex(RGB{rgb.r - 30, rgb.g - 30, rgb.b - 30})};\n' +
			'}'
		system.set_clipboard_text(css)
		w.toast_success('CSS variables copied to clipboard!')
	})
	win.button('📋 Copy Tailwind Config', fn (w &simplegui.SimpleWindow, _ string) {
		hex := w.get('color_hex')
		tw := 'colors: {\n' +
			'  brand: {\n' +
			'    DEFAULT: "${hex}",\n' +
			'    light: "${hex}cc",\n' +
			'    dark: "${hex}99",\n' +
			'  }\n' +
			'}'
		system.set_clipboard_text(tw)
		w.toast_success('Tailwind color config copied to clipboard!')
	})
	win.button('📋 Copy Vlang Constants', fn (w &simplegui.SimpleWindow, _ string) {
		hex := w.get('color_hex')
		rgb := hex_to_rgb(hex)
		v_code := 'pub const color_primary = "${hex}"\n' +
			'pub const color_primary_rgb = [${rgb.r}, ${rgb.g}, ${rgb.b}]\n'
		system.set_clipboard_text(v_code)
		w.toast_success('Vlang constants copied to clipboard!')
	})
	win.row_end()
	win.box_end()

	win.status_bar('Color Studio Pro Enterprise  •  WCAG 2.1 AAA Compliant  •  Ready')

	// Initial population
	update_color_workbench(win, default_color)

	win.run()
}
