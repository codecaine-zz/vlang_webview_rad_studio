module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 22 - Context Menu & Desktop Menubar Showcase'
		width: 1100
		height: 750
		theme: 'tokyo_night'
		fullscreen: true
	)

	// 1. Configure Full Desktop Menubar
	categories := [
		simplegui.MenuCategory{
			title: '📁 File'
			items: [
				simplegui.MenuItem{ text: '📄 New File', action: 'file_new', shortcut: 'Cmd+N' },
				simplegui.MenuItem{ text: '📂 Open File...', action: 'file_open', shortcut: 'Cmd+O' },
				simplegui.MenuItem{ text: '💾 Save Project', action: 'file_save', shortcut: 'Cmd+S' },
				simplegui.MenuItem{ text: '', action: '', is_divider: true },
				simplegui.MenuItem{ text: '🚪 Quit RAD Studio', action: 'app_quit', shortcut: 'Cmd+Q' },
			]
		},
		simplegui.MenuCategory{
			title: '✏️ Edit'
			items: [
				simplegui.MenuItem{ text: '↩️ Undo', action: 'edit_undo', shortcut: 'Cmd+Z' },
				simplegui.MenuItem{ text: '↪️ Redo', action: 'edit_redo', shortcut: 'Cmd+Y' },
				simplegui.MenuItem{ text: '', action: '', is_divider: true },
				simplegui.MenuItem{ text: '✂️ Cut', action: 'edit_cut', shortcut: 'Cmd+X' },
				simplegui.MenuItem{ text: '📋 Copy', action: 'edit_copy', shortcut: 'Cmd+C' },
				simplegui.MenuItem{ text: '📥 Paste', action: 'edit_paste', shortcut: 'Cmd+V' },
				simplegui.MenuItem{ text: '', action: '', is_divider: true },
				simplegui.MenuItem{ text: '🔘 Select All', action: 'edit_select_all', shortcut: 'Cmd+A' },
			]
		},
		simplegui.MenuCategory{
			title: '👁️ View'
			items: [
				simplegui.MenuItem{ text: '⛶ Toggle Fullscreen', action: 'view_fullscreen', shortcut: 'Cmd+F' },
				simplegui.MenuItem{ text: '', action: '', is_divider: true },
				simplegui.MenuItem{ text: '🎨 Tokyo Night', action: 'theme_tokyo_night' },
				simplegui.MenuItem{ text: '🎨 Monokai Pro', action: 'theme_monokai_pro' },
				simplegui.MenuItem{ text: '🎨 Cyberpunk 2077', action: 'theme_cyberpunk' },
				simplegui.MenuItem{ text: '🎨 GitHub Light', action: 'theme_github_light' },
				simplegui.MenuItem{ text: '🎨 Matrix Phosphor', action: 'theme_matrix_phosphor' },
			]
		},
		simplegui.MenuCategory{
			title: '🪟 Window'
			items: [
				simplegui.MenuItem{ text: '🗕 Minimize Window', action: 'win_minimize', shortcut: 'Cmd+M' },
				simplegui.MenuItem{ text: '📌 Stay On Top', action: 'win_pin', shortcut: 'Cmd+Shift+T' },
				simplegui.MenuItem{ text: '🎯 Center On Screen', action: 'win_center', shortcut: 'Cmd+Shift+C' },
			]
		},
		simplegui.MenuCategory{
			title: '❓ Help'
			items: [
				simplegui.MenuItem{ text: '📖 Documentation', action: 'help_docs' },
				simplegui.MenuItem{ text: '⌨️ Shortcuts Reference', action: 'help_shortcuts' },
				simplegui.MenuItem{ text: 'ℹ️ About RAD Studio', action: 'help_about' },
			]
		},
	]

	win.set_menubar(categories, fn (mut w simplegui.SimpleWindow, action string) {
		match action {
			'view_fullscreen' { w.toggle_fullscreen() }
			'win_minimize' { w.minimize() }
			'win_pin' { w.set_always_on_top(true) }
			'win_center' { w.center() }
			'theme_tokyo_night' { w.set_theme('tokyo_night') }
			'theme_monokai_pro' { w.set_theme('monokai_pro') }
			'theme_cyberpunk' { w.set_theme('cyberpunk') }
			'theme_github_light' { w.set_theme('github_light') }
			'theme_matrix_phosphor' { w.set_theme('matrix_phosphor') }
			'app_quit' { exit(0) }
			else {
				w.notification('Menubar Action', 'Executed command: ${action}')
			}
		}
	})

	// 2. Configure Desktop Right-Click Floating Context Menu
	context_items := [
		simplegui.MenuItem{ text: '📋 Copy Selection', action: 'ctx_copy', shortcut: 'Cmd+C' },
		simplegui.MenuItem{ text: '✂️ Cut Selection', action: 'ctx_cut', shortcut: 'Cmd+X' },
		simplegui.MenuItem{ text: '📥 Paste Clipboard', action: 'ctx_paste', shortcut: 'Cmd+V' },
		simplegui.MenuItem{ text: '', action: '', is_divider: true },
		simplegui.MenuItem{ text: '⛶ Toggle Fullscreen', action: 'ctx_fullscreen', shortcut: 'Cmd+F' },
		simplegui.MenuItem{ text: '📌 Stay On Top', action: 'ctx_pin', shortcut: 'Cmd+Shift+T' },
		simplegui.MenuItem{ text: '🎯 Center Window', action: 'ctx_center', shortcut: 'Cmd+Shift+C' },
		simplegui.MenuItem{ text: '', action: '', is_divider: true },
		simplegui.MenuItem{ text: '🎨 Tokyo Night', action: 'ctx_theme_tokyo' },
		simplegui.MenuItem{ text: '🎨 Monokai Pro', action: 'ctx_theme_monokai' },
		simplegui.MenuItem{ text: '🎨 Cyberpunk', action: 'ctx_theme_cyberpunk' },
		simplegui.MenuItem{ text: '', action: '', is_divider: true },
		simplegui.MenuItem{ text: '❌ Exit Application', action: 'ctx_quit', shortcut: 'Cmd+Q' },
	]

	win.set_context_menu(context_items, fn (mut w simplegui.SimpleWindow, action string) {
		match action {
			'ctx_fullscreen' { w.toggle_fullscreen() }
			'ctx_pin' { w.set_always_on_top(true) }
			'ctx_center' { w.center() }
			'ctx_theme_tokyo' { w.set_theme('tokyo_night') }
			'ctx_theme_monokai' { w.set_theme('monokai_pro') }
			'ctx_theme_cyberpunk' { w.set_theme('cyberpunk') }
			'ctx_quit' { exit(0) }
			else {
				w.notification('Context Menu', 'Right-click action selected: ${action}')
			}
		}
	})

	// 3. UI Controls Layout
	win.heading('📋 Desktop Menubar & Context Menu Showcase')
	win.subheading('Interactive top menubar dropdowns, custom right-click context menu, and keyboard shortcuts')
	win.divider()

	win.box_start('🖱️ How to Test Menus')
	win.label('1. Click any menu item in the TOP MENUBAR (File, Edit, View, Window, Help) to open dropdowns.')
	win.label('2. RIGHT-CLICK ANYWHERE in this window to open the custom floating context menu.')
	win.label('3. Browser default right-click menu (inspect element & reload) is completely disabled.')
	win.label('4. Try keyboard shortcuts: Cmd+F (Fullscreen), Cmd+M (Minimize), Cmd+Shift+T (Pin), Cmd+Shift+C (Center).')
	win.box_end()

	win.box_start('Interactive Quick Actions')
	win.row_start()
	win.button('⛶ Toggle Fullscreen (Cmd+F)', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.button('📌 Pin Stay On Top (Cmd+Shift+T)', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_always_on_top(true)
		w.notification('Window Pin', 'Window pinned always-on-top.')
	})
	win.button('🎯 Center Window (Cmd+Shift+C)', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.button('🎨 Switch to Cyberpunk', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('cyberpunk')
	})
	win.button('🎨 Switch to Tokyo Night', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_theme('tokyo_night')
	})
	win.row_end()
	win.box_end()

	win.box_start('Right-Click Canvas Workspace')
	win.textarea('Context Area', 'Right click inside this workspace area to trigger custom desktop actions.\nNotice how the browser default menu is suppressed and replaced with our custom floating menu.', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Menubar & Context Menu Engine: Active | Loaded in Fullscreen Mode')

	win.run()
}
