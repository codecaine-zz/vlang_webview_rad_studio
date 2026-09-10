module simplegui

import os

pub struct Theme {
pub:
	name             string
	short_name       string
	background_color string
	font_color       string
	accent_color     string
	secondary_accent string
	card_background string
	card_border     string
	description      string
	is_dark          bool
}

pub fn get_all_themes() map[string]Theme {
	return {
		// Modern & Developer Themes
		'monokai_pro': Theme{
			name: 'Monokai Pro'
			short_name: 'Monokai'
			background_color: '#2d2a2e'
			font_color: '#fcfcfa'
			accent_color: '#ffd866'
			secondary_accent: '#ff6188'
			card_background: '#221f22'
			card_border: '#403e41'
			description: 'Monokai Pro refined dark spectrum with warm yellow and vivid magenta accents'
			is_dark: true
		}
		'tokyo_night': Theme{
			name: 'Tokyo Night'
			short_name: 'Tokyo Night'
			background_color: '#1a1b26'
			font_color: '#c0caf5'
			accent_color: '#7aa2f7'
			secondary_accent: '#bb9af7'
			card_background: '#24283b'
			card_border: '#414868'
			description: 'Tokyo Night dark neon indigo city theme with vibrant blue and lavender accents'
			is_dark: true
		}
		'one_dark_pro': Theme{
			name: 'One Dark Pro'
			short_name: 'One Dark'
			background_color: '#21252b'
			font_color: '#abb2bf'
			accent_color: '#61afef'
			secondary_accent: '#98c379'
			card_background: '#282c34'
			card_border: '#3e4451'
			description: 'Iconic Atom & VS Code One Dark Pro deep slate canvas with vibrant syntax hues'
			is_dark: true
		}
		'gruvbox_dark': Theme{
			name: 'Gruvbox Dark'
			short_name: 'Gruvbox'
			background_color: '#282828'
			font_color: '#ebdbb2'
			accent_color: '#fabd2f'
			secondary_accent: '#fe8019'
			card_background: '#1d2021'
			card_border: '#504945'
			description: 'Retro groove warm earthy dark palette with amber gold and terracotta orange'
			is_dark: true
		}
		'gruvbox_light': Theme{
			name: 'Gruvbox Light'
			short_name: 'Gruv Light'
			background_color: '#fbf1c7'
			font_color: '#3c3836'
			accent_color: '#b57614'
			secondary_accent: '#af3a03'
			card_background: '#f2e5bc'
			card_border: '#d5c4a1'
			description: 'Retro groove parchment light canvas with earthy amber and walnut tones'
			is_dark: false
		}
		'rose_pine': Theme{
			name: 'Rosé Pine'
			short_name: 'Rosé Pine'
			background_color: '#191724'
			font_color: '#e0def4'
			accent_color: '#ebbcba'
			secondary_accent: '#31748f'
			card_background: '#1f1d2e'
			card_border: '#26233a'
			description: 'All natural pine needles and soft soho rose wine minimalist aesthetic'
			is_dark: true
		}
		'everforest': Theme{
			name: 'Everforest'
			short_name: 'Everforest'
			background_color: '#2d353b'
			font_color: '#d3c6aa'
			accent_color: '#a7c080'
			secondary_accent: '#7fbbb3'
			card_background: '#232a2e'
			card_border: '#3d484d'
			description: 'Comfortable natural forest green dark palette designed to protect the eyes'
			is_dark: true
		}
		'kanagawa': Theme{
			name: 'Kanagawa'
			short_name: 'Kanagawa'
			background_color: '#1f1f28'
			font_color: '#dcd7ba'
			accent_color: '#7e9cd8'
			secondary_accent: '#957fb8'
			card_background: '#16161d'
			card_border: '#2a2a37'
			description: 'Elegant Japanese ink wash & Great Wave woodblock painting inspired dark theme'
			is_dark: true
		}
		'dracula': Theme{
			name: 'Dracula'
			short_name: 'Dracula'
			background_color: '#282a36'
			font_color: '#f8f8f2'
			accent_color: '#bd93f9'
			secondary_accent: '#ff79c6'
			card_background: '#1e1f29'
			card_border: '#44475a'
			description: 'Classic dark theme with vampire purple, pink, and cyan accents'
			is_dark: true
		}
		'nord': Theme{
			name: 'Nord'
			short_name: 'Nord'
			background_color: '#2e3440'
			font_color: '#eceff4'
			accent_color: '#88c0d0'
			secondary_accent: '#81a1c1'
			card_background: '#242933'
			card_border: '#3b4252'
			description: 'Arctic, north-bluish clean and elegant dark palette'
			is_dark: true
		}
		'catppuccin': Theme{
			name: 'Catppuccin Mocha'
			short_name: 'Catppuccin'
			background_color: '#1e1e2e'
			font_color: '#cdd6f4'
			accent_color: '#cba6f7'
			secondary_accent: '#f38ba8'
			card_background: '#181825'
			card_border: '#313244'
			description: 'Soothing pastel dark theme with lavender and pink hues'
			is_dark: true
		}
		'solarized_dark': Theme{
			name: 'Solarized Dark'
			short_name: 'Solar Dark'
			background_color: '#002b36'
			font_color: '#839496'
			accent_color: '#2aa198'
			secondary_accent: '#b58900'
			card_background: '#073642'
			card_border: '#586e75'
			description: 'Precision engineered teal and cyan dark palette'
			is_dark: true
		}
		'solarized_light': Theme{
			name: 'Solarized Light'
			short_name: 'Solar Light'
			background_color: '#fdf6e3'
			font_color: '#657b83'
			accent_color: '#268bd2'
			secondary_accent: '#d33682'
			card_background: '#eee8d5'
			card_border: '#93a1a1'
			description: 'Precision engineered cream and warm light palette'
			is_dark: false
		}
		'github_dark': Theme{
			name: 'GitHub Dark'
			short_name: 'GitHub Dark'
			background_color: '#0d1117'
			font_color: '#c9d1d9'
			accent_color: '#58a6ff'
			secondary_accent: '#238636'
			card_background: '#161b22'
			card_border: '#30363d'
			description: 'GitHub official dark workspace interface'
			is_dark: true
		}
		'github_light': Theme{
			name: 'GitHub Light'
			short_name: 'GitHub Light'
			background_color: '#ffffff'
			font_color: '#24292f'
			accent_color: '#0969da'
			secondary_accent: '#1a7f37'
			card_background: '#f6f8fa'
			card_border: '#d0d7de'
			description: 'Clean crisp official GitHub light interface'
			is_dark: false
		}

		// Modern Operating Systems
		'sonoma_dark': Theme{
			name: 'macOS Sonoma Dark'
			short_name: 'Sonoma Dark'
			background_color: '#1e1e1e'
			font_color: '#ffffff'
			accent_color: '#007aff'
			secondary_accent: '#5ac8fa'
			card_background: '#2c2c2e'
			card_border: '#3a3a3c'
			description: 'macOS Sonoma dark translucent acrylic interface'
			is_dark: true
		}
		'sonoma_light': Theme{
			name: 'macOS Sonoma Light'
			short_name: 'Sonoma Light'
			background_color: '#f5f5f7'
			font_color: '#1d1d1f'
			accent_color: '#007aff'
			secondary_accent: '#34c759'
			card_background: '#ffffff'
			card_border: '#e5e5ea'
			description: 'Apple HIG human interface guidelines light style'
			is_dark: false
		}
		'sonoma_emerald': Theme{
			name: 'Sonoma Emerald'
			short_name: 'Emerald Mac'
			background_color: '#1a2421'
			font_color: '#e8f5e9'
			accent_color: '#00c853'
			secondary_accent: '#69f0ae'
			card_background: '#23332d'
			card_border: '#2e443c'
			description: 'macOS dark theme with mint emerald accents'
			is_dark: true
		}
		'codefreelance': Theme{
			name: 'CodeFreelance Pro'
			short_name: 'CodeFreelance'
			background_color: '#0d111a'
			font_color: '#f0f6fc'
			accent_color: '#38bdf8'
			secondary_accent: '#a855f7'
			card_background: '#161e2e'
			card_border: '#243048'
			description: 'Ultra sleek cyan neon coding workstation theme'
			is_dark: true
		}
		'fluent_dark': Theme{
			name: 'Windows 11 Fluent Dark'
			short_name: 'Fluent Dark'
			background_color: '#202020'
			font_color: '#ffffff'
			accent_color: '#60cdff'
			secondary_accent: '#76b9ed'
			card_background: '#2c2c2c'
			card_border: '#383838'
			description: 'Windows 11 Fluent Mica and Acrylic dark style'
			is_dark: true
		}
		'fluent_light': Theme{
			name: 'Windows 11 Fluent Light'
			short_name: 'Fluent Light'
			background_color: '#f3f3f3'
			font_color: '#000000'
			accent_color: '#0067c0'
			secondary_accent: '#005fb8'
			card_background: '#ffffff'
			card_border: '#e5e5e5'
			description: 'Windows 11 clean fluent light style'
			is_dark: false
		}

		// Nostalgic & Retro Themes
		'win95': Theme{
			name: 'Windows 95 Classic'
			short_name: 'Win95'
			background_color: '#008080'
			font_color: '#000000'
			accent_color: '#000080'
			secondary_accent: '#808080'
			card_background: '#c0c0c0'
			card_border: '#ffffff'
			description: 'Authentic 90s classic bevel and teal desktop'
			is_dark: false
		}
		'commodore64': Theme{
			name: 'Commodore 64'
			short_name: 'C64'
			background_color: '#40318d'
			font_color: '#8b80db'
			accent_color: '#8b80db'
			secondary_accent: '#a098eb'
			card_background: '#352874'
			card_border: '#5c48b8'
			description: '8-bit nostalgic purple and lavender CRT monitor aesthetic'
			is_dark: true
		}
		'amiga': Theme{
			name: 'Commodore Amiga Workbench'
			short_name: 'Amiga'
			background_color: '#0055aa'
			font_color: '#ffffff'
			accent_color: '#ff8800'
			secondary_accent: '#ffffff'
			card_background: '#ffffff'
			card_border: '#000000'
			description: 'Iconic Amiga OS Topaz workbench blue and orange'
			is_dark: true
		}
		'macintosh_system7': Theme{
			name: 'Macintosh System 7'
			short_name: 'System 7'
			background_color: '#c4c4c4'
			font_color: '#000000'
			accent_color: '#336699'
			secondary_accent: '#666666'
			card_background: '#ffffff'
			card_border: '#000000'
			description: '1991 Apple Macintosh System 7 platinum pinstripe'
			is_dark: false
		}
		'gameboy': Theme{
			name: 'Nintendo Game Boy DMG-01'
			short_name: 'Game Boy'
			background_color: '#8b956d'
			font_color: '#0f380f'
			accent_color: '#306230'
			secondary_accent: '#8bac0f'
			card_background: '#9bbc0f'
			card_border: '#306230'
			description: 'Original 4-shade olive pea-soup Game Boy LCD display'
			is_dark: false
		}
		'matrix_phosphor': Theme{
			name: 'Matrix Green Phosphor'
			short_name: 'Matrix'
			background_color: '#0d110d'
			font_color: '#00ff66'
			accent_color: '#00ff66'
			secondary_accent: '#008833'
			card_background: '#131a13'
			card_border: '#00aa44'
			description: 'Glowing monochrome green CRT mainframe terminal'
			is_dark: true
		}
		'amber_crt': Theme{
			name: 'Amber CRT Terminal'
			short_name: 'Amber CRT'
			background_color: '#140c00'
			font_color: '#ffb000'
			accent_color: '#ff9000'
			secondary_accent: '#cc7000'
			card_background: '#1f1300'
			card_border: '#8a5000'
			description: 'Warm glowing amber VT220 phosphor terminal'
			is_dark: true
		}
		'synthwave84': Theme{
			name: "Synthwave '84"
			short_name: 'Synthwave'
			background_color: '#262335'
			font_color: '#f92aad'
			accent_color: '#f92aad'
			secondary_accent: '#36f9f6'
			card_background: '#1a1824'
			card_border: '#ff7edb'
			description: 'Retro 80s neon grid sunset with hot pink and laser cyan'
			is_dark: true
		}
		'cyberpunk': Theme{
			name: 'Cyberpunk 2077'
			short_name: 'Cyberpunk'
			background_color: '#0a0a10'
			font_color: '#00f5d4'
			accent_color: '#fee715'
			secondary_accent: '#ff007f'
			card_background: '#12121f'
			card_border: '#2a2a44'
			description: 'High contrast electric yellow, neon pink, and cyan'
			is_dark: true
		}

		// Signature Colorways
		'navy_blue': Theme{
			name: 'Navy Blue'
			short_name: 'Navy'
			background_color: '#0a192f'
			font_color: '#e6f1ff'
			accent_color: '#64ffda'
			secondary_accent: '#00b4d8'
			card_background: '#112240'
			card_border: '#233554'
			description: 'Deep oceanic midnight blue with bright aquamarine accents'
			is_dark: true
		}
		'forest_green': Theme{
			name: 'Forest Green'
			short_name: 'Forest'
			background_color: '#0f2018'
			font_color: '#e8f5e9'
			accent_color: '#4ade80'
			secondary_accent: '#22c55e'
			card_background: '#162e24'
			card_border: '#224a3a'
			description: 'Deep woodland green with luminous mint highlights'
			is_dark: true
		}
		'sunset_orange': Theme{
			name: 'Sunset Orange'
			short_name: 'Sunset'
			background_color: '#1a1412'
			font_color: '#fff3e0'
			accent_color: '#ff6f00'
			secondary_accent: '#ff9800'
			card_background: '#261e1b'
			card_border: '#3d302a'
			description: 'Warm dusk twilight with glowing tangerine amber'
			is_dark: true
		}
		'crimson': Theme{
			name: 'Crimson Velvet'
			short_name: 'Crimson'
			background_color: '#1a0c0e'
			font_color: '#ffebee'
			accent_color: '#ef4444'
			secondary_accent: '#f43f5e'
			card_background: '#261216'
			card_border: '#3d1c23'
			description: 'Dramatic dark luxury crimson ruby and scarlet'
			is_dark: true
		}
		'emerald': Theme{
			name: 'Emerald Jewel'
			short_name: 'Emerald'
			background_color: '#061a14'
			font_color: '#e6fffa'
			accent_color: '#10b981'
			secondary_accent: '#059669'
			card_background: '#0d2820'
			card_border: '#163d32'
			description: 'Precious gemstone deep green and jade highlights'
			is_dark: true
		}
		'sapphire': Theme{
			name: 'Sapphire Royal'
			short_name: 'Sapphire'
			background_color: '#081426'
			font_color: '#e0f2fe'
			accent_color: '#0284c7'
			secondary_accent: '#38bdf8'
			card_background: '#0f2038'
			card_border: '#1b3356'
			description: 'Deep royal blue with crisp azure and celestial brights'
			is_dark: true
		}
		'amethyst': Theme{
			name: 'Amethyst Purple'
			short_name: 'Amethyst'
			background_color: '#160d24'
			font_color: '#f3e8ff'
			accent_color: '#a855f7'
			secondary_accent: '#c084fc'
			card_background: '#201335'
			card_border: '#331f54'
			description: 'Mystical crystal purple with vibrant lavender accents'
			is_dark: true
		}
		'midnight': Theme{
			name: 'Midnight Black'
			short_name: 'Midnight'
			background_color: '#000000'
			font_color: '#f8fafc'
			accent_color: '#38bdf8'
			secondary_accent: '#818cf8'
			card_background: '#111111'
			card_border: '#262626'
			description: 'Pure OLED true pitch black with sharp ice-blue accents'
			is_dark: true
		}
		'charcoal': Theme{
			name: 'Charcoal Minimal'
			short_name: 'Charcoal'
			background_color: '#18181b'
			font_color: '#f4f4f5'
			accent_color: '#a1a1aa'
			secondary_accent: '#71717a'
			card_background: '#27272a'
			card_border: '#3f3f46'
			description: 'Understated matte graphite industrial modern aesthetic'
			is_dark: true
		}
		'slate': Theme{
			name: 'Slate Tech'
			short_name: 'Slate'
			background_color: '#0f172a'
			font_color: '#f8fafc'
			accent_color: '#94a3b8'
			secondary_accent: '#64748b'
			card_background: '#1e293b'
			card_border: '#334155'
			description: 'Balanced slate gray corporate developer workstation'
			is_dark: true
		}
		'dark': Theme{
			name: 'Standard Dark'
			short_name: 'Dark'
			background_color: '#121212'
			font_color: '#ffffff'
			accent_color: '#38bdf8'
			secondary_accent: '#0284c7'
			card_background: '#1e1e1e'
			card_border: '#2e2e2e'
			description: 'Standard modern dark theme'
			is_dark: true
		}
		'light': Theme{
			name: 'Standard Light'
			short_name: 'Light'
			background_color: '#f8fafc'
			font_color: '#0f172a'
			accent_color: '#0284c7'
			secondary_accent: '#38bdf8'
			card_background: '#ffffff'
			card_border: '#e2e8f0'
			description: 'Standard clean modern light theme'
			is_dark: false
		}
	}
}

pub fn get_theme(name string) Theme {
	themes := get_all_themes()
	clean := name.to_lower().trim_space().replace(' ', '_').replace('-', '_')
	if t := themes[clean] {
		return t
	}
	// Common aliases
	alias_map := {
		'gruvbox': 'gruvbox_dark'
		'one_dark': 'one_dark_pro'
		'synthwave_84': 'synthwave84'
		'catppuccin_mocha': 'catppuccin'
		'macos_sonoma': 'sonoma_dark'
		'macos_dark': 'sonoma_dark'
		'macos_light': 'sonoma_light'
		'windows_11_fluent': 'fluent_dark'
		'windows_11_dark': 'fluent_dark'
		'windows_11_light': 'fluent_light'
		'windows_95': 'win95'
		'commodore_64': 'commodore64'
		'amiga_workbench': 'amiga'
		'atari_st': 'amiga'
		'mac_system_7': 'macintosh_system7'
		'matrix': 'matrix_phosphor'
		'amber': 'amber_crt'
		'vibrant_neon': 'cyberpunk'
		'vscode_dark': 'one_dark_pro'
		'sublime_text': 'monokai_pro'
		'material_dark': 'one_dark_pro'
	}
	if resolved := alias_map[clean] {
		if t := themes[resolved] {
			return t
		}
	}
	for k, t in themes {
		if k.contains(clean) || clean.contains(k) {
			return t
		}
	}
	return themes['monokai_pro'] or {
		Theme{
			name: 'Default Dark'
			short_name: 'Dark'
			background_color: '#1e1e2e'
			font_color: '#cdd6f4'
			accent_color: '#cba6f7'
			secondary_accent: '#f38ba8'
			card_background: '#181825'
			card_border: '#313244'
			description: 'Default fallback theme'
			is_dark: true
		}
	}
}

pub fn hex_to_contrast_color(hex_str string) string {
	clean := hex_str.trim_space().trim_string_left('#')
	if clean.len == 6 {
		r := ('0x' + clean[0..2]).int()
		g := ('0x' + clean[2..4]).int()
		b := ('0x' + clean[4..6]).int()
		lum := (r * 299 + g * 587 + b * 114) / 1000
		if lum > 145 {
			return '#111111'
		}
	}
	return '#ffffff'
}

pub fn get_themes_json() string {
	mut out := '{'
	themes := get_all_themes()
	mut first := true
	for k, t in themes {
		if !first {
			out += ','
		}
		first = false
		btn_txt := hex_to_contrast_color(t.accent_color)
		out += '"${k}":{"name":"${t.name}","background_color":"${t.background_color}","font_color":"${t.font_color}","accent_color":"${t.accent_color}","secondary_accent":"${t.secondary_accent}","card_background":"${t.card_background}","card_border":"${t.card_border}","btn_text":"${btn_txt}"}'
	}
	out += '}'
	return out
}

pub fn get_theme_names() []string {
	return [
		'monokai_pro', 'tokyo_night', 'one_dark_pro', 'gruvbox_dark', 'gruvbox_light',
		'rose_pine', 'everforest', 'kanagawa', 'dracula', 'nord',
		'catppuccin', 'solarized_dark', 'solarized_light', 'github_dark', 'github_light',
		'sonoma_dark', 'sonoma_light', 'sonoma_emerald', 'codefreelance',
		'fluent_dark', 'fluent_light', 'win95', 'commodore64', 'amiga',
		'macintosh_system7', 'gameboy', 'matrix_phosphor', 'amber_crt',
		'synthwave84', 'cyberpunk', 'navy_blue', 'forest_green',
		'sunset_orange', 'crimson', 'emerald', 'sapphire',
		'amethyst', 'midnight', 'charcoal', 'slate', 'dark', 'light'
	]
}

pub fn list_themes() []string {
	return get_theme_names()
}

pub fn get_saved_theme() string {
	config_file := os.join_path(os.home_dir(), '.config', 'simplegui', 'theme.txt')
	if os.exists(config_file) {
		name := os.read_file(config_file) or { '' }.trim_space()
		if name != '' {
			return name
		}
	}
	return 'tokyo_night'
}

pub fn save_theme(theme_name string) bool {
	config_dir := os.join_path(os.home_dir(), '.config', 'simplegui')
	if !os.exists(config_dir) {
		os.mkdir_all(config_dir) or { return false }
	}
	config_file := os.join_path(config_dir, 'theme.txt')
	os.write_file(config_file, theme_name) or { return false }
	return true
}
