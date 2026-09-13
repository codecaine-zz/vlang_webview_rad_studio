module main

import simplegui
import system
import os
import time
import sync

struct FileMeta {
	mtime u64
	ctime u64
	size  u64
}

struct AuditEvent {
	timestamp string
	event     string
	rel_path  string
	exit_code string
	duration  string
	full_path string
}

struct FileChangeEvent {
	event_type string
	full_path  string
	rel_path   string
}

@[heap]
struct WatcherContext {
pub mut:
	win          &simplegui.SimpleWindow = unsafe { nil }
	is_watching  bool                    = true
	is_busy      bool
	lock         sync.Mutex
	event_count  int
	exec_count   int
	success_cnt  int
	fail_cnt     int
	log_buffer   string
	audit_events []AuditEvent
}

fn (mut ctx WatcherContext) append_log(entry string) {
	ctx.lock.lock()
	defer {
		ctx.lock.unlock()
	}
	if ctx.log_buffer == '' {
		ctx.log_buffer = entry
	} else {
		ctx.log_buffer += '\n' + entry
	}
	// Keep buffer reasonable to avoid browser memory buildup
	if ctx.log_buffer.len > 35000 {
		ctx.log_buffer = ctx.log_buffer#[ctx.log_buffer.len - 30000..]
	}
}

fn (mut ctx WatcherContext) get_log() string {
	ctx.lock.lock()
	defer {
		ctx.lock.unlock()
	}
	return ctx.log_buffer
}

fn (mut ctx WatcherContext) add_audit_event(ev AuditEvent) {
	ctx.lock.lock()
	defer {
		ctx.lock.unlock()
	}
	ctx.audit_events << ev
	if ctx.audit_events.len > 1000 {
		ctx.audit_events = ctx.audit_events#[ctx.audit_events.len - 800..].clone()
	}
}

fn is_path_excluded(name string, full_path string, excludes []string) bool {
	// Built-in hard exclusions for system / vcs noise
	if name in ['.git', '.cache', 'node_modules', '.rad_preview', '.DS_Store'] {
		return true
	}
	if name.starts_with('.') && (name.ends_with('.swp') || name.ends_with('.tmp')) {
		return true
	}
	if name.ends_with('~') || name.ends_with('.dSYM') {
		return true
	}

	for exc in excludes {
		clean := exc.trim_space()
		if clean == '' {
			continue
		}
		if clean.starts_with('*.') {
			ext := clean#[1..]
			if name.ends_with(ext) {
				return true
			}
		} else if clean == name || full_path.contains(clean) {
			return true
		}
	}
	return false
}

fn is_path_included(name string, includes []string) bool {
	if includes.len == 0 {
		return true
	}
	for inc in includes {
		clean := inc.trim_space()
		if clean == '' || clean == '*' || clean == '*.*' {
			return true
		}
		if clean.starts_with('*.') {
			ext := clean#[1..]
			if name.ends_with(ext) {
				return true
			}
		} else if clean == name || name.ends_with(clean) {
			return true
		}
	}
	return false
}

fn scan_dir_snapshot(canonical_root string, recursive bool, includes []string, excludes []string) map[string]FileMeta {
	mut snapshot := map[string]FileMeta{}
	if !os.is_dir(canonical_root) {
		return snapshot
	}
	scan_dir_rec(canonical_root, canonical_root, mut snapshot, 0, recursive, includes, excludes)
	return snapshot
}

fn scan_dir_rec(root string, current string, mut snapshot map[string]FileMeta, depth int, recursive bool, includes []string, excludes []string) {
	if depth > 7 {
		return
	}
	entries := os.ls(current) or { return }
	for entry in entries {
		full_path := os.join_path(current, entry)
		if is_path_excluded(entry, full_path, excludes) {
			continue
		}

		if os.is_dir(full_path) {
			if recursive {
				scan_dir_rec(root, full_path, mut snapshot, depth + 1, recursive, includes, excludes)
			}
		} else {
			if is_path_included(entry, includes) {
				st := os.stat(full_path) or { continue }
				snapshot[full_path] = FileMeta{
					mtime: u64(st.mtime)
					ctime: u64(st.ctime)
					size: u64(st.size)
				}
			}
		}
	}
}

fn parse_comma_list(input_str string) []string {
	mut items := []string{}
	for raw in input_str.split(',') {
		trimmed := raw.trim_space()
		if trimmed != '' {
			items << trimmed
		}
	}
	return items
}

fn get_relative_display_path(root string, full_path string) string {
	if full_path.starts_with(root) {
		rel := full_path#[root.len..].trim_left(os.path_separator)
		return if rel == '' { '.' } else { rel }
	}
	return full_path
}

fn execute_command_pipeline(mut ctx WatcherContext, event_type string, full_path string, rel_path string, root_dir string) (string, int, string) {
	raw_cmd := ctx.win.get('trigger_cmd').trim_space()
	if raw_cmd == '' {
		return '', 0, '0ms'
	}

	filename := os.file_name(full_path)
	file_dir := os.dir(full_path)
	now_str := time.now().custom_format('HH:mm:ss')

	// Enterprise dynamic placeholders
	resolved_cmd := raw_cmd
		.replace('{file}', rel_path)
		.replace('{path}', full_path)
		.replace('{filename}', filename)
		.replace('{dir}', file_dir)
		.replace('{root}', root_dir)
		.replace('{event}', event_type)
		.replace('{time}', now_str)

	ctx.lock.lock()
	ctx.is_busy = true
	ctx.lock.unlock()
	ctx.win.set_kpi('kpi_status', 'Executing...', 'Command Active')

	sw := time.new_stopwatch()
	out, code := system.exec(resolved_cmd)
	elapsed := sw.elapsed()
	dur_str := '${elapsed.milliseconds()}ms'

	ctx.lock.lock()
	ctx.is_busy = false
	ctx.exec_count++
	if code == 0 {
		ctx.success_cnt++
	} else {
		ctx.fail_cnt++
	}
	total_execs := ctx.exec_count
	successes := ctx.success_cnt
	failures := ctx.fail_cnt
	ctx.lock.unlock()

	status_code_str := if code == 0 { 'Exit 0 (Success)' } else { 'Exit ${code} (Failed)' }
	trimmed_out := out.trim_space()

	// 1. Direct Terminal stdout logging (ANSI styled output in terminal)
	println('\n[${now_str}] ⚡ [${event_type.to_upper()}] ${rel_path}')
	println('  $ ${resolved_cmd}')
	if trimmed_out != '' {
		for line in trimmed_out.split_into_lines() {
			println('    ${line}')
		}
	}
	println('  ↳ ${status_code_str} • Latency: ${dur_str}')

	// 2. GUI Live Output Console streaming
	mut log_entry := '[${now_str}] ⚡ [${event_type.to_upper()}] ${rel_path}\n$ ${resolved_cmd}'
	if trimmed_out != '' {
		log_entry += '\n' + trimmed_out
	}
	log_entry += '\n↳ ${status_code_str}  [took ${dur_str}]\n======================================================================'

	ctx.append_log(log_entry)
	ctx.win.set_value('live_console', ctx.get_log())

	// 3. Update KPI cards
	ctx.win.set_kpi('kpi_status', 'Active (Listening)', 'Ready')
	ctx.win.set_kpi('kpi_runs', '${total_execs} Runs', '${successes} OK • ${failures} Err')
	ctx.win.set_kpi('kpi_latency', dur_str, 'Last Exit: ${code}')

	return resolved_cmd, code, dur_str
}

fn run_watcher_loop(mut ctx WatcherContext) {
	// Wait until GUI window and webview engine are active
	for {
		time.sleep(100 * time.millisecond)
		if !isnil(ctx.win.wv) {
			break
		}
	}
	time.sleep(300 * time.millisecond)

	mut current_watch_dir := ctx.win.get('watch_dir').trim_space()
	if current_watch_dir == '' {
		current_watch_dir = '.'
	}
	mut canonical_dir := os.real_path(current_watch_dir)

	// Read initial include/exclude rules
	mut includes := parse_comma_list(ctx.win.get('include_pat'))
	mut excludes := parse_comma_list(ctx.win.get('exclude_pat'))
	mut recursive := ctx.win.get('recursive') != 'false'

	// Initial snapshot: captures state BEFORE changes occur, preventing phantom creation events
	mut previous_snapshot := scan_dir_snapshot(canonical_dir, recursive, includes, excludes)
	println('[Watcher Studio Pro] Engine initialized on: ${canonical_dir}')
	println('[Watcher Studio Pro] Pre-indexed ${previous_snapshot.len} files. Actively listening...')

	for {
		// Dynamic debounce / polling interval
		interval_val := ctx.win.get('poll_interval').trim_space()
		delay_ms := match interval_val {
			'200ms' { 200 }
			'500ms' { 500 }
			'1000ms' { 1000 }
			'2000ms' { 2000 }
			else { 350 }
		}
		time.sleep(delay_ms * time.millisecond)

		if isnil(ctx.win.wv) {
			break
		}

		ctx.lock.lock()
		watching := ctx.is_watching
		ctx.lock.unlock()

		if !watching {
			continue
		}

		// Dynamically reflect folder path changes from user GUI
		dir_in_gui := ctx.win.get('watch_dir').trim_space()
		target_dir := if dir_in_gui != '' { dir_in_gui } else { '.' }
		new_canonical := os.real_path(target_dir)

		includes = parse_comma_list(ctx.win.get('include_pat'))
		excludes = parse_comma_list(ctx.win.get('exclude_pat'))
		recursive = ctx.win.get('recursive') != 'false'

		if new_canonical != canonical_dir {
			canonical_dir = new_canonical
			current_watch_dir = target_dir
			previous_snapshot = scan_dir_snapshot(canonical_dir, recursive, includes, excludes)
			ctx.win.set_status('Watching folder switched to: ${canonical_dir}')
			continue
		}

		current_snapshot := scan_dir_snapshot(canonical_dir, recursive, includes, excludes)

		mut events := []FileChangeEvent{}

		// 1. Detect Created and Modified files
		for file_path, meta in current_snapshot {
			rel := get_relative_display_path(canonical_dir, file_path)
			if file_path in previous_snapshot {
				old := previous_snapshot[file_path]
				if meta.mtime != old.mtime || meta.size != old.size || meta.ctime != old.ctime {
					events << FileChangeEvent{
						event_type: 'modified'
						full_path: file_path
						rel_path: rel
					}
				}
			} else {
				events << FileChangeEvent{
					event_type: 'created'
					full_path: file_path
					rel_path: rel
				}
			}
		}

		// 2. Detect Deleted files
		for file_path, _ in previous_snapshot {
			if file_path !in current_snapshot {
				rel := get_relative_display_path(canonical_dir, file_path)
				events << FileChangeEvent{
					event_type: 'deleted'
					full_path: file_path
					rel_path: rel
				}
			}
		}

		if events.len == 0 {
			continue
		}

		// Commit snapshot state immediately
		previous_snapshot = current_snapshot.clone()

		auto_exec := ctx.win.get('auto_exec') != 'false'

		for ev in events {
			now_str := time.now().custom_format('HH:mm:ss')
			ctx.lock.lock()
			ctx.event_count++
			total_events := ctx.event_count
			ctx.lock.unlock()

			mut status := 'Logged'
			mut dur_display := '0ms'

			if auto_exec {
				_, code, dur := execute_command_pipeline(mut ctx, ev.event_type, ev.full_path, ev.rel_path, canonical_dir)
				dur_display = dur
				status = if code == 0 { 'Triggered (0)' } else { 'Failed (${code})' }
			} else {
				println('[${now_str}] ℹ️ [${ev.event_type.to_upper()}] ${ev.rel_path} (Auto-exec disabled)')
				ctx.append_log('[${now_str}] ℹ️ File ${ev.event_type.capitalize()}: ${ev.rel_path} (Audit Only)\n------------------------------------------------------------')
				ctx.win.set_value('live_console', ctx.get_log())
				status = 'Audit Only'
			}

			event_label := 'File ' + ev.event_type.capitalize()
			ctx.win.add_table_row('activity_log', [now_str, event_label, ev.rel_path, status, dur_display, ev.full_path])
			ctx.add_audit_event(AuditEvent{
				timestamp: now_str
				event: event_label
				rel_path: ev.rel_path
				exit_code: status
				duration: dur_display
				full_path: ev.full_path
			})

			ctx.win.set_kpi('kpi_changes', '${total_events} Events', '+1 just now')
			ctx.win.set_status('⚡ [${now_str}] ${event_label}: ${ev.rel_path} • ${status} [${dur_display}]')

			if ev.event_type == 'deleted' {
				ctx.win.toast_warning('${event_label}: ' + ev.rel_path)
			} else {
				ctx.win.toast_success('${event_label}: ' + ev.rel_path)
			}
		}
	}
}

fn export_audit_log_csv(events []AuditEvent) string {
	mut sb := 'Timestamp,Event,RelativePath,ExitStatus,Duration,FullPath\n'
	for e in events {
		sb += '"${e.timestamp}","${e.event}","${e.rel_path}","${e.exit_code}","${e.duration}","${e.full_path}"\n'
	}
	return sb
}

fn main() {
	mut ctx := &WatcherContext{
		is_watching: true
		is_busy: false
		event_count: 0
		exec_count: 0
		success_cnt: 0
		fail_cnt: 0
		log_buffer: ''
		audit_events: []AuditEvent{}
	}

	mut win := simplegui.new_window(
		title: 'Watcher Studio Pro Enterprise -- Real-time File System Intelligence & Automation'
		width: 1180
		height: 890
		theme: 'everforest'
	)
	ctx.win = win

	win.heading('👁️ Watcher Studio Pro Enterprise')
	win.subheading('Autonomous File System Intelligence, Real-time Change Auditing & Command Automation Pipeline')
	win.divider()

	// Top KPI Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Watcher Engine', 'Active (Listening)', 'Poll: 350ms')
	win.kpi_card_named('kpi_changes', 'Total Changes', '0 Events', 'Awaiting changes')
	win.kpi_card_named('kpi_runs', 'Commands Run', '0 Runs', '0 OK • 0 Err')
	win.kpi_card_named('kpi_latency', 'Execution Latency', '0ms', 'Standby')
	win.row_end()

	// Configuration Box
	win.box_start('⚙️ Watcher Target & Automation Pipeline')
	
	// Row 1: Target directory & quick helpers
	win.row_start()
	win.input_named('watch_dir', 'Target Directory Path to Watch...', '.', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Target directory updated: ' + val)
	})
	win.button('📂 Browse Folder...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.select_folder_dialog('Choose Directory to Watch')
		if path != '' {
			w.set_value('watch_dir', path)
			w.set_status('Now watching directory: ' + path)
			w.toast_info('Target folder set: ' + path)
		}
	})
	win.button('📍 Current Dir', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('watch_dir', os.real_path('.'))
		w.toast_info('Target set to current directory')
	})
	win.row_end()

	// Row 2: Preset recipes & command input
	win.row_start()
	recipes := [
		'Preset: Echo Event Details',
		'Preset: V Build & Test',
		'Preset: V Format File',
		'Preset: Git Quick Status',
		'Preset: NPM Build',
		'Preset: Voice Alert (macOS)',
	]
	win.dropdown_named('recipe_picker', recipes, recipes[0], fn (w &simplegui.SimpleWindow, val string) {
		cmd := match val {
			'Preset: Echo Event Details' { 'echo "⚡ [Watcher] Event: {event} on {file} at \$(date)"' }
			'Preset: V Build & Test' { 'v test .' }
			'Preset: V Format File' { 'v fmt -w {file}' }
			'Preset: Git Quick Status' { 'git status -s' }
			'Preset: NPM Build' { 'npm run build' }
			'Preset: Voice Alert (macOS)' { 'say "Change in {filename}"' }
			else { 'echo "⚡ [{event}] {file}"' }
		}
		w.set_value('trigger_cmd', cmd)
		w.set_status('Loaded preset command: ' + cmd)
		w.toast_info('Loaded: ' + val)
	})
	win.input_named('trigger_cmd', 'Command to execute on change...', 'echo "⚡ [Watcher] Event: {event} on {file} at \$(date)"', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Trigger command configured: ${val}')
	})
	win.button('⚡ Test Run', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		cmd := w.get('trigger_cmd').trim_space()
		if cmd == '' {
			w.toast_warning('Please enter a shell command to test.')
			return
		}
		target_dir := w.get('watch_dir').trim_space()
		canonical := os.real_path(if target_dir != '' { target_dir } else { '.' })
		dummy_file := os.join_path(canonical, 'sample_test.v')
		resolved, code, dur := execute_command_pipeline(mut ctx, 'test', dummy_file, 'sample_test.v', canonical)
		now_str := time.now().custom_format('HH:mm:ss')
		status := if code == 0 { 'Manual (0)' } else { 'Failed (${code})' }
		w.add_table_row('activity_log', [now_str, 'Manual Test', 'sample_test.v', status, dur, dummy_file])
		if code == 0 {
			w.toast_success('Manual command executed successfully [${dur}]')
			w.set_status('Manual execution succeeded: ' + resolved)
		} else {
			w.toast_error('Manual command failed (Exit ${code})')
			w.set_status('Manual test failed with exit code: ${code}')
		}
	})
	win.row_end()

	// Row 3: Include & Exclude filters
	win.row_start()
	win.input_named('include_pat', 'Include File Patterns (e.g. *, *.v, *.json)...', '*', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Include filter updated: ${val}')
	})
	win.input_named('exclude_pat', 'Exclude Patterns (comma separated)...', '.git, node_modules, .cache, *.tmp', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Exclude filter updated: ${val}')
	})
	intervals := ['200ms', '350ms', '500ms', '1000ms', '2000ms']
	win.dropdown_named('poll_interval', intervals, '350ms', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Polling interval set to: ' + val)
		w.set_kpi('kpi_status', 'Active (Listening)', 'Poll: ' + val)
	})
	win.row_end()

	// Row 4: Operational toggles & template badge
	win.row_start()
	win.toggle_named('auto_exec', 'Auto-Execute Command on Change', true, fn (w &simplegui.SimpleWindow, val string) {
		enabled := val == 'true'
		w.set_status(if enabled { 'Auto-execution enabled.' } else { 'Auto-execution paused (audit-only mode).' })
		w.toast_info(if enabled { 'Auto-execution active' } else { 'Audit-only mode active' })
	})
	win.toggle_named('recursive', 'Recursive (Watch Subdirectories)', true, fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Recursive scanning: ${val}')
	})
	win.label('💡 Placeholders: {file}, {path}, {filename}, {dir}, {root}, {event}, {time}')
	win.row_end()
	win.box_end()

	// Live Console Box
	win.box_start('💻 Real-time Command Execution Console')
	win.raw_html('<style>
		#live_console {
			font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 12px;
			height: 160px;
			min-height: 160px;
			background: #1e2326;
			color: #a7c080;
			border: 1px solid #2d353b;
			border-radius: 6px;
			line-height: 1.45;
			padding: 10px;
		}
	</style>')
	win.textarea_named('live_console', 'Real-time command execution output (stdout/stderr) will stream here when files change...', '', fn (w &simplegui.SimpleWindow, _ string) {})
	win.row_start()
	win.button('🧹 Clear Console', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		ctx.lock.lock()
		ctx.log_buffer = ''
		ctx.lock.unlock()
		w.set_value('live_console', '')
		w.toast_info('Console buffer cleared')
	})
	win.button('📋 Copy Console Output', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		text := ctx.get_log()
		if text == '' {
			w.toast_warning('Console is currently empty.')
			return
		}
		system.set_clipboard_text(text)
		w.toast_success('Console output copied to clipboard!')
	})
	win.row_end()
	win.box_end()

	// Activity Log Box
	win.box_start('📋 Filesystem Event & Automation Audit History')
	headers := ['Timestamp', 'Event', 'Target File', 'Status', 'Duration', 'Full Path']
	start_time := time.now().custom_format('HH:mm:ss')
	initial_rows := [
		[start_time, 'Engine Initialized', '.', 'Active', '0ms', os.real_path('.')],
	]
	win.table_named('activity_log', headers, initial_rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Audit event #${idx} inspected')
	})
	win.box_end()

	// Action toolbar
	win.row_start()
	win.button('⏸️ Pause Engine', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		ctx.lock.lock()
		ctx.is_watching = false
		ctx.lock.unlock()
		w.set_kpi('kpi_status', 'Paused (Idle)', 'Suspended')
		w.set_status('Watcher engine suspended.')
		w.toast_warning('Watcher engine paused')
	})
	win.button('▶️ Resume Engine', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		ctx.lock.lock()
		ctx.is_watching = true
		ctx.lock.unlock()
		poll := w.get('poll_interval')
		w.set_kpi('kpi_status', 'Active (Listening)', 'Poll: ' + (if poll != '' { poll } else { '350ms' }))
		w.set_status('Watcher engine resumed — actively monitoring file system.')
		w.toast_success('Watcher engine active')
	})
	win.button('🧹 Clear All History', fn [mut ctx] (w &simplegui.SimpleWindow, _ string) {
		w.set_table_rows('activity_log', [][]string{})
		ctx.lock.lock()
		ctx.event_count = 0
		ctx.exec_count = 0
		ctx.success_cnt = 0
		ctx.fail_cnt = 0
		ctx.log_buffer = ''
		ctx.audit_events = []AuditEvent{}
		ctx.lock.unlock()
		w.set_value('live_console', '')
		w.set_kpi('kpi_changes', '0 Events', 'Cleared')
		w.set_kpi('kpi_runs', '0 Runs', '0 OK • 0 Err')
		w.set_kpi('kpi_latency', '0ms', 'Standby')
		w.toast_warning('All audit logs and console history reset.')
		w.set_status('Engine state and history cleared.')
	})
	win.button('💾 Export Audit Log (CSV)', fn [ctx] (w &simplegui.SimpleWindow, _ string) {
		save_path := w.save_file_dialog('Export Audit Log to CSV', 'watcher_audit_log.csv')
		if save_path != '' {
			csv_content := export_audit_log_csv(ctx.audit_events)
			os.write_file(save_path, csv_content) or {
				w.toast_error('Failed to export CSV: ${err}')
				return
			}
			w.toast_success('Audit log exported successfully to: ' + save_path)
			w.set_status('Exported audit CSV: ' + save_path)
		}
	})
	win.row_end()

	win.status_bar('Watcher Studio Pro Enterprise  •  Real-time I/O Pipeline  •  Active Listening')

	spawn run_watcher_loop(mut ctx)

	win.run()
}
