module main

import simplegui
import system
import os
import time

fn build_application_bundle(w &simplegui.SimpleWindow) {
	name := w.get('app_name').trim_space()
	bundle_id := w.get('bundle_id').trim_space()
	entry := w.get('entry_file').trim_space()
	target_type := w.get('target_profile')
	build_mode := w.get('build_mode')

	if name == '' {
		w.toast_warning('Please specify an Application Name.')
		return
	}
	if entry == '' || !entry.ends_with('.v') || !os.is_file(entry) {
		w.toast_error('Please select an existing .v source file.')
		return
	}

	w.set_kpi('kpi_status', 'Building...', 'Compiler Active')
	w.set_status('Compiling and packaging ${name} from ${entry}...')
	now_str := time.now().custom_format('HH:mm:ss')

	mut flags := []string{}
	if build_mode.contains('-prod') {
		flags << '-prod'
	}
	if build_mode.contains('-g') {
		flags << '-g'
	}

	out_bin := name.to_lower().replace(' ', '_')
	flags << ['-o', out_bin, entry]

	w.set_value('build_console', '[${now_str}] 🚀 Invoking V compiler...\nCommand: v ${flags.join(' ')}\n------------------------------------------------------------')

	sw := time.new_stopwatch()
	res := system.exec_safe('v', flags)
	dur := sw.elapsed()
	dur_str := '${dur.milliseconds()}ms'

	if res.exit_code != 0 {
		w.set_kpi('kpi_status', 'Build Failed', 'Exit ${res.exit_code}')
		w.set_kpi('kpi_duration', dur_str, 'Compiler Error')
		w.set_status('❌ Compilation failed with exit code ${res.exit_code}')
		w.toast_error('Build failed: ${res.output}')

		current_log := w.get('build_console')
		w.set_value('build_console', current_log + '\n\n❌ ERROR:\n' + res.output + '\n------------------------------------------------------------')
		return
	}

	bin_size := if os.is_file(out_bin) { os.file_size(out_bin) } else { u64(0) }
	bin_size_str := system.format_bytes(bin_size)

	// If macOS .app bundle requested, wrap into .app structure
	mut final_artifact := out_bin
	if target_type.contains('.app') {
		app_dir := '${name}.app'
		contents_macos := os.join_path(app_dir, 'Contents', 'MacOS')
		contents_res := os.join_path(app_dir, 'Contents', 'Resources')
		os.mkdir_all(contents_macos) or {}
		os.mkdir_all(contents_res) or {}

		// Move binary into Contents/MacOS
		dest_bin := os.join_path(contents_macos, name)
		os.cp(out_bin, dest_bin) or {}
		os.chmod(dest_bin, 0o755) or {}

		// Write Info.plist
		plist_content := '<?xml version="1.0" encoding="UTF-8"?>\n' +
			'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' +
			'<plist version="1.0">\n<dict>\n' +
			'  <key>CFBundleExecutable</key>\n  <string>${name}</string>\n' +
			'  <key>CFBundleIdentifier</key>\n  <string>${bundle_id}</string>\n' +
			'  <key>CFBundleName</key>\n  <string>${name}</string>\n' +
			'  <key>CFBundlePackageType</key>\n  <string>APPL</string>\n' +
			'  <key>CFBundleShortVersionString</key>\n  <string>1.0.0</string>\n' +
			'</dict>\n</plist>\n'
		os.write_file(os.join_path(app_dir, 'Contents', 'Info.plist'), plist_content) or {}
		final_artifact = app_dir
	}

	w.set_kpi('kpi_status', 'Build Success', '0 (OK)')
	w.set_kpi('kpi_binary', final_artifact, 'Artifact')
	w.set_kpi('kpi_duration', dur_str, 'Completed')
	w.set_kpi('kpi_size', bin_size_str, 'Binary Size')

	log_msg := '[${now_str}] ✅ Build Completed Successfully!\n' +
		'Target:   ${final_artifact}\n' +
		'Size:     ${bin_size_str} (${bin_size} bytes)\n' +
		'Duration: ${dur_str}\n' +
		'Output:\n${if res.output.trim_space() != '' { res.output } else { 'No warnings or compiler notices.' }}\n' +
		'============================================================'
	w.set_value('build_console', log_msg)

	w.toast_success('Application built successfully [${dur_str}]')
	w.set_status('Build succeeded • ${final_artifact} (${bin_size_str}) ready')
}

fn main() {
	mut win := simplegui.new_window(
		title: 'App Bundler Studio Pro Enterprise -- Desktop Application Packager'
		width: 1180
		height: 890
		theme: 'sonoma_dark'
	)

	win.heading('📦 App Bundler Studio Pro Enterprise')
	win.subheading('Standalone Desktop Application Packaging, macOS .app Bundles, Custom Icons & Binary Optimization')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Build Status', 'Ready', 'Standby')
	win.kpi_card_named('kpi_binary', 'Output Target', 'myapp.app', 'Target')
	win.kpi_card_named('kpi_duration', 'Compilation Latency', '0ms', 'Awaiting build')
	win.kpi_card_named('kpi_size', 'Binary Size', '0 B', 'Executable')
	win.row_end()

	// Packaging Configuration Box
	win.box_start('⚙️ Application Metadata & Source Configuration')
	win.row_start()
	win.input_named('app_name', 'Application Display Name...', 'RADStudioApp', fn (w &simplegui.SimpleWindow, _ string) {})
	win.input_named('bundle_id', 'Bundle Identifier...', 'com.vlang.radstudio', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_end()

	win.row_start()
	win.input_named('entry_file', 'V Source Entry File (e.g. applications/api_studio.v)...', 'applications/api_studio.v', fn (w &simplegui.SimpleWindow, _ string) {})
	win.button('📂 Browse Source File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select Entry V Source File', 'v')
		if path != '' {
			w.set_value('entry_file', path)
			w.toast_info('Entry file selected: ' + path)
		}
	})
	win.row_end()

	// Build Modes & Targets
	win.row_start()
	build_modes := [
		'Production (-prod: full optimization, stripped)',
		'Fast Dev (no optimization: instant build)',
		'Debug (-g: symbols, backtraces)',
	]
	win.dropdown_named('build_mode', build_modes, build_modes[0], fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Build mode: ' + val)
	})

	targets := [
		'macOS .app Bundle (with Info.plist & structure)',
		'Standalone Native Executable (CLI / Binary)',
	]
	win.dropdown_named('target_profile', targets, targets[0], fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Target profile: ' + val)
	})

	win.button('🚀 Build & Package App', fn (w &simplegui.SimpleWindow, _ string) {
		build_application_bundle(w)
	})
	win.row_end()
	win.box_end()

	// Live Build Console Box
	win.box_start('💻 Real-Time Compiler & Packaging Build Console')
	win.raw_html('<style>
		#build_console {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 180px;
			min-height: 180px;
			background: #141416;
			color: #4ade80;
			border: 1px solid #27272a;
			border-radius: 6px;
			line-height: 1.45;
			padding: 10px;
		}
	</style>')
	win.textarea_named('build_console', 'Build console output (compiler logs, warnings, packaging status) will appear here...', 'Ready to compile. Select options above and click "🚀 Build & Package App".', fn (w &simplegui.SimpleWindow, _ string) {})

	win.row_start()
	win.button('📂 Reveal in Finder / Explorer', fn (w &simplegui.SimpleWindow, _ string) {
		system.reveal_in_finder('.')
		w.toast_success('Opened build folder in file manager!')
	})
	win.button('📋 Copy Build Command Line', fn (w &simplegui.SimpleWindow, _ string) {
		name := w.get('app_name').trim_space()
		entry := w.get('entry_file').trim_space()
		mode := w.get('build_mode')
		flag := if mode.contains('-prod') { '-prod' } else { '' }
		cmd := 'v ${flag} -o ${name.to_lower().replace(' ', '_')} ${entry}'.trim_space()
		system.set_clipboard_text(cmd)
		w.toast_success('Build command copied to clipboard: ' + cmd)
	})
	win.button('🧹 Clear Build Console', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('build_console', '')
		w.toast_info('Build console cleared')
	})
	win.row_end()
	win.box_end()

	win.status_bar('App Bundler Studio Pro Enterprise  •  Multi-Target Cross Compilation  •  Ready')
	win.run()
}
