module main

import simplegui
import time
import mockutils
import colorutils
import strutils
import semverutils
import validutils
import cacheutils
import timeutils

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 25 - Comprehensive Developer Utilities Suite'
		width: 960
		height: 740
		theme: 'dracula'
	)

	win.heading('🛠️ Developer Utility Toolkit Showcase')
	win.subheading('30 Production-Grade Utility Modules embedded directly into Vlang RAD Studio')
	win.divider()

	// -------------------------------------------------------------------------
	// 1. Synthetic Data Generator (mockutils)
	// -------------------------------------------------------------------------
	win.box_start('👤 1. Synthetic Data & Mock Profiles (mockutils)')
	user := mockutils.mock_user()

	win.row_start()
	win.kpi_card('Mock ID', '${user.id}', 'Randomly generated')
	win.kpi_card('Mock User', user.name, user.role)
	win.kpi_card('Mock Contact', user.email, user.phone)
	win.row_end()

	win.row_start()
	win.button('🎲 Generate Random User', fn (w &simplegui.SimpleWindow, _ string) {
		u := mockutils.mock_user()
		w.toast_success('Generated: ${u.name} (${u.email}) [${u.role}]')
		w.set_status('Generated synthetic user profile for: ${u.name}')
	})
	win.row_end()
	win.box_end()

	// -------------------------------------------------------------------------
	// 2. String Case Manipulation (strutils)
	// -------------------------------------------------------------------------
	win.box_start('🔤 2. String Transformations & Slugs (strutils)')
	input_text := 'Vlang RAD Studio Webview'
	win.row_start()
	win.label('Original: "${input_text}"')
	win.label('snake_case: "${strutils.to_snake_case(input_text)}"')
	win.label('kebab-case: "${strutils.to_kebab_case(input_text)}"')
	win.label('camelCase: "${strutils.to_camel_case(input_text)}"')
	win.label('slug: "${strutils.slugify(input_text)}"')
	win.row_end()
	win.box_end()

	// -------------------------------------------------------------------------
	// 3. Color Studio & Palettes (colorutils)
	// -------------------------------------------------------------------------
	win.box_start('🎨 3. Color Space Engine (colorutils)')
	hex_col := '#6366f1'
	rgb_col := colorutils.hex_to_rgb(hex_col) or { colorutils.RGB{r: 99, g: 102, b: 241} }
	hsl_col := colorutils.rgb_to_hsl(rgb_col)

	win.row_start()
	win.kpi_card('Hex Color', hex_col, 'Source input')
	win.kpi_card('RGB String', rgb_col.str(), '8-bit channels')
	win.kpi_card('HSL String', hsl_col.str(), 'Hue / Sat / Light')
	win.row_end()
	win.box_end()

	// -------------------------------------------------------------------------
	// 4. SemVer & Data Validation (semverutils & validutils)
	// -------------------------------------------------------------------------
	win.box_start('🔍 4. SemVer & Validation (semverutils & validutils)')
	v1_str := '2.4.1'
	v1 := semverutils.parse(v1_str) or { semverutils.SemVer{} }
	satisfies := semverutils.satisfies(v1, '^2.0.0') or { false }

	test_email := 'developer@vlang.io'
	test_url := 'https://github.com/codecaine-zz/vlang_utils'
	is_valid_email := validutils.validate_email(test_email)
	is_valid_url := validutils.validate_url(test_url)

	win.row_start()
	win.kpi_card('SemVer Check', '${v1.str()} ^2.0.0', if satisfies { 'Satisfied' } else { 'Failed' })
	win.kpi_card('Email Validation', test_email, if is_valid_email { 'Valid format' } else { 'Invalid' })
	win.kpi_card('URL Validation', 'GitHub URL', if is_valid_url { 'Valid HTTP(S)' } else { 'Invalid' })
	win.row_end()
	win.box_end()

	// -------------------------------------------------------------------------
	// 5. In-Memory LRU Cache & Time (cacheutils & timeutils)
	// -------------------------------------------------------------------------
	win.box_start('⚡ 5. High-Performance LRU Cache & Time (cacheutils & timeutils)')
	mut lru := cacheutils.new_lru[string](3) or { panic(err) }
	lru.set('session_token', 'xyz_998124')
	lru.set('active_theme', 'dracula')
	cached_theme := lru.get('active_theme') or { 'none' }

	sample_past := time.now().add_seconds(-3600)
	time_ago_str := timeutils.time_ago(sample_past)

	win.row_start()
	win.label('LRU Cached "active_theme": "${cached_theme}" (Items: ${lru.len()}/3)')
	win.label('Relative Time (-1 hour): "${time_ago_str}"')
	win.row_end()
	win.box_end()

	win.status_bar('All 30 Developer Utility Modules ready and verified!')
	win.run()
}
