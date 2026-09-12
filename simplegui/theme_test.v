module simplegui

fn test_theme_counts() {
	themes := get_all_themes()
	names := get_theme_names()
	assert themes.len == 76
	assert names.len == 76

	for i in 1 .. names.len {
		assert names[i - 1] < names[i]
	}

	for name in names {
		assert name in themes
		t := themes[name]
		assert t.name.len > 0
		assert t.background_color.starts_with('#')
		assert t.font_color.starts_with('#')
		assert t.accent_color.starts_with('#')
	}
}

fn test_theme_aliases() {
	assert get_theme('raycast').name == 'Raycast Dark'
	assert get_theme('linear').name == 'Linear Studio'
	assert get_theme('vercel').name == 'Vercel Geist'
	assert get_theme('ue5').name == 'Unreal Engine 5'
	assert get_theme('arc_browser').name == 'Arc Velvet'
	assert get_theme('c64').name == 'Commodore 64'
	assert get_theme('gruvbox').name == 'Gruvbox Dark'
	assert get_theme('one_dark').name == 'One Dark Pro'
	assert get_theme('synthwave_84').name == "Synthwave '84"
	assert get_theme('macos_sonoma').name == 'macOS Sonoma Dark'
}
