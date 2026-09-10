module main

import webview
import os

const html_content = '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<style>
body {
	background: #0f172a;
	color: #e2e8f0;
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
	padding: 24px;
	user-select: none;
}
h2 { color: #38bdf8; margin-bottom: 8px; }
p { font-size: 14px; opacity: 0.8; margin-bottom: 20px; }
.grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 12px;
	margin-bottom: 24px;
}
button {
	background: #1e293b;
	color: #f8fafc;
	border: 1px solid #334155;
	padding: 12px;
	border-radius: 8px;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.15s;
}
button:hover { background: #334155; border-color: #38bdf8; transform: translateY(-1px); }
.actions { display: flex; gap: 12px; margin-bottom: 20px; }
.btn-pin { background: #0284c7; }
.btn-fs { background: #059669; }
.btn-quit { background: #dc2626; }
.log-box {
	background: #1e293b;
	border: 1px solid #334155;
	border-radius: 8px;
	padding: 16px;
	font-family: monospace;
	font-size: 13px;
	color: #38bdf8;
}
</style>
</head>
<body>
<h2>🖼️ Native Window Placement & Pinning Manager</h2>
<p>Click a placement button to position and move the application window across the screen:</p>

<div class="grid">
	<button onclick="setPos(\'upper_left\')">↖ Upper Left</button>
	<button onclick="setPos(\'top_center\')">⬆ Top Center</button>
	<button onclick="setPos(\'upper_right\')">↗ Upper Right</button>

	<button onclick="setPos(\'center_left\')">⬅ Center Left</button>
	<button onclick="setPos(\'center\')" style="background:#0369a1;">🎯 Center Screen</button>
	<button onclick="setPos(\'center_right\')">➡ Center Right</button>

	<button onclick="setPos(\'bottom_left\')">↙ Lower Left</button>
	<button onclick="setPos(\'bottom_center\')">⬇ Bottom Center</button>
	<button onclick="setPos(\'bottom_right\')">↘ Lower Right</button>
</div>

<div class="actions">
	<button class="btn-pin" onclick="togglePin()">📌 Toggle Stay On Top</button>
	<button class="btn-fs" onclick="toggleFs()">⛶ Fullscreen (Ctrl+F / F11)</button>
	<button class="btn-quit" onclick="handleQuit()">❌ Quit App (Ctrl+Q)</button>
</div>

<div class="log-box" id="logBox">Window initialized. Current position: Center Screen.</div>

<script>
let pinned = false;
function setPos(pos) {
	window.setWindowPosition(pos);
	document.getElementById("logBox").innerText = "Moved window to preset: " + pos;
}
function togglePin() {
	pinned = !pinned;
	window.setAlwaysOnTop(pinned);
	document.getElementById("logBox").innerText = "Stay on Top: " + (pinned ? "ENABLED" : "DISABLED");
}
function toggleFs() {
	window.toggleFullscreen();
	document.getElementById("logBox").innerText = "Toggled native fullscreen state.";
}
function handleQuit() {
	if (typeof window.quitApp === "function") {
		window.quitApp();
	}
	if (typeof window.exitApp === "function") {
		window.exitApp();
	}
	if (typeof window.closeWindow === "function") {
		window.closeWindow();
	}
}

window.addEventListener("keydown", function(e) {
	var isCmdOrCtrl = e.metaKey || e.ctrlKey;
	if (isCmdOrCtrl && (e.key === "q" || e.key === "Q" || e.code === "KeyQ")) {
		e.preventDefault();
		handleQuit();
	}
});
</script>
</body>
</html>'

fn main() {
	export_path := os.getenv('SIMPLEGUI_EXPORT_HTML')
	if export_path.len > 0 {
		os.write_file(export_path, html_content) or {}
		return
	}
	$if linux {
		if os.getenv('GDK_BACKEND') == '' {
			os.setenv('GDK_BACKEND', 'x11', true)
		}
	}
	mut wv := webview.create(debug: true)
	wv.set_title('Demo 4 - Native Window Placement & Pin API')
	wv.set_size(820, 540, .@none)
	wv.attach_window_management_bindings()
	wv.set_html(html_content)
	wv.set_fullscreen(false)
	wv.run()
}
