# 📘 V Webview RAD Studio & SimpleGUI: Complete API Reference & Developer Guide

Welcome to the comprehensive API manual for **V Webview RAD Studio**. This guide is designed so that anyone—from beginners and non-programmers to seasoned software engineers—can build, run, and ship cross-platform desktop applications in minutes.

---

## 📑 Table of Contents

1. [Architectural Philosophy: How Desktop Apps Are Built](#1-architectural-philosophy-how-desktop-apps-are-built)
2. [Quickstart: Your First Application in 60 Seconds](#2-quickstart-your-first-application-in-60-seconds)
3. [SimpleGUI: Declarative Window & UI Controls](#3-simplegui-declarative-window-ui-controls)
   - [Window Setup & Configuration](#window-setup-configuration)
   - [Containers & Layouts (Boxes, Rows, Cards, Columns)](#containers-layouts)
   - [Standard Controls (Buttons, Inputs, Textareas, Labels)](#standard-controls)
   - [Selection Controls (Checkboxes, Radios, Dropdowns, Toggles, Sliders)](#selection-controls)
   - [Desktop Menubar & Custom Context Menus](#desktop-menubar-custom-context-menus)
   - [Data Displays (Tables, Key-Value Lists, Badges, Tags, Progress)](#data-displays)
   - [Desktop Triggers (Timers, File Pickers, Notifications, Dialogs)](#desktop-triggers)
   - [Window Management & Shortcuts](#window-management-shortcuts)
   - [Dynamic Theme Switcher (42 Form Themes)](#dynamic-theme-switcher)
   - [Named Builder & Fluent Control API (`vlang_simplegui` Parity)](#named-builder-fluent-control-api-vlang_simplegui-parity)
4. [System Module: `system/sys.v` (OS & Hardware Telemetry)](#4-system-module-systemsysv)
   - [Safe Command & Process Execution](#safe-command-process-execution)
   - [Process Management & Lifecycle](#process-management-lifecycle)
   - [Cross-Platform Paths & App Directories](#cross-platform-paths-app-directories)
   - [File Operations, Directory Sizing & Archives](#file-operations-directory-sizing-archives)
   - [Hardware Telemetry (CPU, RAM, Battery, Uptime)](#hardware-telemetry)
   - [Power, Display & Theme Controls](#power-display-theme-controls)
   - [Audio, Speech & Sound Effects](#audio-speech-sound-effects)
   - [Network Diagnostics & Font Resolution](#network-diagnostics-font-resolution)
5. [Standard Library: `system/stdlib.v` (Algorithms & Encoders)](#5-standard-library-systemstdlibv)
   - [Resilient HTTP Client](#resilient-http-client)
   - [Cryptography (AES, Ed25519, PBKDF2, Bcrypt, UUID, Hashes)](#cryptography)
   - [Regular Expressions](#regular-expressions)
   - [Gzip & Zlib Compression](#gzip-zlib-compression)
   - [Randomness & Combinatorics](#randomness-combinatorics)
   - [Concurrency Helpers (Mutex & WaitGroup)](#concurrency-helpers)
   - [Complex Numbers, Trigonometry & Math](#complex-numbers-trigonometry-math)
   - [Statistical Analysis](#statistical-analysis)
   - [String Metrics & Manipulations](#string-metrics-manipulations)
   - [URL Object Model & HTML Scraper](#url-object-model-html-scraper)
   - [CSV Matrices & Generic Data Structures](#csv-matrices-generic-data-structures)
   - [Time, Calendar & JSON](#time-calendar-json)
6. [Security Module: `system/security.v` (Defensive Coding)](#6-security-module-systemsecurityv)
   - [Shell Injection Prevention](#shell-injection-prevention)
   - [Path Traversal & Filename Sanitization](#path-traversal-filename-sanitization)
   - [Constant-Time Comparison & Secret Masking](#constant-time-comparison-secret-masking)
   - [HTML Sanitization & Safe URLs](#html-sanitization-safe-urls)
   - [Cryptographic Token Generation](#cryptographic-token-generation)
7. [State Module: `system/state.v` (Persistence & Configuration)](#7-state-module-systemstatev)
   - [Crash-Proof Atomic File Writing](#crash-proof-atomic-file-writing)
   - [Typesafe JSON State Serialization](#typesafe-json-state-serialization)
   - [Application-Scoped Preferences](#application-scoped-preferences)
8. [End-to-End Tutorial: Building a Production DevOps Workstation](#8-end-to-end-tutorial-building-a-production-devops-workstation)
9. [Packaging & Distribution Guide (`build.vsh`)](#9-packaging-distribution-guide-buildvsh)

---

## 1. Architectural Philosophy: How Desktop Apps Are Built

Traditional GUI development is often fragmented:
- Web technologies (Electron, Chromium) are bloated and consume hundreds of megabytes of RAM.
- Low-level native APIs (Cocoa, Win32, GTK) are complex, verbose, and difficult to cross-compile.

**V Webview RAD Studio** bridges this gap:
1. **Lightweight Native Core**: Written in **V (vlang)**, producing tiny standalone native binaries (~2.8 MB) with zero runtime dependencies.
2. **OS Webview Engine**: Uses the operating system's built-in browser engine (WebKit on macOS/Linux, WebView2 on Windows) via direct C/Objective-C/C++ bindings.
3. **Declarative SimpleGUI**: A fluent builder API where UI controls, layout rows, event handlers, and themes are declared in simple, readable code.
4. **Hardware Telemetry & System Tools**: Built-in modules for processes, CPU, RAM, battery, network, crypto, files, and audio without external libraries.
5. **No Reloads / Native Feel**: Default browser right-click menus and accidental page reloads (`Cmd+R` / `F5`) are suppressed. Desktop shortcuts (`Cmd+F`, `Cmd+M`, `Cmd+Shift+T`) control the native window directly.

```
┌──────────────────────────────────────────────────────────┐
│                 Your Application Code                    │
│   (calls simplegui, system.sys, system.stdlib, etc.)     │
└───────────────┬───────────────────────────┬──────────────┘
                │                           │
        UI Construction             System & Hardware
                ▼                           ▼
┌───────────────────────────┐   ┌──────────────────────────┐
│     simplegui Engine      │   │      system Modules      │
│  (HTML/CSS Generation,    │   │  (Process, Hardware,     │
│   42 Themes, Layouts)     │   │   Crypto, Files, State)  │
└───────────────┬───────────┘   └───────────┬──────────────┘
                │                           │
                ▼                           ▼
┌──────────────────────────────────────────────────────────┐
│             webview Binding (C++ / Obj-C)                │
│    (WebKit Cocoa / WebView2 / WebKitGTK / IPC Bridge)    │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Quickstart: Your First Application in 60 Seconds

Create a file named `hello_world.v`:

```v
module main

import simplegui

fn main() {
	// 1. Create a new window with a title and theme
	mut win := simplegui.new_window(
		title: 'My First Application'
		width: 800
		height: 600
		theme: 'tokyo_night'
		fullscreen: false
	)

	// 2. Add containers and visual controls
	win.box_start('Welcome to V RAD Studio')
	win.label('Build blazing-fast native desktop applications effortlessly.')

	win.row_start()
	win.button('Click Me', fn (w &simplegui.SimpleWindow, _ string) {
		w.notification('Hello World', 'You clicked the primary button!')
	})
	win.button('Toggle Fullscreen', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.row_end()

	win.box_end()

	// 3. Start the event loop
	win.run()
}
```

Run it directly from your terminal:
```bash
v run hello_world.v
```

---

## 3. SimpleGUI: Declarative Window & UI Controls

### Window Setup & Configuration

```v
import simplegui

mut win := simplegui.new_window(
	title: 'Enterprise Studio'     // Window title
	width: 1024                    // Window initial width in pixels
	height: 720                    // Window initial height in pixels
	theme: 'monokai_pro'           // One of 42 built-in themes
	fullscreen: true               // Start in fullscreen mode (default: true)
	min_width: 640                 // Minimum resizable width
	min_height: 480                // Minimum resizable height
)
```

### Containers & Layouts

#### Box (Card / Section Container)
Groups controls inside an outlined card with a bold header:
```v
win.box_start('Server Settings')
win.label('Configure your cloud deployment target.')
// ... controls go here ...
win.box_end()
```

#### Row (Horizontal Flex Container)
Lays out multiple buttons, inputs, or badges side-by-side:
```v
win.row_start()
win.button('Save', fn (w &simplegui.SimpleWindow, _ string) { /* ... */ })
win.button('Cancel', fn (w &simplegui.SimpleWindow, _ string) { /* ... */ })
win.badge('Active', 'green')
win.row_end()
```

#### Card (KPI & Metric Card)
Creates a highlighted statistic container:
```v
win.card_start('CPU Load', '38.4%', 'green')
win.label('8 Cores Active')
win.card_end()
```

#### Columns (Multi-Column Layout)
Splits content into balanced vertical columns:
```v
win.columns_start(2) // 2 equal columns

// Column 1
win.box_start('Left Column')
win.label('Details on left side')
win.box_end()

// Column 2
win.box_start('Right Column')
win.label('Details on right side')
win.box_end()

win.columns_end()
```

---

### Standard Controls

#### Label
Displays static or formatted text:
```v
win.label('This is a primary text label.')
```

#### Button
A clickable action trigger:
```v
win.button('Submit Form', fn (w &simplegui.SimpleWindow, _ string) {
	w.notification('Submitted', 'Your data was saved.')
})
```

#### Text Input
Single-line text input field with placeholder and `on_change` callback:
```v
win.input('Username', 'Enter your handle...', fn (w &simplegui.SimpleWindow, val string) {
	println('Current username: ${val}')
})
```

#### Textarea
Multi-line text editor:
```v
win.textarea('Log Output', 'System initialized.\nReady for commands.', fn (w &simplegui.SimpleWindow, val string) {
	println('Log updated')
})
```

#### Link
Clickable hyper-link opening a URL or triggering a callback:
```v
win.link('Visit GitHub Project', 'https://github.com/codecaine-zz/vlang_webview_rad_studio')
```

---

### Selection Controls

#### Checkbox
Toggleable boolean checkbox:
```v
win.checkbox('Enable Telemetry', true, fn (w &simplegui.SimpleWindow, val string) {
	// val is 'true' or 'false'
	is_checked := val == 'true'
	println('Telemetry: ${is_checked}')
})
```

#### Radio Buttons
Exclusive single-choice selection within a group:
```v
win.row_start()
win.radio('environment', 'Development', true, fn (w &simplegui.SimpleWindow, val string) {
	println('Selected: dev')
})
win.radio('environment', 'Staging', false, fn (w &simplegui.SimpleWindow, val string) {
	println('Selected: staging')
})
win.radio('environment', 'Production', false, fn (w &simplegui.SimpleWindow, val string) {
	println('Selected: prod')
})
win.row_end()
```

#### Dropdown (Select)
Popup list of options:
```v
options := ['Fast (128-bit)', 'Standard (256-bit)', 'Maximum (512-bit)']
win.select_dropdown('Encryption Level', options, 'Standard (256-bit)', fn (w &simplegui.SimpleWindow, val string) {
	println('User selected: ${val}')
})
```

#### Toggle Switch
Modern iOS/macOS-style sliding toggle switch:
```v
win.toggle('Dark Mode', true, fn (w &simplegui.SimpleWindow, val string) {
	is_on := val == 'true'
	println('Toggle: ${is_on}')
})
```

#### Slider
Numeric range slider:
```v
win.slider('Volume', 0, 100, 75, fn (w &simplegui.SimpleWindow, val string) {
	level := val.int()
	println('Volume slider: ${level}%')
})
```

---

### Desktop Menubar & Custom Context Menus

#### Top Menubar
Creates a desktop dropdown menubar across the top of your window:
```v
categories := [
	simplegui.MenuCategory{
		title: '📁 File'
		items: [
			simplegui.MenuItem{ text: '📄 New Project', action: 'file_new', shortcut: 'Cmd+N' },
			simplegui.MenuItem{ text: '📂 Open Folder', action: 'file_open', shortcut: 'Cmd+O' },
			simplegui.MenuItem{ text: '---', action: '' }, // Divider line
			simplegui.MenuItem{ text: '🚪 Exit', action: 'file_exit', shortcut: 'Cmd+Q' },
		]
	},
	simplegui.MenuCategory{
		title: '⚙️ Tools'
		items: [
			simplegui.MenuItem{ text: '📊 System Diagnostics', action: 'tools_diagnostics' },
			simplegui.MenuItem{ text: '🧹 Clear Cache', action: 'tools_cache' },
		]
	}
]

win.set_menubar(categories, fn (w &simplegui.SimpleWindow, action string) {
	match action {
		'file_new' { w.notification('Action', 'Created new project.') }
		'file_exit' { w.quit() }
		'tools_diagnostics' { w.alert('Diagnostics', 'All systems nominal.') }
		else { println('Menubar selected: ${action}') }
	}
})
```

#### Custom Right-Click Context Menu
Suppresses the browser's default reload menu and opens a custom desktop menu:
```v
context_items := [
	simplegui.MenuItem{ text: '✂️ Cut', action: 'edit_cut', shortcut: 'Cmd+X' },
	simplegui.MenuItem{ text: '📋 Copy', action: 'edit_copy', shortcut: 'Cmd+C' },
	simplegui.MenuItem{ text: '📥 Paste', action: 'edit_paste', shortcut: 'Cmd+V' },
	simplegui.MenuItem{ text: '---', action: '' },
	simplegui.MenuItem{ text: '🔄 Refresh Data', action: 'data_refresh' },
]

win.set_context_menu(context_items, fn (w &simplegui.SimpleWindow, action string) {
	println('Context action: ${action}')
})
```

---

### Data Displays

#### Data Table
Renders a structured grid of rows and columns:
```v
headers := ['ID', 'Process Name', 'Memory', 'Status']
rows := [
	['101', 'rad_studio', '34 MB', 'Running'],
	['102', 'postgres', '142 MB', 'Active'],
	['103', 'redis-server', '18 MB', 'Idle'],
]
win.table(headers, rows)
```

#### Key-Value List
Two-column property inspector list:
```v
items := {
	'OS Version': 'macOS 15.1'
	'Kernel': 'Darwin 24.1.0'
	'Architecture': 'arm64 (Apple Silicon)'
	'Memory': '32 GB Unified'
}
win.key_value_list(items)
```

#### Progress Bar & Spinner
Visual loading and completion indicators:
```v
win.progress_bar(65, 'Deploying cluster: 65%')
win.spinner('Compiling native executable...')
```

#### Status Bar
Docked bottom status message:
```v
win.status_bar('Ready | 3 Services Connected | Port: 8080')
```

---

### Desktop Triggers

#### Interval Timer
Executes a background callback repeatedly at a given millisecond interval:
```v
win.timer(1000, fn (w &simplegui.SimpleWindow, _ string) {
	println('1 second tick')
})
```

#### Native Notification
Displays an OS toast or banner:
```v
win.notification('Backup Completed', 'All 4 databases saved successfully.')
```

#### Native File Picker Dialogs
Invokes the operating system's native Cocoa/Win32/GTK file dialog:
```v
win.button('Select File', fn (w &simplegui.SimpleWindow, _ string) {
	path := system.open_file_dialog('Select Configuration File', '')
	if path != '' {
		w.notification('Selected', path)
	}
})
```

---

### Window Management & Shortcuts

Call these methods directly on `w &simplegui.SimpleWindow`:

```v
w.toggle_fullscreen()         // Toggle fullscreen on/off (Shortcut: Cmd+F / F11)
w.set_fullscreen(true)        // Explicitly set fullscreen state
w.set_always_on_top(true)     // Pin window stay-on-top (Shortcut: Cmd+Shift+T)
w.center()                    // Center window on primary monitor (Cmd+Shift+C)
w.minimize()                  // Minimize window to dock/taskbar (Cmd+M)
w.hide()                      // Hide window from view
w.set_position('center')      // Presets: 'upper_left', 'upper_right', 'bottom_left', 'bottom_right', 'center'
w.quit()                      // Gracefully terminate application process
```

---

### Dynamic Theme Switcher

Switch between any of the **42 built-in themes** instantly at runtime without reloading:

```v
// Switch programmatically
win.set_theme('tokyo_night')
win.set_theme('monokai_pro')
win.set_theme('cyberpunk')
win.set_theme('matrix_phosphor')
win.set_theme('github_light')
win.set_theme('win95')

// Or wire into a dropdown for your users:
themes := simplegui.get_theme_names()
win.select_dropdown('Theme Palette', themes, 'tokyo_night', fn (w &simplegui.SimpleWindow, val string) {
	w.set_theme(val)
})
```

---

### Named Builder & Fluent Control API (`vlang_simplegui` Parity)

RAD Studio provides complete 1:1 API parity with [`vlang_simplegui`](https://github.com/codecaine-zz/vlang_simplegui), supporting explicit control ID registration, fluent chaining modifiers, event binding, layout containers, and live state access.

#### 1. Constructor Parity
```v
// Create a new window with title, width, and height:
mut win := simplegui.new_simple_window('DevOps Workstation', 1024, 768)
```

#### 2. Named Control Builders
Add controls by unique ID with default values and configure them fluently:
```v
// Text & Headers
win.add_heading('lbl_title', 'System Dashboard')
win.add_subheading('lbl_subtitle', 'Real-time telemetry and process monitor')
win.add_section_header('sec_core', 'Core Telemetry')
win.add_label('lbl_info', 'All services nominal.')
win.add_hotkey_badge('badge_hk', 'Cmd+Shift+R')

// Inputs & Fields
win.add_input('txt_search', '').placeholder('Search processes...')
win.add_search_field('txt_find', '').placeholder('Filter logs...')
win.add_password('txt_pwd', '').placeholder('Enter API secret...')
win.add_textarea('txt_notes', 'Initial notes here...').height(120)
win.add_number_input('num_port', 8080)
win.add_date_picker('dt_start', '2026-09-10')
win.add_color_picker('clr_accent', '#38bdf8')

// Buttons
win.add_button('btn_deploy', '🚀 Deploy Application').bold().background_color('#2563eb')
win.add_image_button('btn_img', '📷', 'Take Snapshot')
win.add_help_button('btn_help', 'View Documentation')
win.add_split_button('btn_split', 'Build', 'Run')
win.add_badge_button('btn_alerts', 'Notifications', '3')

// Selections, Radios & Menus
win.add_checkbox('chk_autostart', 'Launch on startup', true)
win.add_switch('sw_dark', 'Dark Theme Mode', true)
win.add_toggle('tg_pin', 'Pin Always On Top', false)
win.add_radio('rad_prod', 'env_group', 'Production', true)
win.add_radio('rad_stag', 'env_group', 'Staging', false)
win.add_radio_group('grp_nodes', ['Node A', 'Node B', 'Node C'], 0)
win.add_dropdown('dd_region', ['us-east-1', 'us-west-2', 'eu-west-1'], 0)
win.add_pull_down('pd_branch', ['main', 'develop', 'feature/rad'], 0)
win.add_combo_box('cb_speed', ['Fast (1x)', 'Super (2x)', 'Ultra (4x)'], 1)
win.add_theme_menu('menu_theme', 'tokyo_night')
win.add_segmented_control('seg_view', ['Live Metrics', 'Historical', 'Raw JSON'], 0)
win.add_mode_control('mode_env', ['Dev', 'Test', 'Prod'], 0)

// Progress & Metrics
win.add_slider('sld_cpu_limit', 10, 100, 75)
win.add_stepper('stp_replicas', 1, 32, 4)
win.add_progress_indicator('prg_sync', 68)
win.add_progress_bar('prg_upload', 92)
win.add_circular_progress('prg_disk', 45)
win.add_kpi_card('kpi_mem', 'Memory Usage', '4.2 GB / 16 GB', 'green')
win.add_badge('bdg_status', 'ONLINE', 'green')

// Rich Visual Components
win.add_code_view('code_snippet', 'console.log("RAD Studio Running");', 'javascript')
win.add_markdown('md_readme', '### Markdown Preview\nSupports **bold**, `code`, and lists.')
win.add_alert_banner('banner_warn', 'warning', 'High disk usage detected on volume /data.')
win.add_table('tbl_nodes', ['Node ID', 'Status', 'IP Address'], [
    ['worker-01', 'Healthy', '10.0.0.12'],
    ['worker-02', 'Healthy', '10.0.0.13'],
    ['worker-03', 'Standby', '10.0.0.14']
])
win.add_image('img_logo', 'https://vlang.io/img/v-logo.png', 120, 120)
win.add_status_bar('bar_bottom', 'Ready | Connected to 127.0.0.1:4000')
win.add_divider()
win.add_spacer(16)
```

#### 3. Layout Containers
Structure your controls with clean nested closures or begin/end blocks:
```v
// Row container:
win.begin_row()
win.add_button('btn_run', 'Run')
win.add_button('btn_stop', 'Stop')
win.end_row()

// Fluent closure-based row:
win.row(fn [mut win] () {
    win.add_button('btn_prev', '⬅ Previous')
    win.add_button('btn_next', 'Next ➡')
})

// Grid container:
win.begin_grid(3) // 3 equal columns
win.add_kpi_card('c1', 'CPU', '12%', 'blue')
win.add_kpi_card('c2', 'RAM', '34%', 'green')
win.add_kpi_card('c3', 'NET', '1.2 MB/s', 'purple')
win.end_grid()

// Card & Group containers:
win.card_with_title('Database Credentials', fn [mut win] () {
    win.add_input('txt_host', 'localhost')
    win.add_number_input('num_db_port', 5432)
})

win.group('Cache Settings', fn [mut win] () {
    win.add_checkbox('chk_redis', 'Enable Redis Cache', true)
    win.add_slider('sld_ttl', 60, 3600, 300)
})

// Tabbed Views & Scroll Views:
win.add_tabs('tab_main', ['Overview', 'Console', 'Settings'])
win.add_scroll_view('scroll_logs', 250)
```

#### 4. Event Wiring & Callbacks
Wire clicks, value changes, and Enter key presses by control ID:
```v
// Button Click:
win.on_click('btn_deploy', fn (w &simplegui.SimpleWindow, _ string) {
    w.toast_success('Deployment started!')
})

// Input Value Change:
win.on_change('txt_search', fn (w &simplegui.SimpleWindow, query string) {
    println('Searching for: ${query}')
})

// Enter Key Press in Input:
win.on_enter('txt_search', fn (w &simplegui.SimpleWindow, query string) {
    w.toast('Executing search for: ' + query)
})

// Dropdown / Selection Item Change:
win.on_select_item('dd_region', fn (w &simplegui.SimpleWindow, selected string) {
    println('Selected Region: ${selected}')
})
```

#### 5. Fluent Modifiers
Chain visual styling directly when adding controls:
```v
win.add_button('btn_action', 'Execute')
    .width(200)
    .height(44)
    .bold()
    .font_size(15)
    .font_color('#ffffff')
    .background_color('#10b981')
    .tooltip('Execute the selected playbook')
    .expand_fill(true)
```

#### 6. Live Value Inspection & Mutation
Query or update controls programmatically at runtime:
```v
// Reading values:
name := win.get_text('txt_search')
checked := win.get_bool('chk_autostart')
port := win.get_int('num_port')

// Mutating values:
win.set_text('lbl_info', 'Task completed successfully.')
win.set_progress('prg_upload', 100)
win.set_status('bar_bottom', 'Deployment Finished')
win.set_control_enabled('btn_deploy', false)
win.set_control_visible('banner_warn', false)

// Inspection:
if win.has_control('btn_deploy') {
    println('Controls count: ${win.list_controls().len}')
}
```

#### 7. Window Manipulation, Effects & Toasts
Easily control native desktop window placement and show polished toasts:
```v
// Toasts:
w.toast('Operation submitted.')
w.toast_success('Database connection established!')
w.toast_error('Failed to authenticate token.')

// Window Effects:
w.shake_window()           // Shake window for invalid input
w.bounce_dock()            // Bounce macOS Dock icon for notifications
w.request_attention()      // Flashes window / requests OS attention

// Positioning & Presets:
w.center_on_screen()       // Center window on active monitor
w.set_position_preset('top_center') // upper_left, top_center, upper_right, bottom_left, bottom_center, bottom_right, center
w.set_fixed_size(800, 600) // Disable window resizing
w.set_opacity(0.95)        // Set window transparency
w.make_always_on_top()     // Keep pinned on top of other windows
w.make_frameless()         // Hide OS titlebar
w.make_utility_panel()     // Configure as floatable utility tool window
w.make_modal()             // Modal dialog configuration
w.close()                  // Close window
w.quit()                   // Terminate application
```

---

## 4. System Module: `system/sys.v`

Import with:
```v
import system
```

### Safe Command & Process Execution

```v
// 1. Run a command and capture output
output := system.exec('uptime')
println('Uptime: ${output}')

// 2. Run a command with fallback if it fails
branch := system.exec_or('git branch --show-current', 'main')

// 3. Execute inside a specific working directory
files := system.exec_in_dir('ls -la', '/Users/username/Projects')

// 4. Run asynchronously in background (non-blocking)
system.exec_bg('sleep 5 && say "Task done"')

// 5. Execute and receive full CommandResult (stdout, stderr, exit code)
res := system.exec_cmd('git status --porcelain')
println('Exit Code: ${res.exit_code}, Success: ${res.success}')
```

### Process Management & Lifecycle

```v
// Get current application Process ID (PID)
pid := system.get_pid()

// Check if an external command or binary is installed in system PATH
has_docker := system.has_command('docker')
bin_path := system.get_command_path('git')

// Check if a process is running by name
is_running := system.is_process_running('redis-server')

// Count total running processes and open file descriptors
proc_count := system.get_running_process_count()
open_files := system.get_open_file_count()

// Kill a process safely by PID or name
system.kill_process_by_pid(1234)
system.kill_process_by_name('rogue_worker')
```

### Cross-Platform Paths & App Directories

Automatically resolves canonical OS paths (macOS `~/Library`, Linux `~/.config`, Windows `%APPDATA%`):

```v
app := 'MyStudio'

config_dir := system.get_app_config_dir(app)   // e.g. ~/.config/MyStudio
data_dir   := system.get_app_data_dir(app)     // e.g. ~/Library/Application Support/MyStudio
cache_dir  := system.get_app_cache_dir(app)    // e.g. ~/Library/Caches/MyStudio
log_dir    := system.get_app_log_dir(app)      // e.g. ~/.local/state/MyStudio/logs

// Direct paths to standard files
cfg_file   := system.get_app_config_file(app, 'settings.json')
state_file := system.get_app_state_file(app, 'session.json')

// Expand tilde ~ paths
full_path  := system.resolve_user_path('~/Documents/report.pdf')
```

### File Operations, Directory Sizing & Archives

```v
path := '/tmp/sample.txt'

// 1. Check existence and types
exists := system.file_exists(path)
is_directory := system.is_dir('/tmp')

// 2. Read and write text files safely
system.write_file(path, 'Hello from V!')
content := system.read_file(path)
system.append_file(path, '\nAppended line')

// 3. File metadata
meta := system.get_file_metadata(path)
println('Size: ${meta.size} bytes, Modified: ${meta.modified_time}')

// 4. Directory size (recursive byte count)
dir_bytes := system.get_directory_size('/Users/username/Projects')

// 5. Disk storage usage
usage := system.get_disk_usage('/')
println('Disk Total: ${usage.total_bytes / 1024 / 1024 / 1024} GB, Used: ${usage.usage_percent}%')

// 6. Native deletion and trash bin
system.trash_file(path) // Moves to macOS Trash / Windows Recycle Bin
system.delete_file(path) // Direct unlink

// 7. Zip and Unzip archives
system.zip_directory('/tmp/my_folder', '/tmp/my_folder.zip')
system.unzip_archive('/tmp/my_folder.zip', '/tmp/extracted')

// 8. File hashes
sha := system.sha256_file('/tmp/data.bin')
md5 := system.md5_file('/tmp/data.bin')
```

### Hardware Telemetry

```v
info := system.get_hardware_info()

println('CPU: ${info.cpu_model} (${info.cpu_cores} cores)')
println('CPU Usage: ${info.cpu_usage_pct}%')
println('RAM: ${info.ram_used_mb} MB used / ${info.ram_total_mb} MB total (${info.ram_usage_pct}%)')
println('Battery: ${info.battery_pct}% (Charging: ${info.battery_charging})')
println('System Uptime: ${info.uptime}')
```

### Power, Display & Theme Controls

```v
// Check system dark mode
is_dark := system.is_dark_mode()

// Sleep or lock
system.sleep_display()
system.lock_screen()

// Prevent OS from sleeping during long background renders/downloads
system.prevent_sleep_bg(3600) // 1 hour keep-awake
```

### Audio, Speech & Sound Effects

```v
// 1. System alert beeps
system.beep()
system.beep_n(3) // 3 rapid beeps

// 2. Text-to-Speech (macOS 'say' / Windows SAPI / Linux espeak)
system.say('Build succeeded!')
system.speak_with_voice('Alert: high temperature detected.', 'Samantha')

// 3. Volume and mute control
vol := system.get_volume() // 0 to 100
system.set_volume(80)
system.set_muted(false)
```

### Network Diagnostics & Font Resolution

```v
// 1. Ping latency test
ms := system.ping('1.1.1.1') // Returns latency in ms, or -1 on timeout

// 2. IP addresses (Privacy-Protected)
masked_ip := system.get_masked_ip()   // e.g. "192.168.***.*** (Protected)"
raw_ip := system.get_local_ip()       // Internal raw local IP
public_ip := system.get_public_ip()   // Protected external IP indicator

// 3. Port check & discovery
is_open := system.is_port_open('localhost', 5432)
free_port := system.find_available_port(8000)

// 4. Download file from web
system.download_file('https://example.com/logo.png', '/tmp/logo.png')

// 5. Cross-platform font file resolution
mono_font := system.resolve_window_font_path('monospace')
```

---

## 5. Standard Library: `system/stdlib.v`

### Resilient HTTP Client

```v
// 1. Simple GET & POST
res := system.http_get('https://api.github.com')
println('Status: ${res.status_code}, Length: ${res.body.len}')

post_res := system.http_post('https://httpbin.org/post', '{"key":"value"}')

// 2. Advanced request with custom headers, retries, and User-Agent
opt := system.SimpleHttpRequestOptions{
	headers: { 'Authorization': 'Bearer TOKEN_123', 'Accept': 'application/json' }
	user_agent: 'MyStudio/2.0'
	retries: 3
	retry_delay_ms: 500
}
req_res := system.http_request('GET', 'https://api.example.com/data', '', opt)
```

### Cryptography

#### AES CBC Encryption (with PKCS#7 Padding)
```v
key_hex := '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f' // 32-byte (256-bit)
plaintext := 'Secret database credentials'

// Encrypt (generates random IV, prepends to ciphertext)
cipher_hex := system.crypto_encrypt_aes_secure(plaintext, key_hex)!

// Decrypt
decrypted := system.crypto_decrypt_aes_secure(cipher_hex, key_hex)!
assert decrypted == plaintext
```

#### Ed25519 Digital Signatures
```v
// Generate keypair
kp := system.crypto_ed25519_keypair()

message := 'Approve deployment #42'
sig := system.crypto_ed25519_sign(message, kp.priv_key)

// Verify
is_valid := system.crypto_ed25519_verify(message, sig, kp.pub_key)
println('Signature authentic: ${is_valid}')
```

#### Password Hashing (Bcrypt & PBKDF2)
```v
// Bcrypt
hash := system.crypto_bcrypt_hash('UserMasterPassword', 10)!
valid := system.crypto_bcrypt_verify('UserMasterPassword', hash)

// PBKDF2 SHA-256
derived := system.crypto_pbkdf2_sha256('password', 'salt1234', 10000, 32)!
```

#### Hashing & UUID
```v
uuid := system.crypto_uuid_v4()          // e.g. "c9a646d3-9c61-4cc9-bc01-90be5cbe9847"
sha := system.hash_sha256('Hello World') // Standard SHA-256 hex
md5 := system.hash_md5('Hello World')
hmac := system.hmac_sha256('secret_key', 'payload_data')
```

---

### Regular Expressions

```v
text := 'Contact admin@example.com or support@company.org'
pattern := r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

// Find all matches
matches := system.regex_find_all(pattern, text)
// ['admin@example.com', 'support@company.org']

// Replace matches
masked := system.regex_replace(pattern, text, '[REDACTED_EMAIL]')
```

---

### Gzip & Zlib Compression

```v
data := 'Repeat text '.repeat(100)

// Gzip
compressed := system.gzip_compress(data)!
restored := system.gzip_decompress(compressed)!

// Zlib
z_comp := system.zlib_compress(data)!
z_rest := system.zlib_decompress(z_comp)!
```

---

### Randomness & Combinatorics

```v
rand_num := system.rand_int_range(1, 100)
rand_float := system.rand_f64_range(0.0, 1.0)
token := system.rand_string(16) // Random 16-char alphanumeric string

mut deck := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
system.rand_shuffle(mut deck)

sample := system.rand_sample(deck, 3) // Pick 3 random items
```

---

### Concurrency Helpers

```v
// Mutex
mut m := system.new_mutex()
m.lock()
// ... critical section ...
m.unlock()

// WaitGroup
mut wg := system.new_waitgroup()
wg.add(2)

spawn fn (mut w system.SimpleWaitGroup) {
	// ... do background task 1 ...
	w.done()
}(mut wg)

spawn fn (mut w system.SimpleWaitGroup) {
	// ... do background task 2 ...
	w.done()
}(mut wg)

wg.wait() // Blocks until all tasks complete
```

---

### Complex Numbers, Trigonometry & Math

```v
// Complex Numbers
c1 := system.new_complex(3.0, 4.0)
c2 := system.new_complex(1.0, 2.0)
c3 := c1.add(c2)
println(c3.str()) // '4.000000 + 6.000000i'
println('Magnitude: ${c1.abs()}') // 5.0

// Trigonometry & Math Helpers
rad := system.math_deg2rad(180.0) // 3.14159...
deg := system.math_rad2deg(3.141592653589793)
hyp := system.math_hypot(3.0, 4.0) // 5.0
gcd := system.math_gcd(48, 18) // 6
lcm := system.math_lcm(4, 6) // 12
val := system.math_clamp(150.0, 0.0, 100.0) // 100.0
lerp := system.math_lerp(0.0, 100.0, 0.5) // 50.0
smooth := system.math_smoothstep(0.0, 1.0, 0.5) // Hermite curve
```

---

### Statistical Analysis

```v
numbers := [12.0, 15.0, 23.0, 29.0, 45.0, 12.0, 18.0]

stats := system.calculate_stats(numbers)!
println('Mean: ${stats.mean}')
println('Median: ${stats.median}')
println('StdDev: ${stats.std_dev}')
println('Variance: ${stats.variance}')
println('Min: ${stats.min}, Max: ${stats.max}')

mode := system.stats_mode(numbers) // 12.0
rms := system.stats_rms(numbers)
```

---

### String Metrics & Manipulations

```v
// 1. Slugs & Titles
slug := system.slugify('Hello World! This is V.') // "hello-world-this-is-v"
title := system.title_case('the lord of the rings') // "The Lord Of The Rings"

// 2. Metrics & Palindromes
is_pal := system.is_palindrome('racecar') // true
words := system.word_count('one two three four') // 4
u_len := system.utf8_len('Hello 🚀') // 7 characters

// 3. String Distance & Similarity
jaro := system.string_jaro_similarity('martha', 'marhta') // 0.9444...
winkler := system.string_jaro_winkler('dwayne', 'duane')
lev := system.string_levenshtein('kitten', 'sitting') // 3
hamming := system.string_hamming_distance('karolin', 'kathrin') // 3

// 4. StringBuilder
mut sb := system.new_string_builder()
sb.write('Part 1 ')
sb.write_line('Line 2')
result := sb.str()
```

---

### URL Object Model & HTML Scraper

#### URL Parsing & Building
```v
url_obj := system.url_parse('https://example.com:8080/search?q=vlang&lang=en#top')
println('Host: ${url_obj.host}') // example.com
println('Query: ${url_obj.query}') // {'q': 'vlang', 'lang': 'en'}

built := system.url_build('https', 'api.dev', '/v1/users', {'active': 'true'})
```

#### HTML Scraping
```v
html_str := '<html><body><h1>Title</h1><div class="content"><a href="https://vlang.io">V Website</a></div></body></html>'
doc := system.html_parse(html_str)

h1_text := doc.get_tag_text('h1') // "Title"
links := doc.get_all_links()       // ["https://vlang.io"]
plain := doc.strip_tags()          // "Title V Website"
```

---

### CSV Matrices & Generic Data Structures

#### CSV
```v
rows := [
	['Name', 'Role', 'Department'],
	['Alice', 'Engineer', 'DevOps'],
	['Bob', 'Designer', 'Product'],
]

// Extract second column (Role)
roles := system.csv_extract_column(rows, 1) // ['Role', 'Engineer', 'Designer']

// Filter rows where Department == DevOps
devops_team := system.csv_filter_rows(rows, 2, 'DevOps')
```

#### Generic Data Structures
```v
// 1. Stack
mut stack := system.new_stack[string]()
stack.push('A')
stack.push('B')
item := stack.pop() // 'B'

// 2. Queue
mut queue := system.new_queue[int]()
queue.enqueue(10)
queue.enqueue(20)
first := queue.dequeue() // 10

// 3. Set (Unique items)
mut set := system.new_set[string]()
set.add('alpha')
set.add('beta')
set.add('alpha')
assert set.size() == 2
```

---

### Time, Calendar & JSON

#### Date & Time Utilities
```v
// Current timestamp string: "YYYY-MM-DD HH:mm:ss"
now := system.time_now()

// Unix epoch timestamp
ts := system.time_unix_timestamp()

// Convert Unix epoch timestamp to formatted string
formatted := system.time_from_unix(ts)

// Calendar calculations & leap year checks
is_leap := system.time_is_leap_year(2024)      // true
days := system.time_days_in_month(2024, 2)     // 29

// Validation helpers
valid_date := system.is_valid_date_str('2026-09-10') // true
valid_time := system.is_valid_time_str('14:30')      // true
```

#### JSON Validation & Prettification
```v
raw_json := '{"name":"RAD Studio","version":"1.0"}'

// Validate syntax
if system.json_validate(raw_json) {
	println('Valid JSON payload')
}

// Pretty print with formatted indentation
pretty := system.json_pretty_print(raw_json)
```

---

## 6. Security Module: `system/security.v`

Import with:
```v
import system
```

### Shell Injection Prevention
Never concatenate raw user strings into shell commands. Use these utilities:

```v
// 1. Quote an argument for shell safety
user_input := 'test; rm -rf /'
safe_arg := system.quote_arg(user_input) // Escapes quotes and special characters

// 2. Execute directly without a shell (immune to injection)
args := ['clone', '--depth', '1', 'https://github.com/vlang/v']
res := system.exec_safe('git', args)
println('Git stdout: ${res.stdout}')

// 3. Safe execution with piped standard input
cat_res := system.exec_safe_stdin('cat', [], 'Piped secret content')
```

### Path Traversal & Filename Sanitization

```v
// 1. Sanitize user-uploaded filename
unsafe_filename := '../../etc/passwd\0file.txt'
clean_name := system.sanitize_filename(unsafe_filename)
// "etc_passwd_file.txt" (traversals and null bytes stripped)

// 2. Validate sandbox boundary
is_safe := system.validate_path('/var/app/data', '/var/app/data/uploads/image.png') // true
is_exploit := system.validate_path('/var/app/data', '/var/app/data/../../etc/shadow') // false
```

### Constant-Time Comparison & Secret Masking

```v
// Prevent timing side-channel attacks during token/password verification
tokens_match := system.constant_time_compare(user_token, secret_token)

// Mask sensitive keys for logs or UI displays
api_key := 'sk-proj-9847192837491823749182'
masked := system.mask_secret(api_key, 4) // "sk-p******************9182"
```

### HTML Sanitization & Safe URLs

```v
// Strip HTML injection / XSS vectors
clean_text := system.sanitize_html('<script>alert("hacked")</script>')
// "&lt;script&gt;alert(&quot;hacked&quot;)&lt;/script&gt;"

// Validate safe URL schemes
valid_url := system.is_safe_url('https://secure.example.com') // true
blocked := system.is_safe_url('javascript:stealCookies()') // false
```

### Cryptographic Token Generation

```v
token := system.generate_secure_token(32) // 64-char hex cryptographically random token
```

---

## 7. State Module: `system/state.v`

Import with:
```v
import system
```

### Crash-Proof Atomic File Writing

Writing directly to a file can corrupt it if the user closes the app or power is lost mid-write. `write_file_atomic` writes to a temporary swap file, flushes to disk (`fsync`), and atomically replaces the destination:

```v
system.write_file_atomic('/tmp/critical_data.json', '{"status":"ok"}')
```

### Typesafe JSON State Serialization

```v
struct UserProfile {
pub mut:
	username string
	theme    string
	runs     int
}

// 1. Save state
profile := UserProfile{
	username: 'alex'
	theme: 'cyberpunk'
	runs: 42
}
system.save_state_to_file('/tmp/profile.json', profile)!

// 2. Load state
restored := system.load_state_from_file[UserProfile]('/tmp/profile.json')!
println('Loaded user: ${restored.username}, Runs: ${restored.runs}')
```

### Application-Scoped Preferences

Stores state inside standard OS config folders automatically (`~/.config/AppName/filename`):

```v
struct AppConfig {
pub mut:
	last_tab    string
	auto_update bool
}

// Save inside ~/.config/DevOpsSentinel/settings.json
system.save_app_state('DevOpsSentinel', 'settings.json', AppConfig{
	last_tab: 'metrics'
	auto_update: true
})

// Load with automatic defaults if file does not exist yet
cfg := system.load_app_state_or('DevOpsSentinel', 'settings.json', AppConfig{
	last_tab: 'overview'
	auto_update: false
})
```

---

## 8. End-to-End Tutorial: Building a Production DevOps Workstation

Here is a complete, working, production-grade application demonstrating how SimpleGUI, hardware telemetry, security, and state persistence work together seamlessly:

```v
module main

import simplegui
import system

fn main() {
	// 1. Load saved preferences or use defaults
	mut state := system.load_app_state_or('DevOpsWorkstation', 'state.json')
	target_host := state['target_host'] or { '1.1.1.1' }

	mut win := simplegui.new_window(
		title: 'DevOps Hardware & Network Sentinel'
		width: 1024
		height: 720
		theme: 'tokyo_night'
		fullscreen: true
	)

	// 2. Menubar
	win.set_menubar([
		simplegui.MenuCategory{
			title: '⚡ Actions'
			items: [
				simplegui.MenuItem{ text: '🔄 Refresh Now', action: 'refresh', shortcut: 'Cmd+R' },
				simplegui.MenuItem{ text: '🚪 Quit', action: 'quit', shortcut: 'Cmd+Q' },
			]
		}
	], fn (w &simplegui.SimpleWindow, action string) {
		if action == 'quit' { w.quit() }
	})

	// 3. Hardware KPI Cards
	hw := system.get_hardware_telemetry()
	win.box_start('Hardware Telemetry')
	win.row_start()
	win.kpi_card('CPU Model', hw.cpu_model, '${hw.cpu_cores} Cores (${hw.cpu_usage.str()}% load)')
	win.kpi_card('Memory (RAM)', hw.ram_formatted, 'RAM in use')
	win.kpi_card('Battery', '${hw.battery_percent}%', if hw.battery_charging { '⚡ Charging' } else { '🔋 On Battery' })
	win.row_end()
	win.box_end()

	// 4. Network Diagnostics Section
	win.box_start('Network Health')
	win.row_start()
	masked_ip := system.get_masked_ip()
	is_online := system.ping_host(target_host)
	win.label('Network IP: ${masked_ip} | Host ${target_host}: ' + if is_online { 'ONLINE ✅' } else { 'OFFLINE ❌' })
	win.row_end()
	win.box_end()

	// 5. Actions & Window Controls
	win.box_start('Quick Controls')
	win.row_start()
	win.button('⛶ Toggle Fullscreen (Cmd+F)', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.button('📌 Pin On Top (Cmd+Shift+T)', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_always_on_top(true)
		w.notification('Window Pinned', 'Sentinel is now always on top.')
	})
	win.button('🎯 Center Window', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.button('🔊 Sound Test', fn (w &simplegui.SimpleWindow, _ string) {
		system.sys_beep()
	})
	win.row_end()
	win.box_end()

	// 5. Actions & Window Controls
	win.box_start('Quick Controls')
	win.row_start()
	win.button('⛶ Toggle Fullscreen (Cmd+F)', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.button('📌 Pin On Top (Cmd+Shift+T)', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_always_on_top(true)
		w.notification('Window Pinned', 'Sentinel is now always on top.')
	})
	win.button('🎯 Center Window', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.button('🔊 Sound Test', fn (w &simplegui.SimpleWindow, _ string) {
		system.sys_beep()
	})
	win.row_end()
	win.box_end()

	win.status_bar('DevOps Sentinel: Active | Host: ${target_host} | Press Cmd+Q to Exit')

	// 6. Run Application
	win.run()
}
```

---

## 9. Packaging & Distribution Guide (`build.vsh`)

The included `build.vsh` script compiles, brands, and packages standalone distribution bundles:

```bash
# Build the Visual RAD Studio IDE
v build.vsh

# Build any specific application:
v build.vsh applications/system_studio.v
v build.vsh applications/crypto_studio.v
v build.vsh applications/database_studio.v

# Build any interactive demo:
v build.vsh demos/22_context_menu_and_menu_demo.v
```

### What `build.vsh` does automatically:
- **macOS (`.app` Bundle)**:
  - Generates `dist/AppName.app/Contents/MacOS` and embeds the native binary.
  - Generates multi-resolution Retina icons (`AppIcon.icns`) from `resources/icon.png` using Apple's `sips` and `iconutil`.
  - Configures `Info.plist` with proper bundle identifiers, minimum macOS target, and High-DPI support.
  - Codesigns with ad-hoc identity (`codesign -f -s -`) and clears gatekeeper quarantine attributes (`xattr -cr`).
- **Windows (`.exe`)**:
  - Compiles with optimization (`-prod`) and embeds Windows application resources.
- **Linux (`ELF` Binary + `.desktop`)**:
  - Compiles standard native ELF binary and generates a desktop entry conforming to Freedesktop standards.
