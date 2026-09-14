# 📘 V Webview RAD Studio & SimpleGUI: Complete API Reference & Developer Guide

Welcome to the comprehensive API manual for **V Webview RAD Studio**. This guide is designed so that anyone—from beginners and non-programmers to seasoned software engineers—can build, run, and ship cross-platform desktop applications in minutes.

---

## 📑 Table of Contents

1. [Architectural Philosophy: How Desktop Apps Are Built](#1-architectural-philosophy-how-desktop-apps-are-built)
2. [Quickstart: Your First Application in 60 Seconds](#2-quickstart-your-first-application-in-60-seconds)
   - [Installing Webview (`v install ttytm.webview`)](#installing-webview-v-install-ttytmwebview)
   - [Creating Your First SimpleGUI Window](#creating-your-first-simplegui-window)
3. [SimpleGUI: Declarative Window & UI Controls](#3-simplegui-declarative-window--ui-controls)
   - [Window Setup & Configuration](#window-setup--configuration)
   - [Containers & Layouts (Boxes, Rows, Cards, Columns)](#containers--layouts)
   - [Standard Controls (Buttons, Inputs, Textareas, Labels)](#standard-controls)
   - [Selection Controls (Checkboxes, Radios, Dropdowns, Toggles, Sliders)](#selection-controls)
   - [Desktop Menubar & Custom Context Menus](#desktop-menubar--custom-context-menus)
   - [Data Displays (Tables, Key-Value Lists, Badges, Tags, Progress)](#data-displays)
   - [Desktop Triggers (Timers, File Pickers, Notifications, Dialogs)](#desktop-triggers)
   - [Window Management & Shortcuts](#window-management--shortcuts)
   - [Dynamic Theme Switcher (76 Form Themes)](#dynamic-theme-switcher)
   - [Named Builder & Fluent Control API (`vlang_simplegui` Parity)](#named-builder--fluent-control-api-vlang_simplegui-parity)
4. [System Module: `system/sys.v` (OS & Hardware Telemetry)](#4-system-module-systemsysv)
   - [Safe Command & Process Execution](#safe-command--process-execution)
   - [Process Management & Lifecycle](#process-management--lifecycle)
   - [Cross-Platform Paths & App Directories](#cross-platform-paths--app-directories)
   - [File Operations, Directory Sizing & Archives](#file-operations-directory-sizing--archives)
   - [Hardware Telemetry (CPU, RAM, Battery, Uptime)](#hardware-telemetry)
   - [Power, Display & Theme Controls](#power-display--theme-controls)
   - [Audio, Speech & Sound Effects](#audio-speech--sound-effects)
   - [Network Diagnostics & Font Resolution](#network-diagnostics--font-resolution)
5. [Standard Library: `system/stdlib.v` (Algorithms & Encoders)](#5-standard-library-systemstdlibv)
   - [Resilient HTTP Client](#resilient-http-client)
   - [Cryptography (AES, Ed25519, PBKDF2, Bcrypt, UUID, Hashes)](#cryptography)
   - [Regular Expressions](#regular-expressions)
   - [Gzip & Zlib Compression](#gzip--zlib-compression)
   - [Randomness & Combinatorics](#randomness--combinatorics)
   - [Concurrency Helpers (Mutex & WaitGroup)](#concurrency-helpers)
   - [Complex Numbers, Trigonometry & Math](#complex-numbers-trigonometry--math)
   - [Statistical Analysis](#statistical-analysis)
   - [String Metrics & Manipulations](#string-metrics--manipulations)
   - [URL Object Model & HTML Scraper](#url-object-model--html-scraper)
   - [CSV Matrices & Generic Data Structures](#csv-matrices--generic-data-structures)
   - [Time, Calendar & JSON](#time-calendar--json)
6. [Security Module: `system/security.v` (Defensive Coding)](#6-security-module-systemsecurityv)
   - [Shell Injection Prevention](#shell-injection-prevention)
   - [Path Traversal & Filename Sanitization](#path-traversal--filename-sanitization)
   - [Constant-Time Comparison & Secret Masking](#constant-time-comparison--secret-masking)
   - [HTML Sanitization & Safe URLs](#html-sanitization--safe-urls)
   - [Cryptographic Token Generation](#cryptographic-token-generation)
7. [State Module: `system/state.v` (Persistence & Configuration)](#7-state-module-systemstatev)
   - [Crash-Proof Atomic File Writing](#crash-proof-atomic-file-writing)
   - [Typesafe JSON State Serialization](#typesafe-json-state-serialization)
   - [Application-Scoped Preferences](#application-scoped-preferences)
8. [End-to-End Tutorial: Building a Production DevOps Workstation](#8-end-to-end-tutorial-building-a-production-devops-workstation)
9. [Packaging & Distribution Guide (`build.vsh`)](#9-packaging--distribution-guide-buildvsh)
10. [Enterprise Desktop Application Suite (18 Complete Studios)](#10-enterprise-desktop-application-suite-18-complete-studios)
    - [Desktop Workstations Architecture & Engineering Principles](#desktop-workstations-architecture--engineering-principles)
    - [Studio Suite Matrix & Quick Reference](#studio-suite-matrix--quick-reference)
    - [Deep Dive: All 18 Enterprise Applications](#deep-dive-all-18-enterprise-applications)
11. [Companion CLI Suite & Automation API (16 Complete Tools)](#11-companion-cli-suite--automation-api-16-complete-tools)

- [CLI Architecture & Performance Advantages](#cli-architecture--performance-advantages)
- [CLI Suite Quick Reference](#cli-suite-quick-reference)
- [System & Hardware Workstation (`system_cli`)](#system--hardware-workstation-system_cli)
- [Cryptographic Hashing & Encoders (`crypto_cli`)](#cryptographic-hashing--encoders-crypto_cli)
- [JSON Inspector, Validator & Formatter (`json_cli`)](#json-inspector-validator--formatter-json_cli)
- [Developer Omnitool & Math Statistics (`devtools_cli`)](#developer-omnitool--math-statistics-devtools_cli)
- [Process & Task Manager (`process_cli`)](#process--task-manager-process_cli)
- [SQLite Database Console (`database_cli`)](#sqlite-database-console-database_cli)
- [HTTP & REST API Client (`api_cli`)](#http--rest-api-client-api_cli)
- [Data Format Converter (`dataconvert_cli`)](#data-format-converter-dataconvert_cli)
- [File System Watcher & Trigger (`watcher_cli`)](#file-system-watcher--trigger-watcher_cli)
- [Regular Expression Tester (`regex_cli`)](#regular-expression-tester-regex_cli)
- [Desktop App Packager & Bundler (`app_bundler_cli`)](#desktop-app-packager--bundler-app_bundler_cli)
- [Network Diagnostics & Ping Telemetry (`network_cli`)](#network-diagnostics--ping-telemetry-network_cli)
- [Visual Git Workstation (`git_cli`)](#visual-git-workstation-git_cli)
- [Markdown to HTML Compiler (`markdown_cli`)](#markdown-to-html-compiler-markdown_cli)
- [Color & WCAG Contrast Inspector (`color_cli`)](#color--wcag-contrast-inspector-color_cli)
- [Environment Variables Manager (`env_cli`)](#environment-variables-manager-env_cli)
- [Writing Custom CLI Tools with `flag.FlagParser`](#writing-custom-cli-tools-with-flagflagparser)

---

## 1. Architectural Philosophy: How Desktop Apps Are Built

Traditional GUI development is often fragmented:

- Web technologies (Electron, Chromium) are bloated and consume hundreds of megabytes of RAM.
- Low-level native APIs (Cocoa, Win32, GTK) are complex, verbose, and difficult to cross-compile.

**V Webview RAD Studio** bridges this gap:

1. **Lightweight Native Core**: Written in **V (vlang)**, producing small native binaries without bundling a browser runtime. Source builds still require the platform webview development libraries listed in the installation guide.
2. **OS Webview Engine**: Uses the operating system's built-in browser engine (WebKit on macOS/Linux, WebView2 on Windows) via direct C/Objective-C/C++ bindings.
3. **Declarative SimpleGUI**: A fluent builder API where UI controls, layout rows, event handlers, and themes are declared in simple, readable code.
4. **Hardware Telemetry & System Tools**: Built-in modules for processes, CPU, RAM, battery, network, crypto, files, and audio without external libraries.
5. **No Reloads / Native Feel**: Default browser right-click menus and accidental page reloads (`Cmd+R` / `F5`) are suppressed. Desktop shortcuts (`Cmd+F`, `Cmd+M`, `Cmd+Shift+T`) control the native window directly.

### Event Execution and UI-Thread Safety

SimpleGUI native event callbacks run on worker threads so filesystem, subprocess, HTTP, DNS, database, and computation work does not block the webview event loop. Calls that evaluate JavaScript or update generated controls are dispatched back to the native webview thread.

Button actions are serialized: all action buttons are temporarily disabled while a callback is running and are restored when it returns. This prevents duplicate clicks and older overlapping button operations from overwriting newer results. Input change handlers remain available for normal state synchronization.

The generated CSS includes narrow-window behavior at 600 pixels: action buttons and row inputs expand to the available width, labels wrap, tables scroll horizontally, and the fixed status bar truncates safely instead of covering or widening the content.

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
│   76 Themes, Layouts)     │   │   Crypto, Files, State)  │
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

### Installing Webview (`v install ttytm.webview`)

If you do not already have the V `webview` module installed on your machine, install it globally using V's package manager:

```bash
# 1. Install official V webview module globally via vpm
v install ttytm.webview

# Or install directly from GitHub if preferred:
v install --git https://github.com/vlang/webview

# Or install all dependencies defined in v.mod:
v install

# 2. Verify installation
v list
```

#### OS System Dependencies

Webview links to your operating system's native rendering engine:

- **macOS**: Built-in Apple WebKit (requires Xcode Command Line Tools: `xcode-select --install`).
- **Linux (Ubuntu / Debian)**: This project was **tested and verified on Ubuntu 24.04 LTS** using the native system packages below.

  ```bash
  sudo apt-get update
  sudo apt-get install -y build-essential pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev libfontconfig1-dev
  ```

  On Ubuntu 22.04 or a distribution that ships WebKitGTK 4.0, install `libwebkit2gtk-4.0-dev` instead of `libwebkit2gtk-4.1-dev`.

  **Homebrew Linux compatibility:** use the Ubuntu GTK/WebKit packages for this project, not Homebrew `webkitgtk`. A global Homebrew `PKG_CONFIG_PATH`, `LD_LIBRARY_PATH`, or Homebrew linker can mix incompatible GLib libraries with the Ubuntu WebKit stack and fail with an error such as `undefined reference to g_variant_builder_init_static`.

  Use this isolated command for builds and runs:

  ```bash
  V_BIN="$(command -v v)"
  env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
  	PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  	"$V_BIN" run demos/01_standard_controls.v
  ```

  An optional helper keeps Homebrew available for other repositories while isolating this project's command:

  ```bash
  v_webview() {
  	env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
  		PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  		"$(command -v v)" "$@"
  }
  v_webview run demos/01_standard_controls.v
  ```

  Confirm that `pkg-config` resolves Ubuntu's WebKitGTK package before reporting a source issue:

  ```bash
  env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR \
  	pkg-config --variable=prefix webkit2gtk-4.1
  # Expected on Ubuntu 24.04: /usr
  ```

- **Linux (Fedora / RHEL)**: `sudo dnf install -y gtk3-devel webkit2gtk4.0-devel`
- **Linux (Arch Linux)**: `sudo pacman -S gtk3 webkit2gtk`
- **Windows**: Microsoft Edge WebView2 (pre-installed on Windows 10 & 11).

> ✅ **Verified Ubuntu build**: All 24 demos and all 16 desktop applications compile against the Ubuntu 24.04 system GTK3/WebKitGTK 4.1 packages. Demo 01 was launched and visually checked through the WebView event loop. Regenerate the Linux screenshot suite with `bash scratch/capture_linux_screenshots.sh` after installing `gnome-screenshot`.
>
> 💡 **Self-Contained in this Repository**:
> The `vlang_webview_rad_studio` repository already vendors a complete, hardware-accelerated Webview backend with Cocoa Objective-C window management (`window_helper.m`) in `webview/`, allowing you to run all applications and demos out-of-the-box without manual setup!

---

### Creating Your First SimpleGUI Window

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
	theme: 'monokai_pro'           // One of 76 built-in themes
	fullscreen: true               // Start in fullscreen mode (default: true across macOS & Linux)
	min_width: 640                 // Minimum resizable width
	min_height: 480                // Minimum resizable height
)
```

> 🖥️ **macOS & Linux Fullscreen Policy**:
> By default, all applications and demos open in native **fullscreen** on macOS and Linux. If you are building tools specifically meant for custom window positioning, floating placement tests, or multi-window desktop workflows (such as `demos/04_window_placement_and_pin.v`), pass `fullscreen: false` in `SimpleWindowOptions`.


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
// Anonymous input (automatically registers aliases 'ctrl_X' and 'inp_1'):
win.input('Username', 'Enter your handle...', fn (w &simplegui.SimpleWindow, val string) {
	println('Current username: ${val}')
})

// Named input for explicit ID access and two-way sync:
win.input_named('txt_user', 'Username', 'default_user', fn (w &simplegui.SimpleWindow, val string) {
	println('Updated: ${val}')
})
```

> 💡 **Automatic Sequential Aliases (`inp_1`, `inp_2`, ...)**:
> All text inputs, passwords, and textareas automatically register ordinal aliases (`inp_1`, `inp_2`, etc.). You can read or mutate them using `w.get_value('inp_1')` or `w.set_value('inp_1', 'new_val')` with full two-way DOM synchronization.

#### Textarea (Auto-Wrapping Multi-Line Editor)

Multi-line text editor featuring automatic text wrapping (`word-break: break-all; overflow-wrap: anywhere;`) so long continuous Base64 strings or cryptographic hashes auto-adjust and stay 100% within the container frame box:

```v
// Anonymous multi-line editor:
win.textarea('Log Output', 'System initialized.\nReady for commands.', fn (w &simplegui.SimpleWindow, val string) {
	println('Log updated: ${val}')
})

// Named multi-line editor:
win.textarea_named('txt_payload', 'Payload', 'Enter plain text or Base64...', fn (w &simplegui.SimpleWindow, val string) {
	w.set_status('Payload modified: ${val.len} bytes')
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

#### Data Table (Auto-Adjusting Grid & Live Row Mutation)

Renders a structured grid of rows and columns with fixed auto-adjusting column proportions, monospace digest formatting, and text auto-wrapping (`word-break: break-all; overflow-wrap: anywhere;`):

```v
headers := ['Algorithm / Primitive', 'Computed Digest (Hex)', 'Bits']
rows := [
	['SHA-256', system.hash_sha256(text), '256'],
	['HMAC-SHA256', system.hmac_sha256(key, text), '256'],
	['Base64 Encoded', system.encode_base64(text), '${text.len * 8}'],
]

// Named table with interactive click-to-inspect callback:
win.table_named('crypto_table', headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
	row_idx := idx.int()
	println('Clicked row #${row_idx}')
})
```

##### Live Runtime Table Mutation

Update table rows dynamically at runtime with full DOM replacement and auto-wrapping:

```v
// Mutate table by name:
w.set_table_rows('crypto_table', updated_rows)

// Auto-target the window's primary table if name is empty:
w.set_table_rows('', updated_rows)

// Row-level additions and deletions:
w.add_table_row('crypto_table', ['MD5', system.hash_md5(text), '128'])
w.delete_table_row('crypto_table', 0)
```

> 🛡️ **Frame Box Safety**: Tables enforce `table-layout: fixed; width: 100%;` with `overflow-wrap: anywhere` so even 512-bit hashes or long Base64 strings will auto-adjust cleanly inside the frame box without blowing out horizontal layout borders.


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

#### In-Window Modal Alerts (`modal_alert` & `alert`)

RAD Studio features a custom, high-fidelity in-window modal dialog that avoids OS-level blocking or window-focus freezes in fullscreen and headless modes:

```v
// Explicit in-window modal with frosted glass backdrop and auto-scrolling monospace code box:
w.modal_alert('Payload Decoded', 'Decoded 4,096 bytes successfully:\n\n' + payload)

// Universal alert: automatically routes to modal_alert when the webview is active:
w.alert('Deployment Triggered', 'Pipeline v2.4 initialized.')
```

**Key Advantages of `modal_alert`:**
- **No Window Lockup**: Does not block the native OS UI thread or trigger system-level modal sheets that can freeze on certain window managers.
- **Glassmorphic Presentation**: Rendered with `backdrop-filter: blur(4px)` and responsive sizing (`max-width: 560px`, `width: 90%`).
- **Monospace Code Container**: Message text is displayed inside an auto-scrolling monospace box (`max-height: 50vh; overflow-y: auto`) with `word-break: break-all; overflow-wrap: anywhere;` to prevent long cryptographic hashes, stacktraces, or tokens from overflowing.
- **Dismiss Button**: Includes an accent-styled button and closes on ESC or click outside.

#### In-Window Toast Notifications

Display sleek, non-intrusive floating toasts in the top-right corner of the window:

```v
w.toast('Data saved to cache.')
w.toast_success('Database connection established!')
w.toast_info('Update check finished: version is up-to-date.')
w.toast_warning('High CPU usage detected (88%).')
w.toast_error('Failed to verify Ed25519 signature.')
```

Toasts automatically fade out after 3.2 seconds and stack cleanly without shifting your layout.

#### Native Confirmation Dialogs

Presents a native OS confirmation dialog returning a boolean:

```v
if w.confirm('Confirm Deletion', 'Are you sure you want to delete production table "users"?') {
	w.toast_error('Table dropped.')
}
```

#### Native Notification

Displays an operating system banner or notification center toast:

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

Switch between any of the **76 built-in themes** instantly at runtime without reloading:

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

#### Encoders & Base64 (Standard, URL-Safe & Auto-Padded)

The `system` module provides robust encoding and decoding routines with automated sanitization:

```v
// Base64 Encoding
raw_text := 'The quick brown fox jumps over the lazy dog'
b64 := system.encode_base64(raw_text)
// "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw=="

// Resilient Base64 Decoding:
// Automatically trims whitespace, strips carriage returns and newlines, converts
// URL-safe '-' and '_' characters to '+' and '/', and appends missing '=' padding.
decoded := system.decode_base64(b64)
assert decoded == raw_text

// Hexadecimal Encoders
hex_str := system.encode_hex('Hello Webview') // "48656c6c6f2057656276696577"
restored := system.decode_hex(hex_str)        // "Hello Webview"

// Ultra-fast Non-Cryptographic 64-bit Wyhash
fast_hash := system.crypto_wyhash('High throughput metric', 1337)
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
v run build.vsh

# Build any specific application:
v run build.vsh applications/system_studio.v
v run build.vsh applications/crypto_studio.v
v run build.vsh applications/database_studio.v

# Build any interactive demo:
v run build.vsh demos/22_context_menu_and_menu_demo.v
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

---

## 10. Enterprise Desktop Application Suite (18 Complete Studios)

**V Webview RAD Studio** includes a complete suite of **18 production-grade desktop application workstations** located in [`applications/`](applications/). Each application is a self-contained, enterprise-ready desktop tool engineered using declarative **SimpleGUI**, native OS Webview, and real system/hardware telemetry APIs.

Unlike typical Electron or browser-based developer applications that require hundreds of megabytes of RAM and heavy runtime dependencies, these applications compile to lean, ultra-fast native binaries (~30–50 MB RAM at runtime) that start up in milliseconds and interface directly with the host operating system.

### Desktop Workstations Architecture & Engineering Principles

All 18 application studios adhere to a set of production engineering principles:

1. **Named Control Identification**: Form controls and outputs utilize explicit named identifiers (e.g. `win.input_named('target_url', ...)` or `win.textarea_named('log_console', ...)`). This enables robust programmatic queries (`win.get_value('target_url')`) and reactive state updates (`win.set_value('log_console', msg)`).
2. **Worker-Thread Concurrency**: Asynchronous callbacks ensure that I/O-heavy operations (HTTP API requests, SQLite database queries, network port scans, filesystem crawls, shell command executions) run smoothly in the background without freezing the GUI event loop or dropping frames.
3. **Anti-Autocorrect Form Inputs**: All input fields across the suite enforce `autocapitalize="off" autocorrect="off" autocomplete="off" spellcheck="false"`. This guarantees that code snippets, URLs, file paths, regex patterns, and shell commands are never mangled by OS text correction.
4. **Monospace Live Streaming Consoles**: Terminal streams and execution logs are formatted in dedicated high-contrast monospace containers with automatic scroll-to-bottom behavior (`el.scrollTop = el.scrollHeight`) whenever new output is appended.
5. **Real Native Subsystems**: Zero simulated data. Applications interact directly with real operating system facilities (`vlib/os`, `vlib/net.http`, `vlib/sqlite`, `vlib/crypto`, `system.sys`, and `system.stdlib`).

---

### Studio Suite Matrix & Quick Reference

| Application Studio | Source File | Core Capabilities & Features | Quick Run Command |
| :--- | :--- | :--- | :--- |
| **API Studio Pro** | [`applications/api_studio.v`](applications/api_studio.v) | Full REST client (GET/POST/PUT/DELETE/PATCH/HEAD), custom headers editor, payload editor, cURL export, stopwatch latency, request history. | `v run applications/api_studio.v` |
| **System Studio Pro** | [`applications/system_studio.v`](applications/system_studio.v) | Real-time multi-metric KPI cards, CPU cores/load averages, RAM utilization, storage partitions, battery sensor, host uptime, specs report copy. | `v run applications/system_studio.v` |
| **Database Studio Pro** | [`applications/database_studio.v`](applications/database_studio.v) | SQLite query workbench (`:memory:` & disk files), schema table discovery, query execution stopwatch, tabular results, CSV export. | `v run applications/database_studio.v` |
| **Git Workbench Studio** | [`applications/git_studio.v`](applications/git_studio.v) | Visual Git staging, commit authoring, git stash, pull, push, unified monospace diff viewer, and 15-commit history log. | `v run applications/git_studio.v` |
| **DevTools Studio Pro** | [`applications/devtools_studio.v`](applications/devtools_studio.v) | Casing transforms (camelCase, snake_case, kebab-case, Title Case), slugify, JWT header & payload decoder, Unix timestamp converter. | `v run applications/devtools_studio.v` |
| **Crypto Studio Pro** | [`applications/crypto_studio.v`](applications/crypto_studio.v) | SHA-256/512, MD5, SHA-1, HMAC-SHA256, Base64/Hex codecs, Shannon entropy calculator, UUID v4 generator, password generator, file checksums. | `v run applications/crypto_studio.v` |
| **Network Studio Pro** | [`applications/network_studio.v`](applications/network_studio.v) | ICMP ping probe (3 packets), DNS resolution (`nslookup`), common port scanner (80, 443, 22, 8080), HTTP health checks, streaming console. | `v run applications/network_studio.v` |
| **Markdown Studio Pro** | [`applications/markdown_studio.v`](applications/markdown_studio.v) | Split-pane editor with live HTML generation, word/character/line counters, reading time estimation, document templates, standalone HTML export. | `v run applications/markdown_studio.v` |
| **JSON Studio Pro** | [`applications/json_studio.v`](applications/json_studio.v) | Real-time syntax validation, key/property filtering, 2-space prettify, minify, document size & parse latency telemetry, structural key breakdown table. | `v run applications/json_studio.v` |
| **Process Studio Pro** | [`applications/process_studio.v`](applications/process_studio.v) | Task manager listing top CPU and top Memory processes, dynamic filter by name or PID, POSIX task signaling (`SIGTERM` & `SIGKILL -9`), inspector console. | `v run applications/process_studio.v` |
| **Advanced Task Manager** | [`applications/task_manager_studio.v`](applications/task_manager_studio.v) | Full OS Activity Monitor & Task Manager: live process table, CPU/RAM/State, POSIX controls (`SIGTERM`, `SIGKILL -9`, `SIGSTOP`, `SIGCONT`), PID inspector, CSV export. | `v run applications/task_manager_studio.v` |
| **Finder & File Explorer** | [`applications/finder_studio.v`](applications/finder_studio.v) | Visual desktop file manager & navigator: breadcrumbs, QuickLook text/code/binary inspector, file operations (mkdir/touch/delete/rename), OS app launcher. | `v run applications/finder_studio.v` |
| **Color Studio Pro** | [`applications/color_studio.v`](applications/color_studio.v) | Exact relative luminance & WCAG 2.1 contrast math against white/black/dark themes (AAA/AA certified), palette generator, CSS `:root`/Tailwind export. | `v run applications/color_studio.v` |
| **DataConvert Studio** | [`applications/dataconvert_studio.v`](applications/dataconvert_studio.v) | High-speed multi-format transformer: JSON ➔ CSV, CSV ➔ JSON Array, JSON ➔ SQL `INSERT INTO`, CSV ➔ HTML `<table>`, buffer swap, file import/export. | `v run applications/dataconvert_studio.v` |
| **Regex Studio Pro** | [`applications/regex_studio.v`](applications/regex_studio.v) | Live regex compilation, match highlighting with character span offsets, capture group extraction table, presets library, replacement workbench. | `v run applications/regex_studio.v` |
| **App Bundler Studio** | [`applications/app_bundler_studio.v`](applications/app_bundler_studio.v) | Desktop app packager: multi-target compiler (`-prod`, `-g`), complete macOS `.app` bundle generator with `Info.plist` generation, live compiler console. | `v run applications/app_bundler_studio.v` |
| **Environment Studio** | [`applications/env_studio.v`](applications/env_studio.v) | Complete alphabetical environment variable table, search filter, runtime variable setter, `.env` file export/import, system `PATH` directory integrity validator. | `v run applications/env_studio.v` |
| **Watcher Studio Pro** | [`applications/watcher_studio.v`](applications/watcher_studio.v) | Pre-indexed baseline (no false startup events), multi-metric change tracking (`mtime`, `ctime`, `size`), VCS noise exclusion, debounce intervals, dynamic placeholders (`{file}`, `{path}`, `{filename}`, `{event}`, `{dir}`, `{time}`), live console, CSV audit export. | `v run applications/watcher_studio.v` |

---

### Deep Dive: All 18 Enterprise Applications

#### 1. API Studio Pro (`applications/api_studio.v`)
An interactive, cross-platform HTTP client for testing and debugging RESTful APIs:
- **Methods**: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`.
- **Custom Headers**: Enter arbitrary key-value headers separated by newlines (e.g. `Authorization: Bearer <token>`).
- **Body Payloads**: Formats request bodies in JSON or raw text.
- **Stopwatch Telemetry**: Measures and displays round-trip network response latency in milliseconds.
- **Status Pills**: Visual status indicators color-coded by HTTP response family (2xx Success, 3xx Redirect, 4xx Client Error, 5xx Server Error).
- **cURL Exporter**: Instantly generates an equivalent `curl` command string and copies it to the system clipboard.
- **Request History**: Interactive table displaying recent requests with timestamps, endpoints, and status codes.

#### 2. Watcher Studio Pro (`applications/watcher_studio.v`)
An enterprise-grade continuous filesystem monitor with automated command triggering:
- **Zero False-Positives Baseline**: Pre-indexes and normalizes directory contents with real paths on launch, guaranteeing no false `[CREATED]` events appear when monitoring begins.
- **Multi-Metric Verification**: Compares file modification times (`mtime`), metadata change times (`ctime`), and byte lengths (`size`) to capture atomic saves and file replacements.
- **VCS Exclusion**: Automatically excludes `.git/`, `.DS_Store`, and temporary editor swap files from triggering events.
- **Command Automation Pipeline**: Executes user-defined shell commands upon detecting any file modification.
- **Dynamic Template Placeholders**:
  - `{file}` / `{path}`: Full absolute path to the modified file.
  - `{filename}`: File basename (e.g., `server.v`).
  - `{dir}`: Parent folder of the affected file.
  - `{event}`: Event action name (`CREATED`, `MODIFIED`, `DELETED`).
  - `{time}`: Timestamp of the event.
- **Debounce Selector**: Configurable intervals (500ms, 1000ms, 2000ms, 5000ms) to bundle rapid bursts of file modifications into single command runs.
- **Compliance Audit Logging**: Full event logs can be exported directly to a standard CSV file for auditing.

#### 3. Database Studio Pro (`applications/database_studio.v`)
An integrated SQLite query and schema inspection console:
- **Connection Flexibility**: Connect to persistent database files on disk or launch temporary in-memory (`:memory:`) databases.
- **Schema Auto-Discovery**: Automatically enumerates all tables, columns, data types, and row counts via `sqlite_master`.
- **Query Execution Engine**: Runs arbitrary SQL commands with sub-millisecond execution stopwatch tracking.
- **Tabular Data Views**: Renders query results in clean data tables with column headers and row count metrics.
- **CSV Data Exporter**: Exports any SQL query result set to CSV with a single click.

#### 4. Git Workbench Studio (`applications/git_studio.v`)
A visual desktop workbench for local Git version control:
- **Working Tree Telemetry**: Real-time working-tree tracking (`git status --short`).
- **Visual Staging**: One-click Stage All (`git add -A`) and Unstage All (`git reset`).
- **Commit Authoring**: Custom commit message validation and one-click commit creation.
- **Repository Operations**: One-click Git Stash, Stash Pop, Pull (`git pull`), and Push (`git push`).
- **Unified Diff Viewer**: Dedicated monospace diff viewer showing file modifications (`git diff`) with line-by-line inspection.
- **Commit History**: Renders the 15 most recent repository commits (`git log --oneline`) with commit hashes, authors, and dates.

#### 5. DevTools Studio Pro (`applications/devtools_studio.v`)
A comprehensive developer productivity omnitool:
- **Casing Transformations**: Bi-directional conversions across `camelCase`, `snake_case`, `kebab-case`, `Title Case`, `UPPERCASE`, and `lowercase`.
- **URL Slug Generator**: Cleans and converts arbitrary strings into URL-safe slugs.
- **JWT Token Inspector**: Decodes and formats JSON Web Token Header and Payload segments without network transmission.
- **Timestamp Converter**: Bi-directional conversion between Unix epoch timestamps (seconds/milliseconds) and human-readable ISO 8601 / RFC3339 strings.
- **Math & Statistics**: Calculates mean, median, min, max, variance, and standard deviation from comma-separated number series.

#### 6. Crypto Studio Pro (`applications/crypto_studio.v`)
A high-assurance cryptography and security suite:
- **Hashing Algorithms**: Real-time generation of SHA-256, SHA-512, MD5, and SHA-1 digests.
- **Message Authentication**: HMAC-SHA256 signature generation with custom user-supplied secret keys.
- **Data Encoders**: High-speed Base64 and Hexadecimal encode/decode tools.
- **Shannon Entropy Analyzer**: Computes Shannon entropy (0.0 to 8.0 bits/byte) to evaluate token unpredictability and password strength.
- **UUID v4 Generator**: Generates cryptographically secure RFC 4122 Version 4 UUIDs.
- **Password Generator**: High-entropy password generator with customizable length, numbers, and special character flags.
- **File Checksum Verifier**: Calculates SHA-256 checksums of local disk files with native file picker integration.

#### 7. Network Studio Pro (`applications/network_studio.v`)
An advanced network diagnostics and connectivity workstation:
- **ICMP Ping Probe**: Sends 3 ping packets to remote hosts or IP addresses, reporting packet loss and round-trip latency statistics (min/avg/max).
- **DNS Lookup Engine**: Queries authoritative name servers (`nslookup` / host lookup) to resolve A, AAAA, and CNAME records.
- **Port Scanner**: Rapid multi-port connectivity check across standard services (HTTP 80, HTTPS 443, SSH 22, Dev 8080, or custom port ranges).
- **HTTP Health Checks**: Validates remote URL endpoints, returning status codes, response times, and server headers.
- **Streaming Terminal Console**: Live monospace console displaying raw network diagnostics with timestamped diagnostic history.

#### 8. Markdown Studio Pro (`applications/markdown_studio.v`)
A split-pane Markdown authoring and HTML publishing studio:
- **Live Split-Pane Preview**: Real-time conversion of Markdown source into styled semantic HTML preview.
- **Document Telemetry**: Word counter, character counter, line counter, and estimated reading time calculator.
- **Templates Library**: One-click boilerplate insertion for Software READMEs, REST API Documentation, and Project Changelogs.
- **HTML Export**: Copy raw HTML to the clipboard or export a standalone, styled HTML document to disk.

#### 9. JSON Studio Pro (`applications/json_studio.v`)
A high-performance JSON formatting, validation, and querying suite:
- **Syntax Validator**: Real-time validation using `json2`, highlighting syntax error locations and invalid tokens.
- **Prettify & Minify**: Formats messy JSON with 2-space indentation or compacts it into a single-line payload.
- **Key & Property Filter**: Search and extract nested objects, keys, and values by substring or property name.
- **Document Telemetry**: Live byte counter, character length, and parse latency stopwatch.
- **Structural Analysis Table**: Automatically analyzes root object keys, reporting their data types and array lengths.

#### 10. Process Studio Pro (`applications/process_studio.v`)
A task manager and OS process inspection workstation:
- **Process Listing**: Live monitoring of top processes sorted by CPU utilization and Memory footprint.
- **Dynamic Search Filter**: Instant filtering by process name, binary path, or PID.
- **Task Control**: Send POSIX signals directly to processes:
  - Graceful termination (`SIGTERM`)
  - Forced immediate termination (`SIGKILL -9`)
- **Process Inspector**: Detailed console showing PID, PPID, owning user, memory consumption, CPU load, and full execution command line.

#### 11. Color Studio Pro (`applications/color_studio.v`)
An accessibility-certified color palette and contrast analyzer:
- **WCAG 2.1 Contrast Math**: Calculates exact relative luminance ($L = 0.2126R + 0.7152G + 0.0722B$) and contrast ratios against Pure White (`#FFFFFF`), Pure Black (`#000000`), and Dark Theme (`#1E1E2E`).
- **Compliance Badges**: Visual indicators for WCAG AA (Normal/Large text) and AAA (Normal/Large text) certification.
- **Harmonious Palettes**: Generates Monochromatic, Complementary, Triadic, and Analogous color harmonies.
- **Code Export**: Exports color tokens directly into CSS custom properties (`:root`), Tailwind CSS configuration objects, or Vlang constant structures.

#### 12. DataConvert Studio (`applications/dataconvert_studio.v`)
A high-speed multi-format data transformer:
- **Transformation Formats**:
  - JSON Array ➔ Standard CSV
  - Standard CSV ➔ JSON Array of Objects
  - JSON Array ➔ SQL `INSERT INTO` statements
  - Standard CSV ➔ Semantic HTML `<table>` markup
- **Buffer Swap**: One-click swap of output buffer to input buffer for multi-stage conversion pipelines.
- **File I/O**: Direct file import and export with native file dialog integration.
- **Data Metrics**: Live byte count and row/line telemetry cards for both input and output payloads.

#### 13. Regex Studio Pro (`applications/regex_studio.v`)
A regular expression development and testing studio:
- **Live Engine Compilation**: Compiles and tests expressions against sample text using `vlib/regex`.
- **Match Offsets & Highlighting**: Displays matched segments along with start and end character span offsets.
- **Capture Groups Breakdown**: Dedicated table enumerating all indexed capture groups and their extracted substrings.
- **Pattern Presets**: Quick-load common patterns: Email addresses, HTTP/HTTPS URLs, IPv4 addresses, ISO dates, Hex colors, and phone numbers.
- **Substitution Workbench**: Live regex search-and-replace testing with output preview.

#### 14. App Bundler Studio (`applications/app_bundler_studio.v`)
A desktop application packager and distribution compiler:
- **Target Architectures**: Multi-platform compiler frontend supporting macOS, Linux, and Windows targets.
- **Compilation Modes**: Production optimized release mode (`-prod`), debug symbols (`-g`), and custom compiler flags.
- **macOS `.app` Bundle Generator**: Generates complete application bundles with `Contents/MacOS`, `Info.plist`, and Retina icon integration.
- **Build Console**: Monospace build console streaming compiler standard output, warnings, and error diagnostics.

#### 15. Environment Studio (`applications/env_studio.v`)
An operating system environment variables and configuration workbench:
- **Alphabetical Variable Table**: Inspect all environment variables currently exposed to the process in an alphabetical grid.
- **Search & Filter**: Search variables by name or value substring.
- **Runtime Variable Setter**: Set and test environment variables for the active session.
- **`.env` File Import/Export**: Import environment variables from `.env` files or export current configurations to disk.
- **`PATH` Integrity Validator**: Validates each directory listed in the system `PATH` variable, flagging non-existent or broken directories.

#### 16. System Studio Pro (`applications/system_studio.v`)
A hardware intelligence and operating system telemetry workstation:
- **KPI Metric Cards**: Real-time cards for CPU Load, Active RAM, Storage Usage, Battery State, and Host Uptime.
- **CPU Metrics**: Core counts, 1/5/15-minute load averages, and processor model identification.
- **RAM Telemetry**: Total, used, and free physical memory metrics with utilization percentages.
- **Disk Partitions**: Storage capacity, used bytes, and free space across all mounted filesystem partitions.
- **System Specs Export**: Formats a complete hardware audit report and copies it to the clipboard.

#### 17. Advanced Task Manager Studio Enterprise (`applications/task_manager_studio.v`)
An OS Activity Monitor and Task Manager workstation:
- **Full Process Grid**: Real-time process listing with PID, PPID, Owning User, CPU%, MEM%, State, and Command Name.
- **POSIX Signal Controls**: Send `SIGTERM` (graceful exit), `SIGKILL -9` (forced termination), `SIGSTOP` (pause/suspend process), or `SIGCONT` (resume process).
- **Interactive PID Selection**: Click any row in the process table to immediately inspect the process and populate action buttons.
- **Deep Process Inspector**: Monospace console displaying executable binary paths, arguments, environment flags, and process parentage.
- **System Telemetry & Storage Inspector**: Detailed report of CPU cores/load averages, physical RAM in use vs. free, battery power profile, and filesystem disk mounts (`df -h`).
- **CSV Data Exporter**: Export the full process snapshot table to CSV with one click.

#### 18. Finder & File Explorer Studio Enterprise (`applications/finder_studio.v`)
A visual desktop file manager and directory navigator:
- **Breadcrumbs & Quick Jumps**: Instant navigation to `Home (~/ )`, `Desktop`, `Documents`, `Downloads`, or `Up to Parent (..)`.
- **Direct Path Entry**: Editable path bar with normalization (`os.real_path`) and directory validation.
- **File System Table**: Detailed table with icons, filenames, human-readable file types, formatted sizes (`KB/MB/GB` or `item count`), POSIX permissions (`drwxr-xr-x`, `-rwxr-xr-x`), and last modification timestamps.
- **Integrated QuickLook Previewer**:
  - Code/Text/Markdown/JSON/CSV preview with line counts, byte sizes, and syntax preview (first 120 lines).
  - Binary/Media/Archive inspection displaying file metadata, MIME type, permissions, and real SHA-256 digests (`system.sha256_file`).
- **File & Folder Operations**: Create new folders (`mkdir`), touch new files, rename items, delete files/folders, and copy absolute paths to the clipboard.
- **System Default App Launcher**: Open any selected file or folder in the OS default application (`open` on macOS, `xdg-open` on Linux, `start` on Windows).

---

## 11. Companion CLI Suite & Automation API (16 Complete Tools)

In addition to visual GUI applications, **V Webview RAD Studio** includes **16 companion CLI tools** located in `cli_apps/`. Every single application in the Enterprise Studio suite has a matching command-line interface.

### CLI Architecture & Performance Advantages

1. **Native Startup**: Each tool compiles to a standalone V executable; binary size and launch time depend on imported modules and the target platform.
2. **Predictable CLI Contract**: Every tool supports `--help` and `--version`, rejects unknown or conflicting arguments, writes usage errors to stderr with exit code `2`, and reports terminal operational failures with exit code `1`.
3. **Output Modes**: Human-readable terminal output is the default. Tools that expose `--json`, such as `system_cli` and `env_cli`, provide machine-readable output for automation.
4. **External Tool Requirements**: Some commands intentionally invoke platform tools, including Git, SQLite, ping/DNS utilities, process tools, the V compiler, and platform packaging/signing tools. Missing tools are reported as failures rather than treated as success.

### CLI Suite Quick Reference

| CLI Utility                                                             | Source File                                                | Primary Purpose                                              | Key Flags                                                           |
| ----------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------- |
| [**`system_cli`**](#system--hardware-workstation-system_cli)            | [`cli_apps/system_cli.v`](cli_apps/system_cli.v)           | Hardware telemetry, CPU, RAM, battery & OS inspection        | `-t, --telemetry`, `-j, --json`, `-a, --audit`                      |
| [**`crypto_cli`**](#cryptographic-hashing--encoders-crypto_cli)         | [`cli_apps/crypto_cli.v`](cli_apps/crypto_cli.v)           | Cryptographic digests, HMAC-SHA256, Base64 & Hex             | `-a, --algo`, `-k, --key`, `-A, --all`, `-e, --b64-encode`          |
| [**`json_cli`**](#json-inspector-validator--formatter-json_cli)         | [`cli_apps/json_cli.v`](cli_apps/json_cli.v)               | JSON formatting, validation & minification                   | `-f, --file`, `-m, --minify`, `-v, --validate`                      |
| [**`devtools_cli`**](#developer-omnitool--math-statistics-devtools_cli) | [`cli_apps/devtools_cli.v`](cli_apps/devtools_cli.v)       | UUIDs, epoch timestamps, string metrics & math stats         | `-u, --uuid`, `-t, --timestamp`, `-s, --slug`, `-S, --stats`        |
| [**`process_cli`**](#process--task-manager-process_cli)                 | [`cli_apps/process_cli.v`](cli_apps/process_cli.v)         | Process listing, name filtering & process termination        | `-f, --filter`, `-k, --kill`, `-t, --top`                           |
| [**`database_cli`**](#sqlite-database-console-database_cli)             | [`cli_apps/database_cli.v`](cli_apps/database_cli.v)       | SQLite database inspector, schema viewer & SQL query runner  | `-d, --database`, `-t, --tables`, `-s, --schema`, `-q, --query`, `-w, --allow-write` |
| [**`api_cli`**](#http--rest-api-client-api_cli)                         | [`cli_apps/api_cli.v`](cli_apps/api_cli.v)                 | REST client supporting GET, POST, PUT, DELETE, and body data | `-X, --method`, `-d, --data`, `-c, --content-type`, `-i, --headers` |
| [**`dataconvert_cli`**](#data-format-converter-dataconvert_cli)         | [`cli_apps/dataconvert_cli.v`](cli_apps/dataconvert_cli.v) | Matrix conversion between CSV and JSON                       | `-f, --from`, `-t, --to`, `-i, --file`                              |
| [**`watcher_cli`**](#file-system-watcher--trigger-watcher_cli)          | [`cli_apps/watcher_cli.v`](cli_apps/watcher_cli.v)         | Filesystem directory watcher with automated command triggers | `-p, --path`, `-e, --exec`, `-i, --interval`                        |
| [**`regex_cli`**](#regular-expression-tester-regex_cli)                 | [`cli_apps/regex_cli.v`](cli_apps/regex_cli.v)             | Regular expression testing, matching & string replacement    | `-p, --pattern`, `-r, --replace`                                    |
| [**`app_bundler_cli`**](#desktop-app-packager--bundler-app_bundler_cli) | [`cli_apps/app_bundler_cli.v`](cli_apps/app_bundler_cli.v) | Standalone distribution packager for macOS, Linux & Windows  | `-n, --name`, `-e, --entry`, `-o, --out`, `-t, --target`            |
| [**`network_cli`**](#network-diagnostics--ping-telemetry-network_cli)   | [`cli_apps/network_cli.v`](cli_apps/network_cli.v)         | ICMP ping latency, DNS lookup, open ports & IP discovery     | `-p, --ping`, `-i, --ip`, `-d, --dns`, `-l, --ports`                |
| [**`git_cli`**](#visual-git-workstation-git_cli)                        | [`cli_apps/git_cli.v`](cli_apps/git_cli.v)                 | Git working tree inspector, branch manager & commit log      | `-s, --status`, `-b, --branch`, `-l, --log`, `-d, --diff`           |
| [**`markdown_cli`**](#markdown-to-html-compiler-markdown_cli)           | [`cli_apps/markdown_cli.v`](cli_apps/markdown_cli.v)       | Markdown to HTML compiler and document converter             | `-f, --file`, `-o, --out`                                           |
| [**`color_cli`**](#color--wcag-contrast-inspector-color_cli)            | [`cli_apps/color_cli.v`](cli_apps/color_cli.v)             | HEX/RGB converter, WCAG contrast ratio & accessibility       | `-x, --hex`, `-b, --bg`                                             |
| [**`env_cli`**](#environment-variables-manager-env_cli)                 | [`cli_apps/env_cli.v`](cli_apps/env_cli.v)                 | Environment variable auditor, search filter & JSON exporter  | `-g, --get`, `-f, --filter`, `-j, --json`                           |

---

### System & Hardware Workstation (`system_cli`)

Cross-platform hardware telemetry, battery level, CPU utilization, and privacy-shielded network inspection.

#### Flags

| Flag          | Short | Default | Description                                                      |
| ------------- | ----- | ------- | ---------------------------------------------------------------- |
| `--telemetry` | `-t`  | `false` | Display full hardware and memory telemetry                       |
| `--cpu`       | `-c`  | `false` | Display CPU model, core count, architecture, and current usage % |
| `--mem`       | `-m`  | `false` | Display RAM allocation metrics (Total, Used, Free)               |
| `--battery`   | `-b`  | `false` | Display battery percentage, charging state, and AC power status  |
| `--network`   | `-n`  | `false` | Display network interfaces and internet ping status              |
| `--json`      | `-j`  | `false` | Output telemetry in machine-readable JSON format                 |
| `--audit`     | `-a`  | `false` | Run comprehensive full-system hardware and OS audit              |

#### Quick Run & Build

```bash
# Run directly
v run cli_apps/system_cli.v --telemetry

# Machine-readable JSON output (ideal for scripting and CI/CD)
v run cli_apps/system_cli.v --json

# Compile to standalone production binary
v -prod cli_apps/system_cli.v -o bin/system_cli
```

#### Example Output (Human-Readable)

```text
====================================================================
⚡ SYSTEM & HARDWARE WORKSTATION CLI (vlang)
====================================================================
🖥️  OS:       macOS 15.0 (arm64)
🏷️  Hostname: workstation.local
⏱️  Uptime:   124500 seconds (~34.6 hours)
🌐 IP:       192.168.***.*** (Protected)

[CPU Information]
  Model: Apple M-Series Silicon
  Cores: 10
  Arch:  arm64
  Usage: 12.4%

[Memory (RAM)]
  Total: 32.00 GB
  Used:  14.82 GB
  Free:  17.18 GB
====================================================================
```

#### Programmatic Usage in V

```v
import system

hw := system.get_hardware_telemetry()
println('CPU Cores: ${hw.cpu_cores}')
println('RAM Free:  ${system.format_bytes(hw.ram_free_bytes)}')
```

---

### Cryptographic Hashing & Encoders (`crypto_cli`)

Enterprise cryptographic tool computing digests, keyed HMAC authentication codes, and Base64/Hex encoding.

#### Flags

| Flag           | Short | Default  | Description                                          |
| -------------- | ----- | -------- | ---------------------------------------------------- |
| `--algo`       | `-a`  | `sha256` | Hashing algorithm: `md5`, `sha256`, `sha512`, `hmac` |
| `--key`        | `-k`  | `""`     | Secret key for HMAC hashing                          |
| `--b64-encode` | `-e`  | `false`  | Base64 encode the input string                       |
| `--b64-decode` | `-d`  | `false`  | Base64 decode the input string                       |
| `--hex-encode` | `-x`  | `false`  | Hex encode the input string                          |
| `--hex-decode` | `-y`  | `false`  | Hex decode the input string                          |
| `--all`        | `-A`  | `false`  | Compute all hashes simultaneously                    |

#### Quick Run Examples

```bash
# Compute all cryptographic digests simultaneously
v run cli_apps/crypto_cli.v --all "Hello, Production Desktop!"

# Generate keyed HMAC-SHA256
v run cli_apps/crypto_cli.v --algo hmac --key "my-super-secret-key" "api_payload_data"

# Base64 encode / decode
v run cli_apps/crypto_cli.v --b64-encode "Encode this payload"
v run cli_apps/crypto_cli.v --b64-decode "RW5jb2RlIHRoaXMgcGF5bG9hZA=="
```

---

### JSON Inspector, Validator & Formatter (`json_cli`)

Zero-dependency JSON payload validator, syntax checker, formatter, and tree inspector.

#### Flags

| Flag         | Short | Default | Description                                         |
| ------------ | ----- | ------- | --------------------------------------------------- |
| `--file`     | `-f`  | `""`    | Input JSON file path to parse                       |
| `--minify`   | `-m`  | `false` | Minify JSON output into a single compact line       |
| `--validate` | `-v`  | `false` | Validate JSON syntax without printing the full body |

#### Quick Run Examples

```bash
# Pretty-print formatted JSON
v run cli_apps/json_cli.v -f config.json

# Minify JSON for network transmission
v run cli_apps/json_cli.v -m -f config.json

# Validate JSON syntax in CI/CD pipeline
v run cli_apps/json_cli.v -v -f package.json
```

---

### Developer Omnitool & Math Statistics (`devtools_cli`)

Developer Swiss Army Knife utility for cryptographic UUID v4 generation, timestamps, string manipulation, and statistical distribution analysis.

#### Flags

| Flag          | Short | Default | Description                                                   |
| ------------- | ----- | ------- | ------------------------------------------------------------- |
| `--uuid`      | `-u`  | `false` | Generate a random UUID v4 string                              |
| `--timestamp` | `-t`  | `false` | Show current Unix epoch timestamp in seconds                  |
| `--slug`      | `-s`  | `false` | Slugify input text for URLs and filenames                     |
| `--title`     | `-T`  | `false` | Convert input text to Title Case                              |
| `--reverse`   | `-r`  | `false` | Reverse characters of input text                              |
| `--words`     | `-w`  | `false` | Count words in input text                                     |
| `--stats`     | `-S`  | `false` | Calculate full statistical metrics on comma-separated numbers |

#### Quick Run Examples

```bash
# Generate UUID v4
v run cli_apps/devtools_cli.v --uuid

# Convert title to URL slug
v run cli_apps/devtools_cli.v --slug "My Enterprise Desktop Application 2026"
# Output: my-enterprise-desktop-application-2026

# Calculate statistics on datasets
v run cli_apps/devtools_cli.v --stats "12, 45, 67, 23, 89, 45, 91, 15"
# Output: Mean: 48.38 | Median: 45.00 | StdDev: 29.81 | Min: 12 | Max: 91
```

---

### Process & Task Manager (`process_cli`)

Cross-platform process monitor, search filter, resource inspector, and runaway process termination utility.

#### Flags

| Flag       | Short | Default | Description                                  |
| ---------- | ----- | ------- | -------------------------------------------- |
| `--filter` | `-f`  | `""`    | Filter processes matching name substring     |
| `--kill`   | `-k`  | `""`    | Kill process by PID or exact executable name |
| `--top`    | `-t`  | `20`    | Show top N active processes (default: 20)    |

#### Quick Run Examples

```bash
# Find all active web or node processes
v run cli_apps/process_cli.v --filter "node"

# Inspect top 10 running system processes
v run cli_apps/process_cli.v --top 10

# Terminate runaway process by PID
v run cli_apps/process_cli.v --kill 48192
```

---

### SQLite Database Console (`database_cli`)

Inspect SQLite databases, catalog tables, examine column schemas, and execute raw SQL statements directly from the command line.

#### Flags

| Flag         | Short | Default  | Description                                              |
| ------------ | ----- | -------- | -------------------------------------------------------- |
| `--database` | `-d`  | `app.db` | SQLite database file path                                |
| `--tables`   | `-t`  | `false`  | List all tables in the database                          |
| `--schema`   | `-s`  | `""`     | Display column schema and constraints of specified table |
| `--query`    | `-q`  | `""`     | Execute an SQL query and display results                 |
| `--allow-write` | `-w` | `false` | Permit a query that may modify the database              |

Without `--allow-write`, the SQLite process is opened with `-readonly` and only read-oriented statement prefixes (`SELECT`, `WITH`, `EXPLAIN`, and `PRAGMA`) are accepted. The database path must already exist. Supplying more than one of `--tables`, `--schema`, and query mode is a usage error.

#### Quick Run Examples

```bash
# List all tables in database
v run cli_apps/database_cli.v -d storage.db --tables

# View table schema
v run cli_apps/database_cli.v -d storage.db --schema users

# Execute SQL query
v run cli_apps/database_cli.v -d storage.db -q "SELECT id, name, role FROM users LIMIT 5;"

# Explicitly opt in to a write
v run cli_apps/database_cli.v -d storage.db --allow-write -q "UPDATE users SET role = 'admin' WHERE id = 1;"
```

---

### HTTP & REST API Client (`api_cli`)

Command-line REST client for making HTTP requests, testing endpoints, verifying responses, and inspecting headers.

#### Flags

| Flag             | Short | Default            | Description                                          |
| ---------------- | ----- | ------------------ | ---------------------------------------------------- |
| `--method`       | `-X`  | `GET`              | HTTP Method: `GET`, `POST`, `PUT`, `DELETE`, `PATCH` |
| `--data`         | `-d`  | `""`               | Request body payload string                          |
| `--content-type` | `-c`  | `application/json` | Content-Type request header                          |
| `--headers`      | `-i`  | `false`            | Include HTTP response headers in output              |

#### Quick Run Examples

```bash
# Perform GET request with headers
v run cli_apps/api_cli.v -i https://httpbin.org/get

# Send JSON POST payload
v run cli_apps/api_cli.v -X POST -d '{"project":"vlang_rad_studio","status":"active"}' https://httpbin.org/post
```

---

### Data Format Converter (`dataconvert_cli`)

Matrix transformation tool converting datasets bidirectionally between CSV and JSON.

#### Flags

| Flag     | Short | Default | Description                  |
| -------- | ----- | ------- | ---------------------------- |
| `--from` | `-f`  | `csv`   | Source format: `csv`, `json` |
| `--to`   | `-t`  | `json`  | Target format: `json`, `csv` |
| `--file` | `-i`  | `""`    | Input data file path         |

#### Quick Run Examples

```bash
# Convert CSV dataset to JSON
v run cli_apps/dataconvert_cli.v --from csv --to json -i customers.csv > customers.json

# Convert JSON array of objects to CSV
v run cli_apps/dataconvert_cli.v --from json --to csv -i metrics.json > metrics.csv
```

---

### File System Watcher & Trigger (`watcher_cli`)

Monitors directories for file modifications, creations, and deletions, triggering custom shell commands on every change event.

The watcher validates that the target exists and that the polling interval is positive. It sleeps between snapshots to avoid a busy loop, exits with an error if the path disappears, logs trigger-command failures while continuing to monitor, and can be cancelled with `Ctrl+C`/SIGTERM.

#### Flags

| Flag         | Short | Default | Description                                        |
| ------------ | ----- | ------- | -------------------------------------------------- |
| `--path`     | `-p`  | `.`     | Directory or file path to watch                    |
| `--exec`     | `-e`  | `""`    | Shell command to execute when changes are detected |
| `--interval` | `-i`  | `1000`  | Polling frequency in milliseconds                  |

#### Quick Run Examples

```bash
# Auto-check V code when files in simplegui/ change
v run cli_apps/watcher_cli.v -p simplegui/ -e "v -check ."

# Auto-rebuild distribution bundle on source edit
v run cli_apps/watcher_cli.v -p applications/ -e "v run build.vsh applications/system_studio.v"
```

---

### Regular Expression Tester (`regex_cli`)

Fast, native regular expression pattern evaluator and string substitution tool.

#### Flags

| Flag        | Short | Default | Description                   |
| ----------- | ----- | ------- | ----------------------------- |
| `--pattern` | `-p`  | `""`    | Regular expression pattern    |
| `--replace` | `-r`  | `""`    | Replacement string (optional) |

#### Quick Run Examples

```bash
# Extract all numeric sequences
v run cli_apps/regex_cli.v -p "\d+" "Order #9401 created for customer 8820"

# Find and replace text matching pattern
v run cli_apps/regex_cli.v -p "([a-z]+)@([a-z.]+)" -r "[REDACTED EMAIL]" "Contact: user@example.com"
```

---

### Desktop App Packager & Bundler (`app_bundler_cli`)

Command-line interface to `build.vsh` for compiling, packaging, and branding native macOS `.app` bundles, Linux ELF binaries, and Windows `.exe`.

#### Flags

| Flag       | Short | Default   | Description                                                     |
| ---------- | ----- | --------- | --------------------------------------------------------------- |
| `--name`   | `-n`  | `MyApp`   | Application Display Name                                        |
| `--entry`  | `-e`  | `main.v`  | Main entry point V source file                                  |
| `--out`    | `-o`  | `dist`    | Destination output directory                                    |
| `--target` | `-t`  | `current` | Target operating system: `current`, `macos`, `linux`, `windows` |

#### Quick Run Examples

```bash
# Package System Studio into native macOS .app bundle
v run cli_apps/app_bundler_cli.v -n "System Studio" -e applications/system_studio.v -o dist/

# Package API Studio for production
v run cli_apps/app_bundler_cli.v -n "API Studio Pro" -e applications/api_studio.v
```

---

### Network Diagnostics & Ping Telemetry (`network_cli`)

Diagnostic tool for ICMP echo ping latency, DNS name resolution, and listening port discovery.

#### Flags

| Flag      | Short | Default | Description                                   |
| --------- | ----- | ------- | --------------------------------------------- |
| `--ping`  | `-p`  | `""`    | Host or IP address to ping                    |
| `--ip`    | `-i`  | `false` | Display local IPv4 address (privacy-shielded) |
| `--dns`   | `-d`  | `""`    | Resolve DNS records for target hostname       |
| `--ports` | `-l`  | `false` | Scan for active listening TCP ports           |

#### Quick Run Examples

```bash
# Test network latency
v run cli_apps/network_cli.v --ping 1.1.1.1

# Resolve DNS hostname
v run cli_apps/network_cli.v --dns github.com

# Audit open listening ports
v run cli_apps/network_cli.v --ports
```

---

### Visual Git Workstation (`git_cli`)

Command-line Git helper for quick status summaries, branch management, diff inspections, and commit histories.

#### Flags

| Flag       | Short | Default | Description                             |
| ---------- | ----- | ------- | --------------------------------------- |
| `--status` | `-s`  | `false` | Show concise Git working tree status    |
| `--branch` | `-b`  | `false` | List local and tracking remote branches |
| `--log`    | `-l`  | `0`     | Show last N commit history log entries  |
| `--diff`   | `-d`  | `false` | Show active working tree unstaged diffs |

#### Quick Run Examples

```bash
# View concise status and last 3 commits
v run cli_apps/git_cli.v --status --log 3

# Inspect branch list
v run cli_apps/git_cli.v --branch
```

---

### Markdown to HTML Compiler (`markdown_cli`)

Converts Markdown documents into standalone HTML files with embedded styling and syntax formatting.

#### Flags

| Flag     | Short | Default | Description                             |
| -------- | ----- | ------- | --------------------------------------- |
| `--file` | `-f`  | `""`    | Input Markdown source file              |
| `--out`  | `-o`  | `""`    | Output HTML destination file (optional) |

#### Quick Run Examples

```bash
# Convert README to HTML document
v run cli_apps/markdown_cli.v -f README.md -o output.html
```

---

### Color & WCAG Contrast Inspector (`color_cli`)

Color math utility converting between HEX and RGB formats, calculating WCAG AAA / AA contrast ratios, and verifying legibility across themes.

#### Flags

| Flag    | Short | Default   | Description                                        |
| ------- | ----- | --------- | -------------------------------------------------- |
| `--hex` | `-x`  | `""`      | Foreground Hex color code (e.g. `#38bdf8`)         |
| `--bg`  | `-b`  | `#0f172a` | Background Hex color code for contrast calculation |

#### Quick Run Examples

```bash
# Check WCAG compliance of cyan accent on dark slate background
v run cli_apps/color_cli.v --hex "#38bdf8" --bg "#0f172a"
# Output: Contrast Ratio: 10.42:1 (Passes WCAG AAA for Normal Text)
```

---

### Environment Variables Manager (`env_cli`)

Inspects active process environment variables, filters keys, extracts specific variables, and outputs structured JSON.

#### Flags

| Flag       | Short | Default | Description                                           |
| ---------- | ----- | ------- | ----------------------------------------------------- |
| `--get`    | `-g`  | `""`    | Get value of a specific environment variable          |
| `--filter` | `-f`  | `""`    | Search and filter environment variable names          |
| `--json`   | `-j`  | `false` | Output environment variables in machine-readable JSON |

#### Quick Run Examples

```bash
# Retrieve PATH variable
v run cli_apps/env_cli.v --get PATH

# Filter all variables starting with V
v run cli_apps/env_cli.v --filter "V_" --json
```

---

### Writing Custom CLI Tools with `flag.FlagParser`

Creating new command-line tools in V is clean, fast, and idiomatic. Here is the standard template used throughout the repository:

```v
module main

import flag
import os
import system

fn main() {
	// 1. Initialize Flag Parser
	mut fp := flag.new_flag_parser(os.args)
	fp.application('my_custom_tool')
	fp.version('1.0.0')
	fp.description('High-Performance Developer Automation CLI')
	fp.skip_executable()

	// 2. Define Command-Line Flags
	name := fp.string('name', `n`, 'World', 'Recipient name')
	count := fp.int('count', `c`, 1, 'Number of iterations')
	as_json := fp.bool('json', `j`, false, 'Output in JSON format')

	// 3. Finalize & Validate Arguments
	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	// 4. Handle Execution
	if as_json {
		println('{"name": "${name}", "count": ${count}, "args": ${additional_args}}')
		return
	}

	for i in 0 .. count {
		println('${i + 1}. Hello, ${name}!')
	}
}
```

Compile and run:

```bash
# Run with V
v run my_custom_tool.v --name "RAD Developer" --count 3

# Compile to production binary
v -prod my_custom_tool.v -o bin/my_custom_tool
```
