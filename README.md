# ⚡ Vlang Webview RAD Studio

**Cross-Platform Visual Rapid Application Development (RAD) Studio & Enterprise Desktop Suite** powered by native **V (vlang)** and lightweight hardware-accelerated **Webview** (macOS Cocoa / WebKit, Windows Win32 / Edge WebView2, Linux GTK / WebKit2GTK).

> 💡 **Built Off & Powered By**:
> This project is built directly on top of [**vlang_macos_webview_app_template**](https://github.com/codecaine-zz/vlang_macos_webview_app_template) for cross-platform Webview window management, porting the full visual IDE from [**bun_rad_studio**](https://github.com/codecaine-zz/bun_rad_studio), and integrating the native RAD API system tools from [**simple_gg**](https://github.com/codecaine-zz/simple_gg) and [**vlang_simplegui**](https://github.com/codecaine-zz/vlang_simplegui).

> 📖 **Full API Reference**:
> For complete documentation with copy-pasteable code examples for every UI control, system telemetry tool, security utility, and state persistence method, see [**API.md**](API.md).

---

## 🏛️ Foundations & Project Lineage

This project is directly based upon and unifies several foundational open-source codebases authored by [@codecaine-zz](https://github.com/codecaine-zz):

| Foundational Project                 | Repository                                                                                                        | Core Subsystems & Architectural Roles                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **vlang_macos_webview_app_template** | [codecaine-zz/vlang_macos_webview_app_template](https://github.com/codecaine-zz/vlang_macos_webview_app_template) | **Native Window Management & Webview Foundation**: The core template and architectural foundation used to manage windows in Webview in V. Provided the native C/C++ Webview binding patterns in V, Cocoa Objective-C window helper integration (`window_helper.m`), 9 placement presets (`center`, `upper_left`, `top_center`, etc.), stay-on-top window pinning (`set_always_on_top`), fullscreen toggling, and native desktop IPC event loop. |
| **bun_rad_studio**                   | [codecaine-zz/bun_rad_studio](https://github.com/codecaine-zz/bun_rad_studio)                                     | **Primary IDE & RAD Blueprint**: Ported from Bun/TypeScript to native V. Provided the Borland Delphi & Visual Basic visual form designer architecture, 70+ drag-and-drop components, anchor & docking layout engines, property grid, 10 application templates, non-visual component tray, and complete 42-theme design system.                                                                                                                  |
| **simple_gg**                        | [codecaine-zz/simple_gg](https://github.com/codecaine-zz/simple_gg)                                               | **RAD Development System Tools**: Ported native system and runtime toolkits (`system/sys.v` & `system/stdlib.v`): process execution (`exec`, `exec_or`, `exec_bg`), real-time hardware telemetry (CPU cores/model/usage, RAM, battery, network ping), native dialogs (`osascript`, PowerShell, `zenity`), clipboard manipulation, cryptography (SHA256, HMAC), encoders, and math statistics.                                                   |
| **vlang_simplegui**                  | [codecaine-zz/vlang_simplegui](https://github.com/codecaine-zz/vlang_simplegui)                                   | **Declarative High-Level GUI & Themes**: Provided the fluent declarative GUI builder syntax (`win.button()`, `win.input()`, `win.radio()`, `win.toggle()`), reactive two-way value synchronization, KPI dashboards, table components, and dynamic live theme switching across all 76 desktop form themes.                                                                                                                                       |
| **vlang_utils**                      | [codecaine-zz/vlang_utils](https://github.com/codecaine-zz/vlang_utils)                                           | **Comprehensive Developer Utility Suite**: 30 modular packages providing in-memory caching (LRU/TTL), synthetic mock data, color space engine, semantic versioning, string casing, SQLite helpers, streaming compression, TAR/ZIP archives, concurrency, and validation.                                                                                                            |

### 🪟 Window Management Foundation: `vlang_macos_webview_app_template`

The core window management engine, Webview lifecycle, and desktop architecture in this project are built directly upon:
👉 **[https://github.com/codecaine-zz/vlang_macos_webview_app_template](https://github.com/codecaine-zz/vlang_macos_webview_app_template)**

Key architectural patterns adopted and expanded from `vlang_macos_webview_app_template`:

- **Native Window Lifecycle**: Creation, initialization, event loop handling, and graceful destruction of Webview windows using V FFI to C/C++.
- **Cocoa Window Management (`window_helper.m`)**: Direct Objective-C runtime bridging to macOS `NSWindow`, `NSApplication`, and `WKWebView` for borderless styling, transparency, and native control.
- **Cross-Platform Placement Presets**: The 9-point screen placement geometry system (`center`, `upper_left`, `upper_right`, `top_center`, `bottom_left`, `bottom_right`, `bottom_center`, `center_left`, `center_right`).
- **Window State Control**: Native fullscreen toggling (`toggle_fullscreen`), stay-on-top pinning (`set_always_on_top`), minimize, and hide.
- **Two-Way IPC Communication**: Secure JavaScript-to-V native function bindings and V-to-JavaScript evaluation (`w.eval()`) with JSON-RPC argument synchronization.

```v
import webview

fn main() {
    mut w := webview.create_window(
        title: 'RAD Desktop Window',
        width: 1024,
        height: 768,
        debug: true
    )

    // Position window via 9-point placement preset from template
    w.set_placement('center')

    // Native window controls
    w.set_always_on_top(true) // Pin window on top
    // w.toggle_fullscreen()   // Toggle native fullscreen

    // Bind native V functions to JavaScript
    w.bind('getSystemStats', fn (w &webview.Window, args string) string {
        return '{"status": "ok"}'
    })

    w.navigate('data:text/html,<h1>Hello from V Webview!</h1>')
    w.run()
}
```

---

## 📦 Installation & Webview Setup (`v install ttytm.webview`)

If you don't already have the V `webview` module installed on your machine, you can install it in seconds using V's built-in package manager:

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

### System Prerequisites

Webview connects directly to your operating system's native browser engine:

- **macOS**: Built-in Apple WebKit (requires Xcode Command Line Tools: `xcode-select --install`).
- **Linux (Ubuntu / Debian / Kali)**: Tested on **Ubuntu** and **Kali Linux** (tested in Parallels Desktop). Works with the native system packages below:

  ```bash
  sudo apt-get update
  sudo apt-get install -y build-essential pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev libfontconfig1-dev
  ```

  For Webview to work, `libwebkitgtk-6.0-4` needs to be installed:
  ```bash
  sudo apt install libwebkitgtk-6.0-4
  ```

  > 💡 **Pre-compiled Binaries**: If the code is already compiled, the binary will just work without the need of the WebKit library being installed.

  On Ubuntu 22.04 or a distro release that provides WebKitGTK 4.0 instead, install `libwebkit2gtk-4.0-dev` in place of `libwebkit2gtk-4.1-dev`.

  **Important for Homebrew Linux users:** do not use a Homebrew `webkitgtk` installation for this project. `pkg-config` honors `PKG_CONFIG_PATH`, so Homebrew GTK, GLib, and WebKit libraries can be mixed with Ubuntu system libraries at link time. This causes errors such as `undefined reference to g_variant_builder_init_static` from a path under `/home/linuxbrew/.linuxbrew/`.

  Use this command when building or running from this repository. It preserves your V executable while ensuring V, `pkg-config`, and the linker use the Ubuntu libraries:

  ```bash
  V_BIN="$(command -v v)"
  env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
    PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    "$V_BIN" run demos/01_standard_controls.v
  ```

  To keep that command short, add this project-safe helper to your shell profile:

  ```bash
  v_webview() {
    env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
      PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
      "$(command -v v)" "$@"
  }
  v_webview run demos/01_standard_controls.v
  ```

  This only affects the current build command; Homebrew remains available for unrelated projects.

  Verify the active WebKitGTK package comes from the system installation:

  ```bash
  env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR \
    pkg-config --variable=prefix webkit2gtk-4.1
  # Expected on Ubuntu 24.04: /usr
  ```

  ### Demo 04: native placement and pinning

  Ubuntu 24.04 normally runs GNOME on Wayland. Wayland deliberately prevents applications from choosing an absolute screen position or forcing themselves above other windows, so those controls cannot be implemented reliably by GTK on a Wayland-only surface.

  `demos/04_window_placement_and_pin.v` selects GTK's X11 backend automatically on Linux when `GDK_BACKEND` is not already set. This gives the demo an XWayland window, allowing its nine placement presets and **Toggle Stay On Top** control to use the native GTK window APIs:

  ```bash
  v run demos/04_window_placement_and_pin.v
  ```

  Do not force `GDK_BACKEND=wayland` when testing demo 04. When overriding the backend manually, use `GDK_BACKEND=x11`; an Ubuntu desktop with XWayland support is required for the movement and pinning controls.

- **Linux (Fedora / RHEL)**:
  ```bash
  sudo dnf install -y gtk3-devel webkit2gtk4.0-devel
  ```
- **Linux (Arch Linux)**:
  ```bash
  sudo pacman -S gtk3 webkit2gtk
  ```
- **Windows**: Microsoft Edge WebView2 (included with Windows 10 & 11, or install Evergreen WebView2 Runtime).

> ✅ **Ubuntu & Kali-tested**: All 24 demos and all 16 desktop applications compile against system GTK3/WebKitGTK packages (tested on Ubuntu and Kali Linux in Parallels Desktop). When running pre-compiled binaries, the binary will just work without needing the WebKit library installed. Linux screenshots can be regenerated with `bash scratch/capture_linux_screenshots.sh` after installing `gnome-screenshot`.
>
> 💡 **Self-Contained in this Repository**:
> Note that this repository already vendors a complete, hardware-accelerated Webview backend with Cocoa Objective-C window management (`window_helper.m`) in `webview/`, so you can clone and run all applications and demos immediately without manual setup.

---

## ⚖️ Architectural Comparison: Developer Pros by Project Type

Choosing the right architectural model for cross-platform desktop development depends on your team's performance, memory, distribution, and iteration requirements. Here is a breakdown of the developer advantages across each architectural paradigm:

| Project / Architectural Model                   | Primary Tech Stack                    | Runtime Model                          | Binary Size         | Idle RAM      | Developer Pros & Strengths                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------------------------------------- | ------------------------------------- | -------------------------------------- | ------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`vlang_webview_rad_studio`** _(This Project)_ | **V (vlang) + Native OS Webview**     | Compiled Machine Code (Zero-VM)        | **~2.8 MB**         | **~15–30 MB** | • **Full Low-Level Power**: Compiled C-speed performance, direct Cocoa/Win32/GTK FFI, zero garbage collection pauses.<br>• **Uniform Modern Graphics**: Native OS webview renders rich HTML5/CSS3 animations, glassmorphism, and 76 themes consistently on every platform.<br>• **Air-Gapped Single Binary**: Zero runtime dependencies (no Node, Bun, or Python needed by end users).<br>• **Native Hardware Telemetry**: Built-in process execution, real-time CPU/RAM stats, cryptography, and atomic storage. |
| **`bun_rad_studio`**                            | **Bun + TypeScript / Web**            | JIT JavaScript Engine (JavaScriptCore) | ~45–60 MB (bundled) | ~40–70 MB     | • **Instant Startup & Hot-Reload**: No compilation step required — edit code and see live changes immediately.<br>• **Massive NPM Ecosystem**: Instant access to millions of JavaScript/TypeScript libraries, components, and widgets.<br>• **Minimal Toolchain Requirements**: No C compilers or Xcode Command Line Tools needed during development.<br>• **Full TypeScript Static Typing**: Clean interfaces and modern syntax out-of-the-box.                                                                  |
| **`vlang_macos_webview_app_template`**          | **V (vlang) + Minimal Cocoa Webview** | Compiled Machine Code                  | **~1.9 MB**         | **~12–25 MB** | • **Bare-Metal Simplicity**: Minimalist boilerplate with zero extraneous abstractions.<br>• **Granular Window Control**: Direct access to the 9-point screen placement geometry and Cocoa `window_helper.m`.<br>• **Ideal for Micro-Tools**: Perfect starting point for single-purpose utilities, menu bar apps, and launchers.                                                                                                                                                                                   |
| **`pywebview`**                                 | **Python + Native GUI/Webview**       | Interpreted / Bytecode (CPython)       | ~20–40 MB (frozen)  | ~50–90 MB     | • **Data Science & AI Powerhouse**: Seamless integration with PyTorch, TensorFlow, NumPy, Pandas, and automation scripts.<br>• **Rapid Prototyping**: Familiar Python syntax and dynamic typing allow rapid experimentation.<br>• **Multi-GUI Backend Support**: Automatically selects WinForms, Cocoa, QT, or GTK depending on environment.                                                                                                                                                                      |
| **`neutralinojs`**                              | **C++ Core + Web Frontend**           | Lightweight C++ Daemon + OS Webview    | **~3–5 MB**         | **~25–40 MB** | • **Lightweight Electron Alternative**: Extremely small distribution size compared to Chromium-based runtimes.<br>• **Familiar Web Tech**: Standard HTML/CSS/JS frontend communicating with native backend via WebSocket IPC.<br>• **Portable Cross-Platform Packaging**: Simple build process across Windows, Linux, and macOS without bundling Node.                                                                                                                                                            |

---

### Detailed Developer Trade-offs & When to Use What

#### ⚡ 1. `vlang_webview_rad_studio` (Compiled Low-Level V + OS Webview)

- **Why Choose It**: When you need raw native execution speed, direct operating system access (sockets, threads, processes, hardware telemetry), and ultra-compact executables (~2.8 MB) without sacrificing modern visual styling or themes.
- **The Developer Win**: You get the best of both worlds: low-level compiled backend power (like C or Go) paired with high-level web rendering (like Electron), but with 1/100th of the RAM footprint and instant distribution.

#### 🚀 2. `bun_rad_studio` (Bun / TypeScript JIT)

- **Why Choose It**: When iteration speed is paramount. You want to prototype UI components rapidly, hot-reload styles on the fly, and take advantage of the massive Node/NPM frontend ecosystem without waiting for a compiler.
- **The Developer Win**: Zero build step friction. You run `bun start` and immediately have a working designer with full TypeScript IntelliSense and vast package compatibility.

#### 🪟 3. `vlang_macos_webview_app_template` (Bare-Metal V Webview Foundation)

- **Why Choose It**: When building targeted native macOS micro-apps, background daemon monitors, or custom window managers that don't need the overhead of a full RAD visual designer.
- **The Developer Win**: Clean, understandable, uncluttered foundation code with full control over the Cocoa event tap and 9-point window geometry.

#### 🐍 4. `pywebview` (Python Ecosystem)

- **Why Choose It**: When your backend logic is heavily reliant on Python's scientific, machine learning, or automation libraries, and you need a clean GUI wrapper around an existing Python script or Jupyter-derived workflow.
- **The Developer Win**: No need to rewrite complex Python backend algorithms in another language—just plug your Python functions into JavaScript calls.

#### 📦 5. `neutralinojs` (Lightweight C++ Engine)

- **Why Choose It**: When your team consists primarily of web developers who want to avoid Electron's heavy binary overhead (150MB+) while keeping standard HTML/CSS/JS web architecture.
- **The Developer Win**: Extremely portable single-folder releases that run on low-spec hardware without requiring users to install Node.js.

---

## 🌟 Highlights

- **Visual RAD Form Designer IDE**: Borland Delphi / Visual Basic style drag-and-drop designer with 70+ components, visual docking, anchors, non-visual tray, property grid, and 1-click code exporters.
- **Cross-Platform Native Window Management**:
  - Fullscreen toggle (Cmd+F / F11)
  - Always-On-Top / Pinning (Cmd+Shift+T)
  - 9 Placement Presets (Center, Upper Left, Upper Right, Top Center, Bottom Left, Bottom Right, Bottom Center, Center Left, Center Right)
  - Native Minimize, Hide, and Clean Process Exit
- **76 Pixel-Perfect Desktop Themes**: Monokai Pro, Tokyo Night, Dracula, Nord, Gruvbox, One Dark Pro, macOS Sonoma, Windows 11 Fluent, Retro 90s (Win95, Commodore 64, Amiga, Mac System 7), Hacker (Cyberpunk 2077, Synthwave 84, Matrix Phosphor), and more.
- **Comprehensive API System Tools**: Ported directly from `simple_gg` and `vlang_simplegui`:
  - Process execution (`exec`, `exec_or`, `exec_bg`)
  - Subsystem hardware telemetry (CPU usage/cores/model, RAM total/used/free, battery state, uptime, disk stats, network ping)
  - Native file pickers, folders, and modal alerts (`osascript`, PowerShell, `zenity`)
  - Native clipboard manipulation (`pbcopy`/`pbpaste`, PowerShell, `xclip`)
  - Full Standard Library utilities: HTTP Client, Cryptography (SHA256, SHA512, MD5, HMAC), Base64/Hex encoding, String helpers, and Math Statistics
- **16 Enterprise System Studio Applications**: Complete GUI workstations in `applications/`
- **16 Companion CLI Workstations**: Matching CLI tools in `cli_apps/`
- **24 Interactive Feature Demos**: Complete showcase gallery in `demos/`
- **Standalone Cross-Platform Builder**: `build.vsh` packages native macOS `.app` bundles with custom `.icns`, Linux ELF binaries, and Windows `.exe`.

---

## 🎨 Visual RAD Studio IDE & Desktop Themes Gallery

| **Visual RAD Studio IDE Canvas**                                                                                                                                                     | **Desktop Menubar & System Controls**                                                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img src="resources/screenshots/rad_studio_ide.png" width="450" alt="Visual RAD Studio IDE Canvas" /><br>_Borland Delphi / VB style drag-and-drop form designer with 70+ components_ | <img src="resources/screenshots/desktop_menubar.png" width="450" alt="Desktop Menubar & System Controls" /><br>_Native-feel desktop menubar with hotkey shortcuts, stay-on-top, and fullscreen_ |

| **Custom Context Menu System**                                                                                                                                                               | **Pixel-Perfect 76 Theme Engine**                                                                                                                                           |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img src="resources/screenshots/custom_context_menu.png" width="450" alt="Custom Context Menu System" /><br>_Right-click menu overrides default browser context with custom desktop actions_ | <img src="resources/screenshots/theme_nord_showcase.png" width="450" alt="Nord Theme Showcase" /><br>_Instant live theme switching across 76 curated desktop color schemes_ |

---

## 📸 Enterprise Application Studios (16 Complete Apps)

| Application Studio       | Screenshot                                                                                          | Description & Quick Run                                                                                                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **API Studio Pro**       | <img src="resources/screenshots/app_api_studio.png" width="300" alt="API Studio Pro" />             | **Native REST Client Workstation**: Send HTTP GET and JSON POST requests, inspect status, headers, and response bodies, and receive explicit transport errors.<br>`v run applications/api_studio.v` |
| **System Studio Pro**    | <img src="resources/screenshots/app_system_studio.png" width="300" alt="System Studio Pro" />       | **Hardware Telemetry Workstation**: Real-time CPU model, cores, RAM allocation, disk capacity, battery telemetry, and privacy-protected IP monitoring.<br>`v run applications/system_studio.v`     |
| **Database Studio Pro**  | <img src="resources/screenshots/app_database_studio.png" width="300" alt="Database Studio Pro" />   | **SQL Workbench & Result Inspector**: Execute SQLite statements against an in-memory or selected database and inspect up to four result columns with explicit failure reporting.<br>`v run applications/database_studio.v` |
| **Git Workbench Studio** | <img src="resources/screenshots/app_git_studio.png" width="300" alt="Git Workbench Studio" />       | **Visual Git Inspector**: View the current branch, working-tree status, recent commits, diff statistics, and local/remote branches.<br>`v run applications/git_studio.v` |
| **DevTools Studio Pro**  | <img src="resources/screenshots/app_devtools_studio.png" width="300" alt="DevTools Studio Pro" />   | **Developer Text Workstation**: Inspect slug, reverse, title-case, word-count, checksum, Base64, and timestamp representations.<br>`v run applications/devtools_studio.v` |
| **Crypto Studio Pro**    | <img src="resources/screenshots/app_crypto_studio.png" width="300" alt="Crypto Studio Pro" />       | **Security & Hash Cryptography**: Generate SHA-256, SHA-512, MD5, SHA-1, HMAC, and Base64 values with live table updates and clipboard actions.<br>`v run applications/crypto_studio.v` |
| **Network Studio Pro**   | <img src="resources/screenshots/app_network_studio.png" width="300" alt="Network Studio Pro" />     | **Network Diagnostics & Telemetry**: ICMP ping latency tester, DNS resolver (`nslookup`), traceroute probe, and privacy-shielded interface telemetry.<br>`v run applications/network_studio.v`     |
| **Markdown Studio Pro**  | <img src="resources/screenshots/app_markdown_studio.png" width="300" alt="Markdown Studio Pro" />   | **Markdown Authoring Suite**: Edit Markdown, render basic headings/lists/paragraphs to HTML text, copy output, and open/save documents with filesystem error reporting.<br>`v run applications/markdown_studio.v` |
| **JSON Studio Pro**      | <img src="resources/screenshots/app_json_studio.png" width="300" alt="JSON Studio Pro" />           | **JSON Formatter & Validator**: Parse, prettify, minify, copy, and load JSON with syntax and file-read errors surfaced to the user.<br>`v run applications/json_studio.v` |
| **Process Studio Pro**   | <img src="resources/screenshots/app_process_studio.png" width="300" alt="Process Studio Pro" />     | **Process Inspector**: Refresh the active process table and inspect numeric PIDs, CPU, memory, user, and command information without sending signals.<br>`v run applications/process_studio.v` |
| **Color Studio Pro**     | <img src="resources/screenshots/app_color_studio.png" width="300" alt="Color Studio Pro" />         | **Color Token Workbench**: Inspect predefined swatches, copy CSS variables for an entered color, and display contrast guidance.<br>`v run applications/color_studio.v` |
| **DataConvert Studio**   | <img src="resources/screenshots/app_dataconvert_studio.png" width="300" alt="DataConvert Studio" /> | **JSON/CSV Converter**: Convert JSON arrays of objects to CSV and CSV rows to correctly escaped JSON objects.<br>`v run applications/dataconvert_studio.v` |
| **Regex Studio Pro**     | <img src="resources/screenshots/app_regex_studio.png" width="300" alt="Regex Studio Pro" />         | **Pattern Tester**: Compile and test a regular expression against text, with shortcuts for loading sample email and URL patterns.<br>`v run applications/regex_studio.v` |
| **App Bundler Studio**   | <img src="resources/screenshots/app_app_bundler_studio.png" width="300" alt="App Bundler Studio" /> | **Application Compiler Workbench**: Validate a V entry file, compile an optimized local-platform executable, and select a PNG icon for a future package configuration.<br>`v run applications/app_bundler_studio.v` |
| **Environment Studio**   | <img src="resources/screenshots/app_env_studio.png" width="300" alt="Environment Studio" />         | **Environment Variables Workbench**: Inspect common process variables, look up a named variable, and copy the current `PATH` value.<br>`v run applications/env_studio.v` |
| **Watcher Studio Pro**   | <img src="resources/screenshots/app_watcher_studio.png" width="300" alt="Watcher Studio Pro" />     | **Watcher Configuration Workbench**: Validate a watch directory and trigger command, browse for a directory, and test the command manually. Use `watcher_cli` for continuous monitoring and cancellation.<br>`v run applications/watcher_studio.v` |

---

## 🎮 Interactive Demos & Showcases (25 Demos)

| Demo                                  | Screenshot                                                                                                              | Highlights & Source                                                                                                               |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **01 - Standard Controls**            | <img src="resources/screenshots/demo_01_standard_controls.png" width="300" alt="Standard Controls" />                   | Buttons, text inputs, textareas, links, labels, and callbacks.<br>`v run demos/01_standard_controls.v`                            |
| **02 - Advanced Modern Controls**     | <img src="resources/screenshots/demo_02_advanced_modern_controls.png" width="300" alt="Advanced Controls" />            | Dropdowns, toggles, segmented controls, badges, and progress bars.<br>`v run demos/02_advanced_modern_controls.v`                 |
| **03 - Data & Non-Visual Controls**   | <img src="resources/screenshots/demo_03_data_and_non_visual.png" width="300" alt="Data & Non-Visual" />                 | Timers, dialog alerts, native file pickers, and OS notifications.<br>`v run demos/03_data_and_non_visual.v`                       |
| **04 - Window Placement & Pin**       | <img src="resources/screenshots/demo_04_window_placement_and_pin.png" width="300" alt="Window Placement" />             | 9 placement presets, stay-on-top window pinning, and clean process exit.<br>`v run demos/04_window_placement_and_pin.v`           |
| **05 - CRUD Todo Table**              | <img src="resources/screenshots/demo_05_crud_todo_table.png" width="300" alt="CRUD Todo Table" />                       | Dynamic table row insertion, deletion, and reactive state sync.<br>`v run demos/05_crud_todo_table.v`                             |
| **06 - Timer Control Studio**         | <img src="resources/screenshots/demo_06_timer_control_studio.png" width="300" alt="Timer Control Studio" />             | Interval timers, countdown clocks, progress updates, and audio chimes.<br>`v run demos/06_timer_control_studio.v`                 |
| **07 - Labeled Forms & Layouts**      | <img src="resources/screenshots/demo_07_labeled_form_and_desktop_controls.png" width="300" alt="Labeled Forms" />       | Form layouts, input validations, radio groups, and help tooltips.<br>`v run demos/07_labeled_form_and_desktop_controls.v`         |
| **08 - Analytics Dashboard Template** | <img src="resources/screenshots/demo_08_analytics_dashboard_template.png" width="300" alt="Analytics Dashboard" />      | KPI metrics, side-by-side data cards, and telemetry status displays.<br>`v run demos/08_analytics_dashboard_template.v`           |
| **09 - File Explorer IDE Template**   | <img src="resources/screenshots/demo_09_file_explorer_ide_template.png" width="300" alt="File Explorer" />              | File tree navigation, folder inspection, file details, and path explorer.<br>`v run demos/09_file_explorer_ide_template.v`        |
| **10 - DB Query Editor Template**     | <img src="resources/screenshots/demo_10_db_studio_query_editor_template.png" width="300" alt="DB Query Editor" />       | SQL query console, table result grids, and execution timing metrics.<br>`v run demos/10_db_studio_query_editor_template.v`        |
| **11 - App Settings & Preferences**   | <img src="resources/screenshots/demo_11_app_settings_preferences_template.png" width="300" alt="App Settings" />        | Tabbed preferences, switch controls, slider adjustments, and save states.<br>`v run demos/11_app_settings_preferences_template.v` |
| **12 - Advanced Desktop Controls**    | <img src="resources/screenshots/demo_12_advanced_desktop_app_controls.png" width="300" alt="Desktop Controls" />        | Clipboard history, split buttons, search inputs, and status badges.<br>`v run demos/12_advanced_desktop_app_controls.v`           |
| **13 - Productivity Studio**          | <img src="resources/screenshots/demo_13_productivity_controls_studio.png" width="300" alt="Productivity Studio" />      | Task lists, priority flags, progress indicators, and completion metrics.<br>`v run demos/13_productivity_controls_studio.v`       |
| **14 - SimpleGUI Fluent Form**        | <img src="resources/screenshots/demo_14_simplegui_fluent_form_demo.png" width="300" alt="Fluent Form" />                | Fluent declarative builder API with clean chaining and reactive events.<br>`v run demos/14_simplegui_fluent_form_demo.v`          |
| **15 - All Controls Showcase**        | <img src="resources/screenshots/demo_15_simplegui_all_controls_showcase.png" width="300" alt="All Controls Showcase" /> | Complete catalog of all SimpleGUI controls rendered in Monokai Pro.<br>`v run demos/15_simplegui_all_controls_showcase.v`         |
| **16 - Parity API Demo**              | <img src="resources/screenshots/demo_16_simplegui_parity_api_demo.png" width="300" alt="Parity API Demo" />             | Named builder methods matching `vlang_simplegui` control signatures.<br>`v run demos/16_simplegui_parity_api_demo.v`              |
| **17 - Layout Types Showcase**        | <img src="resources/screenshots/demo_17_simplegui_layout_types_showcase.png" width="300" alt="Layout Types" />          | Rows, grids, flex containers, KPI cards, and responsive layouts.<br>`v run demos/17_simplegui_layout_types_showcase.v`            |
| **18 - SimpleGUI Ergonomics**         | <img src="resources/screenshots/demo_18_simplegui_ergonomics_demo.png" width="300" alt="Ergonomics Demo" />             | Idiomatic V builder syntax with minimum boilerplate code.<br>`v run demos/18_simplegui_ergonomics_demo.v`                         |
| **19 - State Persistence & Binding**  | <img src="resources/screenshots/demo_19_state_persistence_and_binding_demo.png" width="300" alt="State Persistence" />  | Two-way reactive data synchronization with atomic file saving.<br>`v run demos/19_state_persistence_and_binding_demo.v`           |
| **20 - CodeFreelance Theme Demo**     | <img src="resources/screenshots/demo_20_codefreelance_theme_demo.png" width="300" alt="CodeFreelance Theme" />          | Monokai, Dracula, Tokyo Night, and hacker phosphor theme styling.<br>`v run demos/20_codefreelance_theme_demo.v`                  |
| **21 - Vlang Parity Controls**        | <img src="resources/screenshots/demo_21_vlang_parity_controls_showcase.png" width="300" alt="Vlang Parity Controls" />  | Verification demo testing all visual controls and modifier methods.<br>`v run demos/21_vlang_parity_controls_showcase.v`          |
| **22 - Context Menu & Menubar**       | <img src="resources/screenshots/demo_22_context_menu_and_menu_demo.png" width="300" alt="Context Menu & Menubar" />     | Custom desktop menubar dropdowns and right-click context menus.<br>`v run demos/22_context_menu_and_menu_demo.v`                  |
| **23 - 76 All-Themes Showcase**       | <img src="resources/screenshots/demo_23_all_themes_all_controls_showcase.png" width="300" alt="76 Themes Showcase" />   | Interactive live switcher across all 76 built-in desktop themes.<br>`v run demos/23_all_themes_all_controls_showcase.v`           |
| **24 - DevOps Sentinel Workstation**  | <img src="resources/screenshots/demo_24_devops_sentinel_guide.png" width="300" alt="DevOps Sentinel" />                 | Production workstation with CPU, RAM, disk, and protected network health.<br>`v run demos/24_devops_sentinel_guide.v`             |
| **25 - Developer Utilities Suite**    | 🛠️ Synthetic data, LRU caching, color spaces, semver, and validation.                                                     | Showcase of the 30-module developer utility suite embedded in SimpleGUI.<br>`v run demos/25_developer_utilities_suite_demo.v`        |

---

## 📁 Repository Structure

```
vlang_webview_rad_studio/
├── main.v                         # RAD Studio Visual Form Designer IDE Entry Point
├── rad_engine.v                   # Code generation and live preview runner
├── build.vsh                      # Standalone Cross-Platform Desktop App Builder
├── v.mod                          # Package definition & metadata
│
├── webview/                       # Cross-Platform Webview C/C++ Binding & Window Helpers
│   ├── lib.v                      # V Webview wrapper & window manipulation methods
│   ├── lib.c.v                    # Platform C compiler & linker flags
│   ├── system_bindings.v          # IPC bindings for hardware, telemetry & stdlib
│   ├── utils.v                    # JSON2 event argument & RPC serialization
│   ├── webview.h / webview.cc     # Upstream Webview C++ backend
│   └── window_helper.m            # macOS Cocoa Objective-C window helper
│
├── system/                        # RAD Development System Tools (from simple_gg & vlang_simplegui)
│   ├── sys.v                      # Process execution, telemetry, dialogs, clipboard, audio
│   └── stdlib.v                   # HTTP client, crypto hashes, encoders, string utils, stats
│
├── simplegui/                     # High-Level Declarative GUI Framework
│   ├── simplegui.v                # Window builder, reactive bindings, HTML/CSS generation
│   ├── controls.v                 # 70+ Control specifications & references
│   └── theme.v                    # Catalog of 76 desktop form themes
│
├── applications/                  # 16 Enterprise RAD System Studio Desktop Applications
│   ├── system_studio.v            # System Information & Hardware Telemetry Studio
│   ├── crypto_studio.v            # Cryptographic Hashes & Encoders Studio
│   ├── json_studio.v              # JSON Formatter, Validator & Tree Query Studio
│   ├── devtools_studio.v          # Omnitool Developer Utilities & Time Studio
│   ├── process_studio.v           # Process & Task Manager Workstation
│   ├── database_studio.v          # SQLite Database & SQL Console Studio
│   ├── api_studio.v               # REST API Client & Endpoint Studio
│   ├── dataconvert_studio.v       # JSON / CSV / TSV Data Converter Studio
│   ├── watcher_studio.v           # File System Watcher & Trigger Workstation
│   ├── regex_studio.v             # Regular Expression Tester & Match Studio
│   ├── app_bundler_studio.v       # Application Packaging & Bundler Studio
│   ├── network_studio.v           # Network Diagnostics & Port Telemetry Studio
│   ├── git_studio.v               # Visual Git Workbench & History Studio
│   ├── markdown_studio.v          # Markdown Live Editor & HTML Preview Studio
│   ├── color_studio.v             # Color Palette & WCAG Contrast Ratio Studio
│   └── env_studio.v               # Environment Variables Inspector Studio
│
├── cli_apps/                      # 16 Companion CLI Workstations
│   ├── system_cli.v               # System & hardware telemetry CLI
│   ├── crypto_cli.v               # Cryptographic hashing & encoders CLI
│   ├── json_cli.v                 # JSON formatter & validator CLI
│   ├── devtools_cli.v             # Developer tools & math stats CLI
│   ├── process_cli.v              # Process manager & task killer CLI
│   ├── database_cli.v             # SQLite query & schema inspector CLI
│   ├── api_cli.v                  # HTTP REST API client CLI
│   ├── dataconvert_cli.v          # Data conversion CLI
│   ├── watcher_cli.v              # File system watcher CLI
│   ├── regex_cli.v                # Regex tester & replacer CLI
│   ├── app_bundler_cli.v          # Desktop application bundler CLI
│   ├── network_cli.v              # Network diagnostics & ping CLI
│   ├── git_cli.v                  # Git workbench CLI
│   ├── markdown_cli.v             # Markdown converter CLI
│   ├── color_cli.v                # Color converter & WCAG contrast CLI
│   └── env_cli.v                  # Environment variables CLI
│
├── demos/                         # 25 Interactive Feature Demos
│   ├── 01_standard_controls.v
│   ├── 02_advanced_modern_controls.v
│   ├── 03_data_and_non_visual.v
│   ├── 04_window_placement_and_pin.v
│   ├── 05_crud_todo_table.v
│   ├── 06_timer_control_studio.v
│   ├── 07_labeled_form_and_desktop_controls.v
│   ├── 08_analytics_dashboard_template.v
│   ├── 09_file_explorer_ide_template.v
│   ├── 10_db_studio_query_editor_template.v
│   ├── 11_app_settings_preferences_template.v
│   ├── 12_advanced_desktop_app_controls.v
│   ├── 13_productivity_controls_studio.v
│   ├── 14_simplegui_fluent_form_demo.v
│   ├── 15_simplegui_all_controls_showcase.v
│   ├── 16_simplegui_parity_api_demo.v
│   ├── 17_simplegui_layout_types_showcase.v
│   ├── 18_simplegui_ergonomics_demo.v
│   ├── 19_state_persistence_and_binding_demo.v
│   ├── 20_codefreelance_theme_demo.v
│   ├── 21_vlang_parity_controls_showcase.v
│   ├── 22_context_menu_and_menu_demo.v
│   ├── 23_all_themes_all_controls_showcase.v
│   ├── 24_devops_sentinel_guide.v
│   └── 25_developer_utilities_suite_demo.v
│
└── resources/
    ├── ide.html                   # Delphi/VB Visual RAD IDE Design Canvas
    └── icon.png                   # High-resolution application icon
```

---

## 🚀 Quick Start

### Prerequisites

- [V compiler](https://vlang.io) (v0.4.x or later)
- macOS: Xcode command line tools (`xcode-select --install`)
- Linux: `gtk3`, `webkit2gtk-4.1` (or `webkit2gtk-4.0`), `libwebkitgtk-6.0-4` (needed for source builds/runs; pre-compiled binaries run directly)
- Windows: Microsoft Edge WebView2 runtime

### 1. Launch Visual RAD Studio IDE

```bash
# Compile and run the Visual RAD Studio Form Designer
v run .
```

### 2. Run Any Enterprise Studio Application

```bash
# Launch System Telemetry Studio
v run applications/system_studio.v

# Launch Database Studio
v run applications/database_studio.v

# Launch DevTools Studio
v run applications/devtools_studio.v
```

### 3. Run Any Companion CLI Tool

```bash
# Full hardware telemetry
v run cli_apps/system_cli.v -t

# Crypto hashes and encoders
v run cli_apps/crypto_cli.v -A "My Secret Message"

# Developer stats calculator
v run cli_apps/devtools_cli.v -S "10, 20, 30, 45, 90"
```

### 4. Run Interactive Demos

```bash
# Window placement presets & stay-on-top pinning
v run demos/04_window_placement_and_pin.v

# The 76-theme showcase
v run demos/23_all_themes_all_controls_showcase.v

# 30-Module Developer Utility Suite showcase
v run demos/25_developer_utilities_suite_demo.v
```

---

## Reliability, Concurrency, and CLI Contracts

- SimpleGUI event callbacks run away from the native webview event loop. JavaScript/DOM updates are dispatched back to the webview thread.
- While a button action is running, action buttons are disabled and restored when the callback returns. This prevents duplicate execution and stale overlapping button results.
- The generated layout adds narrow-window fallbacks for buttons, form controls, tables, labels, and the fixed status bar.
- GUI file operations use V filesystem APIs; subprocess arguments are passed through `system.exec_safe` where shell interpretation is not explicitly part of the feature.
- Every CLI supports `--help` and `--version`. Usage errors return exit code `2`; terminal runtime, filesystem, network, database, and subprocess failures return exit code `1`.
- `database_cli` opens databases read-only unless `--allow-write` is supplied. `watcher_cli` validates its interval/path, sleeps between polls, exits if the watched path disappears, logs trigger-command failures while continuing to monitor, and can be stopped with `Ctrl+C`.

Safe automated checks:

```bash
v test .
v fmt -verify $(git ls-files '*.v' '*.vsh')

# Compile each entry point without launching GUI windows
for source in applications/*.v cli_apps/*.v; do
	v -o "/tmp/$(basename "${source%.v}")" "$source"
done
```

---

## 🧰 30-Module Comprehensive Developer Utility Suite

Integrated directly from [**vlang_utils**](https://github.com/codecaine-zz/vlang_utils), this repository contains 30 production-grade, zero-dependency utility modules ready for immediate import in any desktop application, CLI tool, or background service:

| Module | Core Purpose & Capabilities |
| --- | --- |
| **`archiveutils`** | ZIP archive creation, extraction, in-memory archive generation, and entry inspection. |
| **`asyncutils`** | Worker pools, concurrent task scheduling, parallel mapping, futures, and channel fan-out. |
| **`bitutils`** | Bitfield manipulation, bitsets, endianness conversions, masks, and binary flags. |
| **`cacheutils`** | In-memory LRU (Least Recently Used) and TTL (Time-to-Live) auto-evicting caches. |
| **`cliutils`** | Terminal formatting, ANSI color palettes, spinners, progress bars, and CLI prompts. |
| **`colorutils`** | Hex, RGB, HSL, HSV conversions, contrast ratio calculation, and palette generation. |
| **`compressutils`**| Streaming compression & decompression using Zlib, Gzip, and Deflate. |
| **`cryptoutils`** | Secure hashes (SHA-256, SHA-512, MD5), HMAC, PBKDF2, AES-GCM encryption, and token generators. |
| **`envutils`** | `.env` file parsing, environment variable loading, default fallback values, and type casting. |
| **`fileutils`** | Safe atomic file writes, path traversals, temp file lifecycle, directory walkers, and checksums. |
| **`flowutils`** | Function debouncing, throttling, exponential backoff retries, and circuit breakers. |
| **`htmlutils`** | HTML entity escaping, tag stripping, sanitization, and lightweight web scraping helpers. |
| **`httputils`** | High-level HTTP client with custom headers, query param encoding, and resilient error handling. |
| **`logutils`** | Multi-level structured logger (Trace, Debug, Info, Warn, Error) with file and console sinks. |
| **`mockutils`** | Synthetic mock data generation (names, emails, phones, IPv4 addresses, and user profiles). |
| **`netutils`** | IPv4/IPv6 validation, CIDR subnet calculations, port availability checking, and DNS queries. |
| **`regexutils`** | Cached compiled regular expression matching, capturing groups, and string replacements. |
| **`semverutils`** | SemVer 2.0.0 parsing, version comparisons, range checking (`^`, `~`, `>=`, `<=`), and sorting. |
| **`sliceutils`** | Generic slice operations: chunk, deduplicate, filter, map, reduce, flatten, and shuffle. |
| **`sqliteutils`** | SQLite connection helpers, query mapping, transaction handling, and schema migrations. |
| **`stateutils`** | Reactive application state container with change listeners and event-driven updates. |
| **`statutils`** | Descriptive statistics: mean, median, mode, standard deviation, variance, and percentiles. |
| **`structutils`** | Struct cloning, field inspection, dictionary conversion, and property mapping. |
| **`strutils`** | String casing (snake_case, camelCase, kebab-case, PascalCase), slugification, and padding. |
| **`sysutils`** | Hardware telemetry, CPU load, RAM usage, process lifecycle, and cross-platform OS detection. |
| **`tarutils`** | POSIX TAR archive creation, tar extraction, gzip-compressed tarballs, and header parsing. |
| **`templateutils`**| Lightweight mustache-style template interpolation and string rendering. |
| **`timeutils`** | Relative time formatting ("2 hours ago"), date parsing, ISO8601 formatting, and stopwatches. |
| **`tomlutils`** | Lightweight TOML configuration parser and key-value serializer. |
| **`validutils`** | Comprehensive validation rules: email, URL, UUID, credit card numbers, and regex patterns. |

> 📘 **Detailed Documentation**: See [**UTILS_API.md**](UTILS_API.md) for the complete reference manual with signatures and code examples for all 30 utility packages.

---

## 📦 Cross-Platform App Bundler (`build.vsh`)

Build standalone, production-ready desktop applications:

```bash
# Build macOS .app bundle with custom AppIcon.icns and codesign
v run build.vsh -n "RAD Studio" main.v

# Build a specific application studio into a .app bundle
v run build.vsh -n "System Studio" applications/system_studio.v

# Build for Windows (.exe)
v run build.vsh -t windows -n "RADStudio" main.v

# Build for Linux (ELF binary + .desktop entry)
v run build.vsh -t linux -n "RADStudio" main.v
```

---

## 🙏 Credits & Heritage

Special recognition and credits to the upstream projects that made this architecture possible:

- **[bun_rad_studio](https://github.com/codecaine-zz/bun_rad_studio)** by [@codecaine-zz](https://github.com/codecaine-zz) — Visual RAD Studio Delphi/VB IDE architecture, component catalog, and themes.
- **[vlang_macos_webview_app_template](https://github.com/codecaine-zz/vlang_macos_webview_app_template)** by [@codecaine-zz](https://github.com/codecaine-zz) — Cross-platform Webview window management, presets, and Cocoa Cocoa/Win32/GTK bindings.
- **[simple_gg](https://github.com/codecaine-zz/simple_gg)** by [@codecaine-zz](https://github.com/codecaine-zz) — Native V GUI runtime, hardware telemetry, process runners, and system API tools.
- **[vlang_simplegui](https://github.com/codecaine-zz/vlang_simplegui)** by [@codecaine-zz](https://github.com/codecaine-zz) — Declarative GUI builder ergonomics, reactive states, and desktop form themes.
- **[vlang_utils](https://github.com/codecaine-zz/vlang_utils)** by [@codecaine-zz](https://github.com/codecaine-zz) — 30-Module developer utility suite for caching, crypto, SQLite, network, compression, and synthetic data.

---

## 🌐 Other Cross-Platform RAD GUI Projects

These are other projects I like that are cross platform for rad gui development by other people:

- **[pywebview](https://github.com/r0x0r/pywebview)** — Lightweight cross-platform native wrapper around webview components for building desktop GUIs with Python, HTML, CSS, and JavaScript.
- **[neutralinojs](https://github.com/neutralinojs/neutralinojs)** — Portable, lightweight cross-platform desktop application framework that lets you build native desktop apps using web technologies without the overhead of Chromium/Node.js.

---

## 📄 License

MIT License. Created for the Vlang and RAD development community.
