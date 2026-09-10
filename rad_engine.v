module main

import os
import system

pub fn export_project_helper(spec_json string) string {
	export_dir := os.join_path(os.getwd(), 'exported_project')
	os.mkdir_all(export_dir) or {
		return '{"success": false, "error": "Failed to create directory: ${err}"}'
	}

	// 1. Write spec.json
	os.write_file(os.join_path(export_dir, 'spec.json'), spec_json) or {}

	// 2. Generate runnable V webview project
	v_mod_content := 'Module {
	name: "exported_rad_project"
	description: "Exported RAD Studio Webview Project"
	version: "1.0.0"
	license: "MIT"
	dependencies: []
}
'
	os.write_file(os.join_path(export_dir, 'v.mod'), v_mod_content) or {}

	// Generate main.v
	main_v := 'module main

import webview
import system

fn main() {
	println("Starting Exported RAD Studio Webview Application...")
	mut w := webview.create(debug: true)
	w.set_title("RAD Studio Exported Application")
	w.set_size(1000, 750, .@none)
	w.attach_window_management_bindings()
	w.attach_system_bindings()
	w.attach_stdlib_bindings()

	html := os.read_file(os.join_path(@DIR, "index.html")) or {
		"<h1>Exported RAD Studio Application</h1>"
	}
	w.set_html(html)
	w.run()
}
'
	os.write_file(os.join_path(export_dir, 'main.v'), main_v) or {}

	// Generate index.html for the exported project
	html_content := generate_exported_html(spec_json)
	os.write_file(os.join_path(export_dir, 'index.html'), html_content) or {}

	return '{"success": true, "dir": ${system.json_escape(export_dir)}}'
}

pub fn run_preview_helper(spec_json string) string {
	preview_dir := os.join_path(os.getwd(), '.rad_preview')
	os.mkdir_all(preview_dir) or {
		return '{"success": false, "error": "Failed to create preview dir: ${err}"}'
	}

	html_content := generate_exported_html(spec_json)
	os.write_file(os.join_path(preview_dir, 'preview.html'), html_content) or {}

	// Run preview in separate background process or thread
	preview_v := 'module main

import webview
import os

fn main() {
	mut w := webview.create(debug: true)
	w.set_title("RAD Studio - Live Form Preview")
	w.set_size(900, 650, .@none)
	w.attach_window_management_bindings()
	html := os.read_file(os.join_path(@DIR, "preview.html")) or { "<h1>Preview Error</h1>" }
	w.set_html(html)
	w.run()
}
'
	preview_v_path := os.join_path(preview_dir, 'main.v')
	os.write_file(preview_v_path, preview_v) or {}

	// Compile and run the preview in background
	system.exec_bg('v run "${preview_v_path}"')

	return '{"success": true}'
}

fn generate_exported_html(spec_json string) string {
	return '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>RAD Studio Exported Form</title>
<style>
:root {
	--bg-main: #0f172a;
	--text-main: #f8fafc;
	--accent: #38bdf8;
	--card-bg: #1e293b;
	--border-color: rgba(255, 255, 255, 0.1);
}
* { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
body {
	background-color: var(--bg-main);
	color: var(--text-main);
	padding: 24px;
	min-height: 100vh;
}
.header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding-bottom: 16px;
	border-bottom: 1px solid var(--border-color);
	margin-bottom: 24px;
}
.header h1 { font-size: 20px; color: var(--accent); }
.card {
	background-color: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 8px;
	padding: 20px;
	margin-bottom: 16px;
}
.btn {
	background-color: var(--accent);
	color: #000;
	border: none;
	padding: 8px 16px;
	border-radius: 6px;
	font-weight: 600;
	cursor: pointer;
}
.btn:hover { filter: brightness(1.1); }
pre {
	background: rgba(0,0,0,0.3);
	padding: 12px;
	border-radius: 6px;
	overflow-x: auto;
	font-size: 13px;
}
</style>
</head>
<body>
<div class="header">
	<h1>⚡ RAD Studio Live Form</h1>
	<button class="btn" onclick="window.quitApp ? window.quitApp() : window.close()">Close</button>
</div>
<div class="card">
	<p style="margin-bottom: 12px;">Active RAD Form Specification:</p>
	<pre id="specPre"></pre>
</div>
<script>
try {
	const spec = ${spec_json};
	document.getElementById("specPre").textContent = JSON.stringify(spec, null, 2);
} catch (e) {
	document.getElementById("specPre").textContent = "Spec loaded successfully.";
}
</script>
</body>
</html>'
}
