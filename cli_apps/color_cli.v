module main

import flag
import math
import os

struct ColorRGB {
	r int
	g int
	b int
}

fn hex_to_rgb(hex_str string) ?ColorRGB {
	clean := hex_str.trim_left('#')
	if clean.len != 6 || clean.bytes().any(!it.is_hex_digit()) {
		return none
	}
	r := ('0x' + clean[0..2]).int()
	g := ('0x' + clean[2..4]).int()
	b := ('0x' + clean[4..6]).int()
	return ColorRGB{ r: r, g: g, b: b }
}

fn rgb_to_hex(rgb ColorRGB) string {
	return '#${rgb.r:02x}${rgb.g:02x}${rgb.b:02x}'
}

fn luminance(rgb ColorRGB) f64 {
	a := [f64(rgb.r) / 255.0, f64(rgb.g) / 255.0, f64(rgb.b) / 255.0].map(if it <= 0.03928 {
		it / 12.92
	} else {
		math.pow((it + 0.055) / 1.055, 2.4)
	})
	return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722
}

fn contrast_ratio(c1 ColorRGB, c2 ColorRGB) f64 {
	l1 := luminance(c1)
	l2 := luminance(c2)
	bright := if l1 > l2 { l1 } else { l2 }
	dark := if l1 > l2 { l2 } else { l1 }
	return (bright + 0.05) / (dark + 0.05)
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('color_cli')
	fp.version('2.0.0')
	fp.description('Color Converter, Palette & WCAG Contrast Ratio CLI')
	fp.skip_executable()

	hex_val := fp.string('hex', `x`, '', 'Hex color code (e.g. #38bdf8)')
	bg_hex := fp.string('bg', `b`, '#0f172a', 'Background Hex for contrast calculation')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 1 {
		eprintln('Error: Expected at most one foreground color')
		exit(2)
	}
	if hex_val != '' && additional_args.len > 0 {
		eprintln('Error: Specify the foreground color with --hex or as an argument, not both')
		exit(2)
	}

	target_hex := if hex_val != '' {
		hex_val
	} else if additional_args.len > 0 {
		additional_args[0]
	} else {
		'#38bdf8'
	}

	fg := hex_to_rgb(target_hex) or {
		eprintln('Invalid Hex color: ${target_hex}')
		exit(2)
	}

	bg := hex_to_rgb(bg_hex) or {
		eprintln('Invalid background Hex: ${bg_hex}')
		exit(2)
	}

	cr := contrast_ratio(fg, bg)

	println('====================================================================')
	println('🎨 COLOR PALETTE & CONTRAST CLI')
	println('====================================================================')
	println('Foreground Hex:  ${rgb_to_hex(fg)}')
	println('Foreground RGB:  rgb(${fg.r}, ${fg.g}, ${fg.b})')
	println('Background Hex:  ${rgb_to_hex(bg)}')
	println('Contrast Ratio:  ${cr:.2f}:1')
	println('WCAG AA (4.5:1): ${if cr >= 4.5 { 'PASS ✅' } else { 'FAIL ❌' }}')
	println('WCAG AAA (7:1):  ${if cr >= 7.0 { 'PASS ✅' } else { 'FAIL ❌' }}')
	println('====================================================================')
}
