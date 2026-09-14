module main

import simplegui
import system
import os
import time

struct FileItem {
	name           string
	path           string
	is_dir         bool
	size_bytes     u64
	formatted_size string
	type_name      string
	icon           string
	permissions    string
	mod_time       string
}

fn get_file_type_and_icon(filename string, is_dir bool) (string, string) {
	if is_dir {
		return '📁', 'Folder'
	}
	ext := os.file_ext(filename).to_lower()
	return match ext {
		'.v' { '⚡', 'V Source Code' }
		'.c', '.h', '.cpp', '.cc', '.m' { '⚙️', 'C/C++ Source' }
		'.py', '.rb', '.pl' { '🐍', 'Script File' }
		'.js', '.ts', '.jsx', '.tsx' { '📜', 'JavaScript/TypeScript' }
		'.json' { '🔍', 'JSON Document' }
		'.csv', '.tsv' { '📊', 'CSV/TSV Matrix' }
		'.md', '.markdown' { '📝', 'Markdown Document' }
		'.txt', '.log' { '📄', 'Plain Text' }
		'.html', '.htm', '.css' { '🌐', 'Web Document' }
		'.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.ico' { '🖼️', 'Image File' }
		'.mp3', '.wav', '.ogg', '.flac', '.m4a' { '🎵', 'Audio File' }
		'.mp4', '.mov', '.avi', '.mkv', '.webm' { '🎬', 'Video File' }
		'.zip', '.tar', '.gz', '.tgz', '.bz2', '.xz', '.7z' { '📦', 'Archive File' }
		'.pdf' { '📑', 'PDF Document' }
		'.db', '.sqlite', '.sqlite3' { '🗄️', 'Database File' }
		'.sh', '.bash', '.zsh', '.vsh' { '⚡', 'Shell Script' }
		'.app', '.exe' { '🚀', 'Executable Application' }
		else { '📄', 'File' }
	}
}

fn scan_directory(dir_path string, sort_mode string, filter_text string) ![]FileItem {
	real_dir := os.real_path(dir_path)
	if !os.is_dir(real_dir) {
		return error('Target path is not a valid directory: ${real_dir}')
	}

	entries := os.ls(real_dir) or { return error('Failed to list directory contents: ${err}') }

	mut items := []FileItem{}
	lower_filter := filter_text.trim_space().to_lower()

	for entry in entries {
		// Ignore common VCS dotfiles if filtering is active or by default skip .DS_Store
		if entry == '.DS_Store' {
			continue
		}
		if lower_filter != '' && !entry.to_lower().contains(lower_filter) {
			continue
		}

		full_path := os.join_path(real_dir, entry)
		is_dir := os.is_dir(full_path)
		icon, type_name := get_file_type_and_icon(entry, is_dir)

		mod_unix := os.file_last_mod_unix(full_path)
		mod_time_str := if mod_unix > 0 { time.unix(mod_unix).format_ss() } else { 'Unknown' }

		mut size_bytes := u64(0)
		mut formatted_size := ''
		mut perms := if is_dir { 'drwxr-xr-x' } else { '-rw-r--r--' }

		if is_dir {
			child_count := (os.ls(full_path) or { []string{} }).len
			formatted_size = '${child_count} items'
		} else {
			size_bytes = os.file_size(full_path)
			formatted_size = system.format_bytes(size_bytes)
			if os.is_executable(full_path) {
				perms = '-rwxr-xr-x'
			}
		}

		items << FileItem{
			name: entry
			path: full_path
			is_dir: is_dir
			size_bytes: size_bytes
			formatted_size: formatted_size
			type_name: type_name
			icon: icon
			permissions: perms
			mod_time: mod_time_str
		}
	}

	// Always sort directories first, then apply sort criteria
	items.sort_with_compare(fn [sort_mode] (a &FileItem, b &FileItem) int {
		if a.is_dir && !b.is_dir {
			return -1
		}
		if !a.is_dir && b.is_dir {
			return 1
		}
		return match sort_mode {
			'Sort: Name (Z-A)' {
				if a.name.to_lower() > b.name.to_lower() { -1 } else { 1 }
			}
			'Sort: Size (Largest)' {
				if a.size_bytes > b.size_bytes { -1 } else { 1 }
			}
			'Sort: Size (Smallest)' {
				if a.size_bytes < b.size_bytes { -1 } else { 1 }
			}
			'Sort: Date Modified (Newest)' {
				if a.mod_time > b.mod_time { -1 } else { 1 }
			}
			'Sort: Type' {
				if a.type_name < b.type_name { -1 } else { 1 }
			}
			else { // Sort: Name (A-Z)
				if a.name.to_lower() < b.name.to_lower() { -1 } else { 1 }
			}
		}
	})

	return items
}

fn generate_quicklook_preview(item_path string) string {
	if item_path == '' || !os.exists(item_path) {
		return 'No item selected. Click any file or folder from the list to inspect.'
	}

	real_path := os.real_path(item_path)
	if os.is_dir(real_path) {
		children := os.ls(real_path) or { []string{} }
		mod_time := time.unix(os.file_last_mod_unix(real_path)).format_ss()
		return [
			'═══════════════════════════════════════════════════════════════════',
			'  📁 FOLDER INSPECTOR & QUICKLOOK',
			'═══════════════════════════════════════════════════════════════════',
			'Directory Name:   ${os.file_name(real_path)}',
			'Full Path:        ${real_path}',
			'Total Items:      ${children.len} children',
			'Last Modified:    ${mod_time}',
			'Permissions:      drwxr-xr-x',
			'Parent Folder:    ${os.dir(real_path)}',
			'',
			'Subdirectory Contents Preview:',
			'-------------------------------------------------------------------',
			children[..if children.len > 30 { 30 } else { children.len }].join('\n'),
			if children.len > 30 { '... and ${children.len - 30} more items.' } else { '' },
		].join('\n')
	}

	size := os.file_size(real_path)
	ext := os.file_ext(real_path).to_lower()
	mod_time := time.unix(os.file_last_mod_unix(real_path)).format_ss()
	icon, type_name := get_file_type_and_icon(os.file_name(real_path), false)

	// Determine if text-previewable
	is_text := match ext {
		'.v', '.c', '.h', '.cpp', '.py', '.js', '.ts', '.json', '.csv', '.tsv',
		'.md', '.txt', '.log', '.html', '.css', '.xml', '.yaml', '.yml', '.sql',
		'.sh', '.vsh', '.conf', '.env', '.toml', '.ini', '.mod' { true }
		else { false }
	}

	if is_text {
		content := os.read_file(real_path) or { 'Error reading file: ${err}' }
		lines := content.split_into_lines()
		preview_lines := lines[..if lines.len > 120 { 120 } else { lines.len }].join('\n')
		return [
			'═══════════════════════════════════════════════════════════════════',
			'  ${icon} TEXT FILE QUICKLOOK PREVIEW (${type_name})',
			'═══════════════════════════════════════════════════════════════════',
			'File Name:        ${os.file_name(real_path)}',
			'Full Path:        ${real_path}',
			'Size:             ${system.format_bytes(size)} (${content.len} chars, ${lines.len} lines)',
			'Last Modified:    ${mod_time}',
			'',
			'--- Content Preview (First 120 lines) ------------------------------',
			preview_lines,
			if lines.len > 120 { '\n[... preview truncated; file has ${lines.len} total lines ...]' } else { '' },
		].join('\n')
	}

	// For binary or image files
	hash := system.sha256_file(real_path) or { 'Error calculating hash: ${err}' }
	return [
		'═══════════════════════════════════════════════════════════════════',
		'  ${icon} BINARY / MEDIA FILE METADATA (${type_name})',
		'═══════════════════════════════════════════════════════════════════',
		'File Name:        ${os.file_name(real_path)}',
		'Full Path:        ${real_path}',
		'File Size:        ${system.format_bytes(size)} (${size} bytes)',
		'Last Modified:    ${mod_time}',
		'File Extension:   ${ext}',
		'SHA-256 Digest:   ${hash}',
		'Permissions:      ${if os.is_executable(real_path) { '-rwxr-xr-x (Executable)' } else { '-rw-r--r-- (Regular)' }}',
		'',
		'Binary file format cannot be rendered as plain text preview.',
		'Click "🚀 Open in System App" above to view with your default OS viewer.',
	].join('\n')
}

fn refresh_finder_gui(w &simplegui.SimpleWindow, target_dir string) {
	real_dir := os.real_path(target_dir)
	filter_text := w.get_value('file_filter')
	sort_mode := w.get_value('sort_mode')

	items := scan_directory(real_dir, sort_mode, filter_text) or {
		w.toast_error('Failed to open directory: ${err}')
		return
	}

	w.set_value('path_input', real_dir)

	mut folder_count := 0
	mut file_count := 0
	mut total_dir_bytes := u64(0)
	mut table_rows := [][]string{}

	for item in items {
		if item.is_dir {
			folder_count++
		} else {
			file_count++
			total_dir_bytes += item.size_bytes
		}

		table_rows << [
			item.icon,
			item.name,
			item.type_name,
			item.formatted_size,
			item.permissions,
			item.mod_time,
		]
	}

	if table_rows.len == 0 {
		table_rows << ['📁', 'Empty directory', '-', '-', '-', '-']
	}

	disk_info := system.get_disk_info(real_dir)

	w.set_kpi('kpi_current_dir', os.file_name(real_dir), real_dir)
	w.set_kpi('kpi_items', '${items.len} Total', '${folder_count} Folders, ${file_count} Files')
	w.set_kpi('kpi_size', system.format_bytes(total_dir_bytes), 'Files on Disk')
	w.set_kpi('kpi_disk_free', system.format_bytes(disk_info.free_bytes), '${disk_info.mount_point} Free')

	w.set_table_rows('file_table', table_rows)

	selected_path := w.get_value('selected_path').trim_space()
	if selected_path != '' && os.exists(selected_path) {
		w.set_value('preview_pane', generate_quicklook_preview(selected_path))
	} else {
		w.set_value('preview_pane', generate_quicklook_preview(real_dir))
	}

	w.set_status('Browsing: ${real_dir} • ${items.len} items (${folder_count} folders, ${file_count} files)')
}

fn open_in_system_default(path string) {
	$if macos {
		system.exec_safe('open', [path])
	} $else $if windows {
		system.exec_safe('cmd', ['/c', 'start', '""', path])
	} $else {
		system.exec_safe('xdg-open', [path])
	}
}

fn main() {
	start_dir := os.getwd()

	mut win := simplegui.new_window(
		title: 'Finder & File Explorer Studio Pro Enterprise'
		width: 1240
		height: 920
		theme: 'dracula'
	)

	win.heading('🗂️ Finder & File Explorer Studio Pro Enterprise')
	win.subheading('Desktop File System Browser, QuickLook Previewer, Directory Navigator & File Operations Deck')
	win.divider()

	// Initial scanning
	init_items := scan_directory(start_dir, 'Sort: Name (A-Z)', '') or { []FileItem{} }
	mut init_folders := 0
	mut init_files := 0
	mut init_size := u64(0)
	mut init_rows := [][]string{}

	for item in init_items {
		if item.is_dir {
			init_folders++
		} else {
			init_files++
			init_size += item.size_bytes
		}
		init_rows << [item.icon, item.name, item.type_name, item.formatted_size, item.permissions, item.mod_time]
	}
	if init_rows.len == 0 {
		init_rows << ['📁', 'Empty directory', '-', '-', '-', '-']
	}

	disk := system.get_disk_info(start_dir)

	// 1. Top Directory Telemetry KPI Cards
	win.row_start()
	win.kpi_card_named('kpi_current_dir', 'Current Directory', os.file_name(start_dir), start_dir)
	win.kpi_card_named('kpi_items', 'Directory Contents', '${init_items.len} Total', '${init_folders} Folders, ${init_files} Files')
	win.kpi_card_named('kpi_size', 'Total Content Size', system.format_bytes(init_size), 'Files on Disk')
	win.kpi_card_named('kpi_disk_free', 'Volume Free Space', system.format_bytes(disk.free_bytes), '${disk.mount_point} Free')
	win.row_end()

	// 2. Navigation Quick-Jumps & Breadcrumbs Bar
	win.box_start('🧭 Directory Navigation & Quick Jumps')
	win.row_start()
	win.button('🏠 Home', fn (w &simplegui.SimpleWindow, _ string) {
		home := os.home_dir()
		w.set_value('selected_path', '')
		refresh_finder_gui(w, home)
		w.toast_info('Navigated to Home: ${home}')
	})
	win.button('📂 Desktop', fn (w &simplegui.SimpleWindow, _ string) {
		desktop := os.join_path(os.home_dir(), 'Desktop')
		if os.is_dir(desktop) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, desktop)
			w.toast_info('Navigated to Desktop')
		} else {
			w.toast_warning('Desktop folder not found.')
		}
	})
	win.button('📄 Documents', fn (w &simplegui.SimpleWindow, _ string) {
		docs := os.join_path(os.home_dir(), 'Documents')
		if os.is_dir(docs) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, docs)
			w.toast_info('Navigated to Documents')
		} else {
			w.toast_warning('Documents folder not found.')
		}
	})
	win.button('⬇️ Downloads', fn (w &simplegui.SimpleWindow, _ string) {
		downloads := os.join_path(os.home_dir(), 'Downloads')
		if os.is_dir(downloads) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, downloads)
			w.toast_info('Navigated to Downloads')
		} else {
			w.toast_warning('Downloads folder not found.')
		}
	})
	win.button('⬆️ Up to Parent', fn (w &simplegui.SimpleWindow, _ string) {
		cur := w.get_value('path_input')
		parent := os.dir(cur)
		if parent != cur && os.is_dir(parent) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, parent)
			w.toast_info('Moved up to ${parent}')
		} else {
			w.toast_warning('Already at filesystem root.')
		}
	})
	win.button('📂 Pick Folder...', fn (w &simplegui.SimpleWindow, _ string) {
		chosen := w.select_folder_dialog('Choose folder to browse')
		if chosen != '' && os.is_dir(chosen) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, chosen)
			w.toast_success('Opened folder: ${chosen}')
		}
	})
	win.row_end()

	// Path Input Row
	win.row_start()
	win.input_named('path_input', 'Enter directory path to navigate...', start_dir, fn (w &simplegui.SimpleWindow, val string) {
		if val.trim_space() != '' && os.is_dir(val.trim_space()) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, val.trim_space())
		}
	})
	win.button('➡️ Go', fn (w &simplegui.SimpleWindow, _ string) {
		target := w.get_value('path_input').trim_space()
		if target != '' && os.is_dir(target) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, target)
			w.toast_success('Navigated to ${target}')
		} else {
			w.toast_error('Invalid directory path: ${target}')
		}
	})
	win.row_end()
	win.box_end()

	// 3. Search & Sorting Toolbar
	win.box_start('🔍 Search Filter & Sort Mode')
	win.row_start()
	win.input_named('file_filter', 'Filter files and folders by name or extension (e.g. .v, json, main)...', '', fn (w &simplegui.SimpleWindow, _ string) {
		cur := w.get_value('path_input')
		refresh_finder_gui(w, cur)
	})
	win.dropdown_named('sort_mode', [
		'Sort: Name (A-Z)',
		'Sort: Name (Z-A)',
		'Sort: Size (Largest)',
		'Sort: Size (Smallest)',
		'Sort: Date Modified (Newest)',
		'Sort: Type',
	], 'Sort: Name (A-Z)', fn (w &simplegui.SimpleWindow, _ string) {
		cur := w.get_value('path_input')
		refresh_finder_gui(w, cur)
	})
	win.button('🔄 Refresh Directory', fn (w &simplegui.SimpleWindow, _ string) {
		cur := w.get_value('path_input')
		refresh_finder_gui(w, cur)
		w.toast_info('Directory contents refreshed.')
	})
	win.row_end()
	win.box_end()

	// 4. File Browser Table
	win.box_start('📂 File System Explorer (Click any row to select & QuickLook)')
	table_headers := ['Icon', 'Name', 'Type', 'Size', 'Permissions', 'Last Modified']
	win.table_named('file_table', table_headers, init_rows, fn (w &simplegui.SimpleWindow, row_idx_str string) {
		idx := row_idx_str.int()
		cur_dir := w.get_value('path_input')
		filter_text := w.get_value('file_filter')
		sort_mode := w.get_value('sort_mode')
		items := scan_directory(cur_dir, sort_mode, filter_text) or { return }

		if idx >= 0 && idx < items.len {
			selected := items[idx]
			w.set_value('selected_path', selected.path)
			w.set_value('preview_pane', generate_quicklook_preview(selected.path))
			w.toast_info('Selected: ${selected.name} (${selected.type_name})')
		}
	})
	win.box_end()

	// 5. File Operations Deck
	win.box_start('⚡ File & Folder Operations Deck')
	win.row_start()
	win.input_named('selected_path', 'Selected item full path...', '', fn (w &simplegui.SimpleWindow, val string) {
		if val.trim_space() != '' && os.exists(val.trim_space()) {
			w.set_value('preview_pane', generate_quicklook_preview(val.trim_space()))
		}
	})
	win.button('📂 Open / Enter Folder', fn (w &simplegui.SimpleWindow, _ string) {
		target := w.get_value('selected_path').trim_space()
		if target == '' {
			w.toast_error('Please select an item from the list first.')
			return
		}
		if os.is_dir(target) {
			w.set_value('selected_path', '')
			refresh_finder_gui(w, target)
			w.toast_success('Navigated into ${os.file_name(target)}')
		} else {
			// If file, open quicklook preview
			w.set_value('preview_pane', generate_quicklook_preview(target))
			w.toast_info('Loaded QuickLook preview for ${os.file_name(target)}')
		}
	})
	win.button('🚀 Open in OS App', fn (w &simplegui.SimpleWindow, _ string) {
		mut target := w.get_value('selected_path').trim_space()
		if target == '' {
			target = w.get_value('path_input').trim_space()
		}
		if target != '' && os.exists(target) {
			open_in_system_default(target)
			w.toast_success('Opened ${os.file_name(target)} in system default application.')
		} else {
			w.toast_error('Target path does not exist.')
		}
	})
	win.button('📁 New Folder', fn (w &simplegui.SimpleWindow, _ string) {
		cur_dir := w.get_value('path_input')
		mut new_name := 'new_folder'
		mut counter := 1
		for os.exists(os.join_path(cur_dir, new_name)) {
			new_name = 'new_folder_${counter}'
			counter++
		}
		full_folder := os.join_path(cur_dir, new_name)
		os.mkdir(full_folder) or {
			w.toast_error('Failed to create folder: ${err}')
			return
		}
		refresh_finder_gui(w, cur_dir)
		w.set_value('selected_path', full_folder)
		w.set_value('preview_pane', generate_quicklook_preview(full_folder))
		w.toast_success('Created folder: ${new_name}')
	})
	win.button('📝 New File', fn (w &simplegui.SimpleWindow, _ string) {
		cur_dir := w.get_value('path_input')
		mut new_file := 'untitled.txt'
		mut counter := 1
		for os.exists(os.join_path(cur_dir, new_file)) {
			new_file = 'untitled_${counter}.txt'
			counter++
		}
		full_file := os.join_path(cur_dir, new_file)
		os.write_file(full_file, '// New file created with Finder Studio\n') or {
			w.toast_error('Failed to create file: ${err}')
			return
		}
		refresh_finder_gui(w, cur_dir)
		w.set_value('selected_path', full_file)
		w.set_value('preview_pane', generate_quicklook_preview(full_file))
		w.toast_success('Created file: ${new_file}')
	})
	win.button('🗑️ Delete Item', fn (w &simplegui.SimpleWindow, _ string) {
		target := w.get_value('selected_path').trim_space()
		if target == '' || !os.exists(target) {
			w.toast_error('Select an item to delete.')
			return
		}
		cur_dir := w.get_value('path_input')
		item_name := os.file_name(target)
		if os.is_dir(target) {
			os.rmdir_all(target) or {
				w.toast_error('Failed to remove directory: ${err}')
				return
			}
		} else {
			os.rm(target) or {
				w.toast_error('Failed to delete file: ${err}')
				return
			}
		}
		w.set_value('selected_path', '')
		refresh_finder_gui(w, cur_dir)
		w.toast_warning('Deleted: ${item_name}')
	})
	win.button('📋 Copy Path', fn (w &simplegui.SimpleWindow, _ string) {
		mut target := w.get_value('selected_path').trim_space()
		if target == '' {
			target = w.get_value('path_input').trim_space()
		}
		system.set_clipboard_text(target)
		w.toast_info('Copied path to clipboard: ${target}')
	})
	win.row_end()
	win.box_end()

	// 6. QuickLook Preview Pane
	win.box_start('👁️ QuickLook & File Metadata Inspector')
	win.raw_html('<style>
		#preview_pane {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
			font-size: 11px !important;
			height: 240px !important;
			min-height: 240px !important;
			background: #191a21 !important;
			color: #f8f8f2 !important;
			border: 1px solid #282a36 !important;
			border-radius: 6px !important;
			line-height: 1.45 !important;
			padding: 8px !important;
		}
	</style>')
	win.textarea_named('preview_pane', 'QuickLook preview...', generate_quicklook_preview(start_dir), fn (_ &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	win.status_bar('Finder & File Explorer Studio Enterprise • ${init_items.len} items • Ready')

	win.run()
}
