module webview

import os
import system

pub fn (mut w Webview) attach_system_bindings() {
	// Process execution
	w.bind('systemExec', fn (e &Event) string {
		cmd := e.get_arg[string](0) or { '' }
		out, code := system.exec(cmd)
		return '{"output": ${system.json_escape(out)}, "exitCode": ${code}}'
	})

	// Hardware telemetry
	w.bind('systemGetTelemetry', fn (e &Event) string {
		info := system.get_hardware_telemetry()
		return '{"cpuModel": ${system.json_escape(info.cpu_model)}, "cpuCores": ${info.cpu_cores}, "cpuArch": "${info.cpu_arch}", "cpuUsage": ${info.cpu_usage:.1f}, "ramTotal": ${info.ram_total_bytes}, "ramFree": ${info.ram_free_bytes}, "ramUsed": ${info.ram_used_bytes}, "ramFormatted": "${info.ram_formatted}", "osName": "${info.os_name}", "osVersion": "${info.os_version}", "hostname": "${info.hostname}", "uptime": ${info.uptime_seconds}, "batteryPercent": ${info.battery_percent}, "batteryCharging": ${info.battery_charging}, "acConnected": ${info.ac_connected}, "loadAvg1": ${info.load_avg_1:.2f}, "loadAvg5": ${info.load_avg_5:.2f}, "loadAvg15": ${info.load_avg_15:.2f}}'
	})

	// Desktop notifications & alerts
	w.bind('systemNotification', fn (e &Event) string {
		title := e.get_arg[string](0) or { 'RAD Studio' }
		msg := e.get_arg[string](1) or { '' }
		system.show_notification(title, msg)
		return 'ok'
	})

	w.bind('systemAlert', fn (e &Event) string {
		title := e.get_arg[string](0) or { 'Alert' }
		msg := e.get_arg[string](1) or { '' }
		system.show_alert(title, msg)
		return 'ok'
	})

	w.bind('systemConfirm', fn (e &Event) string {
		title := e.get_arg[string](0) or { 'Confirm' }
		msg := e.get_arg[string](1) or { '' }
		res := system.show_confirm(title, msg)
		return if res { 'true' } else { 'false' }
	})

	// File dialogs
	w.bind('systemOpenFilePicker', fn (e &Event) string {
		prompt := e.get_arg[string](0) or { 'Choose File' }
		types := e.get_arg[string](1) or { '' }
		path := system.open_file_dialog(prompt, types)
		return system.json_escape(path)
	})

	w.bind('systemSaveFilePicker', fn (e &Event) string {
		prompt := e.get_arg[string](0) or { 'Save File' }
		name := e.get_arg[string](1) or { 'untitled.txt' }
		path := system.save_file_dialog(prompt, name)
		return system.json_escape(path)
	})

	w.bind('systemSelectFolder', fn (e &Event) string {
		prompt := e.get_arg[string](0) or { 'Select Folder' }
		path := system.select_folder_dialog(prompt)
		return system.json_escape(path)
	})

	// Clipboard
	w.bind('systemGetClipboard', fn (e &Event) string {
		return system.json_escape(system.get_clipboard_text())
	})

	w.bind('systemSetClipboard', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		system.set_clipboard_text(text)
		return 'ok'
	})

	// File system
	w.bind('systemReadFile', fn (e &Event) string {
		path := e.get_arg[string](0) or { '' }
		if !os.exists(path) {
			return '{"error": "File not found"}'
		}
		content := os.read_file(path) or { return '{"error": "${err}"}' }
		return '{"content": ${system.json_escape(content)}}'
	})

	w.bind('systemWriteFile', fn (e &Event) string {
		path := e.get_arg[string](0) or { '' }
		content := e.get_arg[string](1) or { '' }
		os.write_file(path, content) or { return '{"error": "${err}"}' }
		return '{"success": true}'
	})

	w.bind('systemFileExists', fn (e &Event) string {
		path := e.get_arg[string](0) or { '' }
		return if os.exists(path) { 'true' } else { 'false' }
	})

	w.bind('systemListDirectory', fn (e &Event) string {
		path := e.get_arg[string](0) or { '.' }
		entries := os.ls(path) or { return '[]' }
		mut list := []string{}
		for item in entries {
			list << system.json_escape(item)
		}
		return '[${list.join(',')}]'
	})

	// Sound & Browser
	w.bind('systemPlaySound', fn (e &Event) string {
		name := e.get_arg[string](0) or { 'Ping' }
		system.play_system_sound(name)
		return 'ok'
	})

	w.bind('systemOpenUrl', fn (e &Event) string {
		url := e.get_arg[string](0) or { '' }
		system.open_url(url)
		return 'ok'
	})
}

pub fn (mut w Webview) attach_stdlib_bindings() {
	// HTTP API client
	w.bind('apiHttpGet', fn (e &Event) string {
		url := e.get_arg[string](0) or { '' }
		resp := system.http_get(url)
		return '{"statusCode": ${resp.status_code}, "body": ${system.json_escape(resp.body)}}'
	})

	w.bind('apiHttpPost', fn (e &Event) string {
		url := e.get_arg[string](0) or { '' }
		body := e.get_arg[string](1) or { '' }
		ct := e.get_arg[string](2) or { 'application/json' }
		resp := system.http_post(url, body, ct)
		return '{"statusCode": ${resp.status_code}, "body": ${system.json_escape(resp.body)}}'
	})

	// Cryptography
	w.bind('cryptoSha256', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.hash_sha256(text))
	})

	w.bind('cryptoSha512', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.hash_sha512(text))
	})

	w.bind('cryptoMd5', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.hash_md5(text))
	})

	w.bind('cryptoHmacSha256', fn (e &Event) string {
		key := e.get_arg[string](0) or { '' }
		text := e.get_arg[string](1) or { '' }
		return system.json_escape(system.hmac_sha256(key, text))
	})

	// Encoding
	w.bind('base64Encode', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.encode_base64(text))
	})

	w.bind('base64Decode', fn (e &Event) string {
		encoded := e.get_arg[string](0) or { '' }
		return system.json_escape(system.decode_base64(encoded))
	})

	w.bind('hexEncode', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.encode_hex(text))
	})

	w.bind('hexDecode', fn (e &Event) string {
		encoded := e.get_arg[string](0) or { '' }
		return system.json_escape(system.decode_hex(encoded))
	})

	// String utilities
	w.bind('stringReverse', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.reverse_string(text))
	})

	w.bind('stringTitleCase', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.title_case(text))
	})

	w.bind('stringIsPalindrome', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return if system.is_palindrome(text) { 'true' } else { 'false' }
	})

	w.bind('stringSlugify', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.json_escape(system.slugify(text))
	})

	w.bind('stringWordCount', fn (e &Event) string {
		text := e.get_arg[string](0) or { '' }
		return system.word_count(text).str()
	})

	// Math Stats
	w.bind('mathCalculateStats', fn (e &Event) string {
		raw_csv := e.get_arg[string](0) or { '' }
		parts := raw_csv.split(',')
		mut numbers := []f64{}
		for p in parts {
			trimmed := p.trim_space()
			if trimmed.len > 0 {
				numbers << trimmed.f64()
			}
		}
		st := system.calculate_stats(numbers) or {
			return '{"error": "${err}"}'
		}
		return '{"count": ${st.count}, "min": ${st.min}, "max": ${st.max}, "sum": ${st.sum}, "mean": ${st.mean:.4f}, "median": ${st.median:.4f}, "variance": ${st.variance:.4f}, "stdDev": ${st.std_dev:.4f}}'
	})
}
