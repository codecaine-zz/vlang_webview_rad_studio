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
		'raycast_dark': Theme{
			name: 'Raycast Dark'
			short_name: 'Raycast'
			background_color: '#0e0f12'
			font_color: '#f3f4f6'
			accent_color: '#ff6363'
			secondary_accent: '#ff9494'
			card_background: '#18191e'
			card_border: '#282a32'
			description: 'Silicon Valley developer command palette with ultra-slick charcoal surfaces and laser red'
			is_dark: true
		}
		'linear_dark': Theme{
			name: 'Linear Studio'
			short_name: 'Linear'
			background_color: '#0f1015'
			font_color: '#e2e4ed'
			accent_color: '#5e6ad2'
			secondary_accent: '#8e9df6'
			card_background: '#181922'
			card_border: '#282a3a'
			description: 'High-craft Linear project workspace with deep obsidian cards and electric indigo accents'
			is_dark: true
		}
		'vercel_dark': Theme{
			name: 'Vercel Geist'
			short_name: 'Geist'
			background_color: '#000000'
			font_color: '#ededed'
			accent_color: '#ffffff'
			secondary_accent: '#0070f3'
			card_background: '#0a0a0a'
			card_border: '#242424'
			description: 'Ultra-minimalist Next.js & Vercel design system with pure monochrome contrast and electric blue'
			is_dark: true
		}
		'unreal_engine': Theme{
			name: 'Unreal Engine 5'
			short_name: 'UE5'
			background_color: '#18191c'
			font_color: '#e1e2e6'
			accent_color: '#0e86d4'
			secondary_accent: '#e5a93c'
			card_background: '#222328'
			card_border: '#33353e'
			description: 'Epic Games Unreal Engine 5 professional workstation with dark graphite & Blueprint blue'
			is_dark: true
		}
		'arc_velvet': Theme{
			name: 'Arc Velvet'
			short_name: 'Arc Velvet'
			background_color: '#170f26'
			font_color: '#f8f6fc'
			accent_color: '#f72585'
			secondary_accent: '#4cc9f0'
			card_background: '#23183a'
			card_border: '#3d2b63'
			description: 'Arc Browser velvet aesthetic with deep plum indigo and luminous neon magenta accents'
			is_dark: true
		}
		'abyss': Theme{
			name: 'Abyss Bioluminescence'
			short_name: 'Abyss'
			background_color: '#030712'
			font_color: '#f0fdfa'
			accent_color: '#06b6d4'
			secondary_accent: '#3b82f6'
			card_background: '#0b1329'
			card_border: '#16274e'
			description: 'Deep oceanic trench dark theme with radiant bioluminescent cyan and marine slate'
			is_dark: true
		}
		'night_city': Theme{
			name: 'Cyberpunk Night City'
			short_name: 'Night City'
			background_color: '#0e0e13'
			font_color: '#fcee0a'
			accent_color: '#ff003c'
			secondary_accent: '#00f0ff'
			card_background: '#171720'
			card_border: '#2e2e3f'
			description: 'AAA Cyberpunk 2077 Night City HUD with Trauma Team red, Samurai yellow and chrome cards'
			is_dark: true
		}
		'horizon': Theme{
			name: 'Horizon Sunset'
			short_name: 'Horizon'
			background_color: '#1c1e26'
			font_color: '#fdf0ed'
			accent_color: '#e95678'
			secondary_accent: '#fab795'
			card_background: '#232530'
			card_border: '#34384a'
			description: 'Warm twilight horizon spectrum with glowing neon coral, peach and dusk plum'
			is_dark: true
		}
		'tailwind_dark': Theme{
			name: 'Tailwind Slate Emerald'
			short_name: 'Tailwind'
			background_color: '#0b1120'
			font_color: '#f1f5f9'
			accent_color: '#10b981'
			secondary_accent: '#06b6d4'
			card_background: '#151e32'
			card_border: '#24324f'
			description: 'Modern Tailwind CSS flagship developer theme with deep slate 950 and vibrant emerald'
			is_dark: true
		}
		'supabase': Theme{
			name: 'Supabase Dark'
			short_name: 'Supabase'
			background_color: '#121212'
			font_color: '#f8fafc'
			accent_color: '#3ecf8e'
			secondary_accent: '#70e1a5'
			card_background: '#1c1c1c'
			card_border: '#2e2e2e'
			description: 'Supabase cloud database dashboard with sleek dark obsidian and signature emerald'
			is_dark: true
		}
		'oled_black': Theme{
			name: 'OLED Laser Black'
			short_name: 'OLED Laser'
			background_color: '#000000'
			font_color: '#ffffff'
			accent_color: '#00e676'
			secondary_accent: '#2979ff'
			card_background: '#0a0a0a'
			card_border: '#222222'
			description: 'Zero-power pure OLED black canvas with ultra-sharp laser green and high-contrast cards'
			is_dark: true
		}
		'titanium_slate': Theme{
			name: 'Titanium Slate Pro'
			short_name: 'Titanium'
			background_color: '#131417'
			font_color: '#e5e5ea'
			accent_color: '#ff6b22'
			secondary_accent: '#98989d'
			card_background: '#1c1d22'
			card_border: '#2f3038'
			description: 'Apple Pro hardware grade aerospace titanium space black with aviation orange accents'
			is_dark: true
		}
		'jetbrains_darcula': Theme{
			name: 'JetBrains Darcula'
			short_name: 'Darcula'
			background_color: '#2b2b2b'
			font_color: '#a9b7c6'
			accent_color: '#cc7832'
			secondary_accent: '#6897bb'
			card_background: '#313335'
			card_border: '#45484a'
			description: 'Iconic JetBrains IntelliJ IDEA / PyCharm Darcula IDE workspace with warm syntax orange'
			is_dark: true
		}
		'nordic_paper': Theme{
			name: 'Nordic Paper Light'
			short_name: 'Nordic Paper'
			background_color: '#f7f7f5'
			font_color: '#202124'
			accent_color: '#2b5c8f'
			secondary_accent: '#c2593f'
			card_background: '#ffffff'
			card_border: '#e0ded8'
			description: 'Nordic editorial paper light canvas with deep fjord blue and crisp typographic elegance'
			is_dark: false
		}
		'cobalt2': Theme{
			name: 'Cobalt2'
			short_name: 'Cobalt2'
			background_color: '#193549'
			font_color: '#ffffff'
			accent_color: '#ffc600'
			secondary_accent: '#0088ff'
			card_background: '#15232d'
			card_border: '#1f4662'
			description: 'Wes Bos official Cobalt2 deep navy blue with brilliant canary yellow accents'
			is_dark: true
		}
		'win11_slate': Theme{
			name: 'Windows 11 Fluent Slate'
			short_name: 'Win11 Slate'
			background_color: '#202020'
			font_color: '#ffffff'
			accent_color: '#60cdff'
			secondary_accent: '#0078d4'
			card_background: '#2c2c2c'
			card_border: '#383838'
			description: 'Modern Windows 11 Fluent Dark Acrylic with vibrant sky blue accents'
			is_dark: true
		}
		'win11_light': Theme{
			name: 'Windows 11 Mica Light'
			short_name: 'Mica Light'
			background_color: '#f3f3f3'
			font_color: '#1b1b1b'
			accent_color: '#005fb8'
			secondary_accent: '#0078d4'
			card_background: '#ffffff'
			card_border: '#e5e5e5'
			description: 'Modern Windows 11 Mica Light desktop with crisp Fluent typography'
			is_dark: false
		}
		'ubuntu_dark': Theme{
			name: 'Ubuntu Yaru Dark'
			short_name: 'Ubuntu Dark'
			background_color: '#242424'
			font_color: '#ffffff'
			accent_color: '#e95420'
			secondary_accent: '#77216f'
			card_background: '#303030'
			card_border: '#424242'
			description: 'Official Ubuntu Yaru modern Linux dark desktop with warm aubergine charcoal surfaces and signature Ubuntu orange accents'
			is_dark: true
		}
		'ubuntu_light': Theme{
			name: 'Ubuntu Yaru Light'
			short_name: 'Ubuntu Light'
			background_color: '#f7f7f7'
			font_color: '#1e1e1e'
			accent_color: '#e95420'
			secondary_accent: '#77216f'
			card_background: '#ffffff'
			card_border: '#dedede'
			description: 'Clean Ubuntu Yaru modern Linux light desktop with crisp white surfaces, warm gray borders, and vibrant Ubuntu orange'
			is_dark: false
		}
		'adwaita_dark': Theme{
			name: 'GNOME Adwaita Dark'
			short_name: 'Adwaita Dark'
			background_color: '#242424'
			font_color: '#ffffff'
			accent_color: '#3584e4'
			secondary_accent: '#1c71d8'
			card_background: '#303030'
			card_border: '#3d3d3d'
			description: 'Modern GNOME Libadwaita desktop theme with deep slate surfaces and signature Adwaita blue accents'
			is_dark: true
		}
		'adwaita_light': Theme{
			name: 'GNOME Adwaita Light'
			short_name: 'Adwaita Light'
			background_color: '#fafafa'
			font_color: '#2e3436'
			accent_color: '#3584e4'
			secondary_accent: '#1c71d8'
			card_background: '#ffffff'
			card_border: '#dcdcdc'
			description: 'Clean GNOME Libadwaita light desktop with neutral paper surfaces and signature blue controls'
			is_dark: false
		}
		'linux_mint': Theme{
			name: 'Linux Mint Dark'
			short_name: 'Linux Mint'
			background_color: '#2f343f'
			font_color: '#e0e2e4'
			accent_color: '#87a556'
			secondary_accent: '#2ebd59'
			card_background: '#242831'
			card_border: '#3e4453'
			description: 'Modern Linux Mint Cinnamon desktop theme with slate graphite surfaces and signature mint green accents'
			is_dark: true
		}
		'pop_os': Theme{
			name: 'Pop!_OS Dark'
			short_name: 'Pop!_OS'
			background_color: '#202222'
			font_color: '#f6f6f6'
			accent_color: '#48b9c7'
			secondary_accent: '#faa41a'
			card_background: '#2c2e2e'
			card_border: '#3d4040'
			description: 'System76 Pop!_OS and COSMIC modern Linux desktop with dark charcoal surfaces and signature teal and amber accents'
			is_dark: true
		}
		'fedora_dark': Theme{
			name: 'Fedora Blue'
			short_name: 'Fedora'
			background_color: '#1f232a'
			font_color: '#ffffff'
			accent_color: '#51a2da'
			secondary_accent: '#294172'
			card_background: '#292e38'
			card_border: '#3b4250'
			description: 'Official Fedora Workstation modern Linux theme with navy graphite cards and crisp Fedora blue'
			is_dark: true
		}
		'aura': Theme{
			name: 'Aura Dark'
			short_name: 'Aura'
			background_color: '#15141b'
			font_color: '#edecee'
			accent_color: '#a277ff'
			secondary_accent: '#61ffca'
			card_background: '#1f1d2b'
			card_border: '#322f44'
			description: 'Lush mystical dark theme with ethereal neon purple and mint green accents'
			is_dark: true
		}
		'apple_dark': Theme{
			name: 'Apple Dark'
			short_name: 'Dark'
			background_color: '#161618'
			font_color: '#f5f5f7'
			accent_color: '#0a84ff'
			secondary_accent: '#bf5af2'
			card_background: '#242426'
			card_border: '#38383a'
			description: 'Vibrant Apple macOS Dark Mode surface with titanium gray cards and iOS system blue'
			is_dark: true
		}
		'apple_light': Theme{
			name: 'Apple Light'
			short_name: 'Light'
			background_color: '#f5f5f7'
			font_color: '#1d1d1f'
			accent_color: '#0071e3'
			secondary_accent: '#5e5ce6'
			card_background: '#ffffff'
			card_border: '#e5e5e7'
			description: 'Clean Apple macOS Aqua light canvas with SF Pro typography and Cupertino system blue'
			is_dark: false
		}
		'ventura_amber': Theme{
			name: 'Ventura Amber'
			short_name: 'Ventura'
			background_color: '#1c140e'
			font_color: '#fffbeb'
			accent_color: '#ff9500'
			secondary_accent: '#f97316'
			card_background: '#281e16'
			card_border: '#3d2f24'
			description: 'macOS Ventura golden sunset dark hues with warm amber and roasted espresso cards'
			is_dark: true
		}
		'apple_sunset': Theme{
			name: 'Apple Sunset'
			short_name: 'Sunset'
			background_color: '#221526'
			font_color: '#fdf4f8'
			accent_color: '#ff7733'
			secondary_accent: '#e056fd'
			card_background: '#2d1e33'
			card_border: '#46314f'
			description: 'Warm macOS Mojave twilight sunset hues with rich plum surfaces and neon amber accents'
			is_dark: true
		}
		'soft_pastel': Theme{
			name: 'Soft Pastel'
			short_name: 'Pastel'
			background_color: '#f9f6f0'
			font_color: '#1c1917'
			accent_color: '#c05638'
			secondary_accent: '#3d405b'
			card_background: '#ffffff'
			card_border: '#e7dfd5'
			description: 'Apple Studio warm soft linen light theme with terracotta coral and artisan cards'
			is_dark: false
		}
		'nextstep': Theme{
			name: 'NeXTSTEP 1989'
			short_name: 'NeXTSTEP'
			background_color: '#262626'
			font_color: '#dedede'
			accent_color: '#4a90e2'
			secondary_accent: '#707070'
			card_background: '#333333'
			card_border: '#4d4d4d'
			description: 'Steve Jobs 1989 NeXTSTEP UNIX workstation dark minimalist elegance'
			is_dark: true
		}
		'mac_os_aqua': Theme{
			name: 'Mac OS X Aqua'
			short_name: 'OS X Aqua'
			background_color: '#e6ebed'
			font_color: '#0f172a'
			accent_color: '#0066cc'
			secondary_accent: '#ff9500'
			card_background: '#ffffff'
			card_border: '#bac7cd'
			description: 'Early 2001 OS X Cheetah glossy gel buttons and brushed pinstripes'
			is_dark: false
		}
		'hotdog_stand': Theme{
			name: 'Hot Dog Stand'
			short_name: 'Hot Dog'
			background_color: '#000000'
			font_color: '#ffffff'
			accent_color: '#ff0000'
			secondary_accent: '#ffff00'
			card_background: '#1c0000'
			card_border: '#ffff00'
			description: 'Unforgettable Windows 3.1 1992 Hot Dog Stand high-contrast yellow & red'
			is_dark: true
		}
		'playstation': Theme{
			name: 'PlayStation 1994'
			short_name: 'PlayStation'
			background_color: '#1e1e24'
			font_color: '#e4e5eb'
			accent_color: '#00d2c4'
			secondary_accent: '#f44336'
			card_background: '#2a2b34'
			card_border: '#3f414f'
			description: '1994 PSX console grey with iconic geometric controller accents'
			is_dark: true
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
		'raycast': 'raycast_dark'
		'linear': 'linear_dark'
		'vercel': 'vercel_dark'
		'geist': 'vercel_dark'
		'ue5': 'unreal_engine'
		'arc_browser': 'arc_velvet'
		'abyss_bio': 'abyss'
		'deep_ocean': 'abyss'
		'cyberpunk_2077': 'night_city'
		'solar_dusk': 'horizon'
		'tailwind': 'tailwind_dark'
		'tailwind_emerald': 'tailwind_dark'
		'supabase_dark': 'supabase'
		'oled_laser': 'oled_black'
		'pure_black': 'oled_black'
		'titanium': 'titanium_slate'
		'darcula_ide': 'jetbrains_darcula'
		'jetbrains': 'jetbrains_darcula'
		'nordic': 'nordic_paper'
		'paper_light': 'nordic_paper'
		'cobalt': 'cobalt2'
		'fluent_slate': 'win11_slate'
		'mica_light': 'win11_light'
		'ubuntu': 'ubuntu_dark'
		'ubuntu_yaru': 'ubuntu_dark'
		'yaru_dark': 'ubuntu_dark'
		'yaru_light': 'ubuntu_light'
		'adwaita': 'adwaita_dark'
		'gnome_dark': 'adwaita_dark'
		'libadwaita': 'adwaita_dark'
		'gnome_light': 'adwaita_light'
		'mint_dark': 'linux_mint'
		'mint': 'linux_mint'
		'cosmic_dark': 'pop_os'
		'pop_dark': 'pop_os'
		'fedora': 'fedora_dark'
		'aura_dark': 'aura'
		'aqua_os_x': 'mac_os_aqua'
		'psx': 'playstation'
		'c64': 'commodore64'
		'mac_classic': 'macintosh_system7'
		'synthwave': 'synthwave84'
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
	mut names := [
		'abyss',
		'adwaita_dark',
		'adwaita_light',
		'amber_crt',
		'amethyst',
		'amiga',
		'apple_dark',
		'apple_light',
		'apple_sunset',
		'arc_velvet',
		'aura',
		'catppuccin',
		'charcoal',
		'cobalt2',
		'codefreelance',
		'commodore64',
		'crimson',
		'cyberpunk',
		'dark',
		'dracula',
		'emerald',
		'everforest',
		'fedora_dark',
		'fluent_dark',
		'fluent_light',
		'forest_green',
		'gameboy',
		'github_dark',
		'github_light',
		'gruvbox_dark',
		'gruvbox_light',
		'horizon',
		'hotdog_stand',
		'jetbrains_darcula',
		'kanagawa',
		'light',
		'linear_dark',
		'linux_mint',
		'mac_os_aqua',
		'macintosh_system7',
		'matrix_phosphor',
		'midnight',
		'monokai_pro',
		'navy_blue',
		'nextstep',
		'night_city',
		'nord',
		'nordic_paper',
		'oled_black',
		'one_dark_pro',
		'playstation',
		'pop_os',
		'raycast_dark',
		'rose_pine',
		'sapphire',
		'slate',
		'soft_pastel',
		'solarized_dark',
		'solarized_light',
		'sonoma_dark',
		'sonoma_emerald',
		'sonoma_light',
		'sunset_orange',
		'supabase',
		'synthwave84',
		'tailwind_dark',
		'titanium_slate',
		'tokyo_night',
		'ubuntu_dark',
		'ubuntu_light',
		'unreal_engine',
		'ventura_amber',
		'vercel_dark',
		'win11_light',
		'win11_slate',
		'win95',
	]
	names.sort()
	return names
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
