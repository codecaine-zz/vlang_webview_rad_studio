# ⚡ Vlang Webview RAD Studio

**Cross-Platform Visual Rapid Application Development (RAD) Studio & Enterprise Desktop Suite** powered by native **V (vlang)** and lightweight hardware-accelerated **Webview** (macOS Cocoa / WebKit, Windows Win32 / Edge WebView2, Linux GTK / WebKit2GTK).

> 💡 **Built Off & Powered By**:
> This project is built directly on top of [**vlang_macos_webview_app_template**](https://github.com/codecaine-zz/vlang_macos_webview_app_template) for cross-platform Webview window management, porting the full visual IDE from [**bun_rad_studio**](https://github.com/codecaine-zz/bun_rad_studio), and integrating the native RAD API system tools from [**simple_gg**](https://github.com/codecaine-zz/simple_gg) and [**vlang_simplegui**](https://github.com/codecaine-zz/vlang_simplegui).

> 📖 **Full API Reference**:
> For complete documentation with copy-pasteable code examples for every UI control, system telemetry tool, security utility, and state persistence method, see [**API.md**](API.md).

---

## 🏛️ Foundations & Project Lineage

This project is directly based upon and unifies several foundational open-source codebases authored by [@codecaine-zz](https://github.com/codecaine-zz):

| Foundational Project | Repository | Core Subsystems & Architectural Roles |
|---|---|---|
| **vlang_macos_webview_app_template** | [codecaine-zz/vlang_macos_webview_app_template](https://github.com/codecaine-zz/vlang_macos_webview_app_template) | **Native Window Management & Webview Foundation**: The core template and architectural foundation used to manage windows in Webview in V. Provided the native C/C++ Webview binding patterns in V, Cocoa Objective-C window helper integration (`window_helper.m`), 9 placement presets (`center`, `upper_left`, `top_center`, etc.), stay-on-top window pinning (`set_always_on_top`), fullscreen toggling, and native desktop IPC event loop. |
| **bun_rad_studio** | [codecaine-zz/bun_rad_studio](https://github.com/codecaine-zz/bun_rad_studio) | **Primary IDE & RAD Blueprint**: Ported from Bun/TypeScript to native V. Provided the Borland Delphi & Visual Basic visual form designer architecture, 70+ drag-and-drop components, anchor & docking layout engines, property grid, 10 application templates, non-visual component tray, and complete 42-theme design system. |
| **simple_gg** | [codecaine-zz/simple_gg](https://github.com/codecaine-zz/simple_gg) | **RAD Development System Tools**: Ported native system and runtime toolkits (`system/sys.v` & `system/stdlib.v`): process execution (`exec`, `exec_or`, `exec_bg`), real-time hardware telemetry (CPU cores/model/usage, RAM, battery, network ping), native dialogs (`osascript`, PowerShell, `zenity`), clipboard manipulation, cryptography (SHA256, HMAC), encoders, and math statistics. |
| **vlang_simplegui** | [codecaine-zz/vlang_simplegui](https://github.com/codecaine-zz/vlang_simplegui) | **Declarative High-Level GUI & Themes**: Provided the fluent declarative GUI builder syntax (`win.button()`, `win.input()`, `win.radio()`, `win.toggle()`), reactive two-way value synchronization, KPI dashboards, table components, and dynamic live theme switching across all 42 desktop form themes. |

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

## ⚖️ Architectural Comparison: Developer Pros by Project Type

Choosing the right architectural model for cross-platform desktop development depends on your team's performance, memory, distribution, and iteration requirements. Here is a breakdown of the developer advantages across each architectural paradigm:

| Project / Architectural Model | Primary Tech Stack | Runtime Model | Binary Size | Idle RAM | Developer Pros & Strengths |
|---|---|---|---|---|---|
| **`vlang_webview_rad_studio`** *(This Project)* | **V (vlang) + Native OS Webview** | Compiled Machine Code (Zero-VM) | **~2.8 MB** | **~15–30 MB** | • **Full Low-Level Power**: Compiled C-speed performance, direct Cocoa/Win32/GTK FFI, zero garbage collection pauses.<br>• **Uniform Modern Graphics**: Native OS webview renders rich HTML5/CSS3 animations, glassmorphism, and 42 themes consistently on every platform.<br>• **Air-Gapped Single Binary**: Zero runtime dependencies (no Node, Bun, or Python needed by end users).<br>• **Native Hardware Telemetry**: Built-in process execution, real-time CPU/RAM stats, cryptography, and atomic storage. |
| **`bun_rad_studio`** | **Bun + TypeScript / Web** | JIT JavaScript Engine (JavaScriptCore) | ~45–60 MB (bundled) | ~40–70 MB | • **Instant Startup & Hot-Reload**: No compilation step required — edit code and see live changes immediately.<br>• **Massive NPM Ecosystem**: Instant access to millions of JavaScript/TypeScript libraries, components, and widgets.<br>• **Minimal Toolchain Requirements**: No C compilers or Xcode Command Line Tools needed during development.<br>• **Full TypeScript Static Typing**: Clean interfaces and modern syntax out-of-the-box. |
| **`vlang_macos_webview_app_template`** | **V (vlang) + Minimal Cocoa Webview** | Compiled Machine Code | **~1.9 MB** | **~12–25 MB** | • **Bare-Metal Simplicity**: Minimalist boilerplate with zero extraneous abstractions.<br>• **Granular Window Control**: Direct access to the 9-point screen placement geometry and Cocoa `window_helper.m`.<br>• **Ideal for Micro-Tools**: Perfect starting point for single-purpose utilities, menu bar apps, and launchers. |
| **`pywebview`** | **Python + Native GUI/Webview** | Interpreted / Bytecode (CPython) | ~20–40 MB (frozen) | ~50–90 MB | • **Data Science & AI Powerhouse**: Seamless integration with PyTorch, TensorFlow, NumPy, Pandas, and automation scripts.<br>• **Rapid Prototyping**: Familiar Python syntax and dynamic typing allow rapid experimentation.<br>• **Multi-GUI Backend Support**: Automatically selects WinForms, Cocoa, QT, or GTK depending on environment. |
| **`neutralinojs`** | **C++ Core + Web Frontend** | Lightweight C++ Daemon + OS Webview | **~3–5 MB** | **~25–40 MB** | • **Lightweight Electron Alternative**: Extremely small distribution size compared to Chromium-based runtimes.<br>• **Familiar Web Tech**: Standard HTML/CSS/JS frontend communicating with native backend via WebSocket IPC.<br>• **Portable Cross-Platform Packaging**: Simple build process across Windows, Linux, and macOS without bundling Node. |

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
- **42 Pixel-Perfect Desktop Themes**: Monokai Pro, Tokyo Night, Dracula, Nord, Gruvbox, One Dark Pro, macOS Sonoma, Windows 11 Fluent, Retro 90s (Win95, Commodore 64, Amiga, Mac System 7), Hacker (Cyberpunk 2077, Synthwave 84, Matrix Phosphor).
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

| **Visual RAD Studio IDE Canvas** | **Desktop Menubar & System Controls** |
|---|---|
| <img src="resources/screenshots/rad_studio_ide.png" width="450" alt="Visual RAD Studio IDE Canvas" /><br>*Borland Delphi / VB style drag-and-drop form designer with 70+ components* | <img src="resources/screenshots/desktop_menubar.png" width="450" alt="Desktop Menubar & System Controls" /><br>*Native-feel desktop menubar with hotkey shortcuts, stay-on-top, and fullscreen* |

| **Custom Context Menu System** | **Pixel-Perfect 42 Theme Engine** |
|---|---|
| <img src="resources/screenshots/custom_context_menu.png" width="450" alt="Custom Context Menu System" /><br>*Right-click menu overrides default browser context with custom desktop actions* | <img src="resources/screenshots/theme_nord_showcase.png" width="450" alt="Nord Theme Showcase" /><br>*Instant live theme switching across 42 curated desktop color schemes* |

---

## 📸 Enterprise Application Studios (16 Complete Apps)

| Application Studio | Screenshot | Description & Quick Run |
|---|---|---|
| **API Studio Pro** | <img src="resources/screenshots/app_api_studio.png" width="300" alt="API Studio Pro" /> | **Native REST Client Workstation**: Complete endpoint tester with GET, POST, PUT, DELETE, custom request headers, body payloads, and JSON syntax inspection.<br>`v run applications/api_studio.v` |
| **System Studio Pro** | <img src="resources/screenshots/app_system_studio.png" width="300" alt="System Studio Pro" /> | **Hardware Telemetry Workstation**: Real-time CPU model, cores, RAM allocation, disk capacity, battery telemetry, and privacy-protected IP monitoring.<br>`v run applications/system_studio.v` |
| **Database Studio Pro** | <img src="resources/screenshots/app_database_studio.png" width="300" alt="Database Studio Pro" /> | **SQL Workbench & Table Inspector**: Interactive SQL executor, table catalog viewer, schema explorer, and automated test-record seed generation.<br>`v run applications/database_studio.v` |
| **Git Workbench Studio** | <img src="resources/screenshots/app_git_studio.png" width="300" alt="Git Workbench Studio" /> | **Visual Git Manager**: Real-time branch switcher, commit status monitor, working tree inspector, log analyzer, and staging workbench.<br>`v run applications/git_studio.v` |
| **DevTools Studio Pro** | <img src="resources/screenshots/app_devtools_studio.png" width="300" alt="DevTools Studio Pro" /> | **Developer Math & Stats Workstation**: Statistical variance, standard deviation, percentile calculator, UUID generator, and performance timers.<br>`v run applications/devtools_studio.v` |
| **Crypto Studio Pro** | <img src="resources/screenshots/app_crypto_studio.png" width="300" alt="Crypto Studio Pro" /> | **Security & Hash Cryptography**: Generate SHA-256, SHA-512, MD5, HMAC, secure random tokens, and cryptographic verification digests.<br>`v run applications/crypto_studio.v` |
| **Network Studio Pro** | <img src="resources/screenshots/app_network_studio.png" width="300" alt="Network Studio Pro" /> | **Network Diagnostics & Telemetry**: ICMP ping latency tester, DNS resolver (`nslookup`), traceroute probe, and privacy-shielded interface telemetry.<br>`v run applications/network_studio.v` |
| **Markdown Studio Pro** | <img src="resources/screenshots/app_markdown_studio.png" width="300" alt="Markdown Studio Pro" /> | **Live Markdown Authoring Suite**: Dual-pane editor with live HTML rendering, heading structure, table generation, and export utilities.<br>`v run applications/markdown_studio.v` |
| **JSON Studio Pro** | <img src="resources/screenshots/app_json_studio.png" width="300" alt="JSON Studio Pro" /> | **JSON Formatter & Schema Validator**: Parse, reformat, minify, inspect tree hierarchies, and validate JSON payloads with zero dependencies.<br>`v run applications/json_studio.v` |
| **Process Studio Pro** | <img src="resources/screenshots/app_process_studio.png" width="300" alt="Process Studio Pro" /> | **Process Manager & Task Monitor**: Inspect system processes, PIDs, memory usage, command-line arguments, and gracefully terminate runaway tasks.<br>`v run applications/process_studio.v` |
| **Color Studio Pro** | <img src="resources/screenshots/app_color_studio.png" width="300" alt="Color Studio Pro" /> | **Color Palette & WCAG Inspector**: Convert between HEX, RGB, HSL, test accessibility contrast ratios, and inspect design token compatibility.<br>`v run applications/color_studio.v` |
| **DataConvert Studio** | <img src="resources/screenshots/app_dataconvert_studio.png" width="300" alt="DataConvert Studio" /> | **Data Transform Matrix**: Transform datasets between CSV, TSV, JSON, and raw key-value representations with delimiter detection.<br>`v run applications/dataconvert_studio.v` |
| **Regex Studio Pro** | <img src="resources/screenshots/app_regex_studio.png" width="300" alt="Regex Studio Pro" /> | **Pattern Matcher & Regex Tester**: Real-time expression testing, capturing group extraction, and string replacement validator.<br>`v run applications/regex_studio.v` |
| **App Bundler Studio** | <img src="resources/screenshots/app_app_bundler_studio.png" width="300" alt="App Bundler Studio" /> | **Desktop Distribution Workstation**: Visual packaging interface for `build.vsh` to produce macOS `.app` bundles, Windows `.exe`, and Linux binaries.<br>`v run applications/app_bundler_studio.v` |
| **Environment Studio** | <img src="resources/screenshots/app_env_studio.png" width="300" alt="Environment Studio" /> | **Environment Variables Workbench**: Audit active process environment variables, search keys, export `.env` files, and test path configurations.<br>`v run applications/env_studio.v` |
| **Watcher Studio Pro** | <img src="resources/screenshots/app_watcher_studio.png" width="300" alt="Watcher Studio Pro" /> | **Filesystem Event Monitor**: Live directory watcher monitoring file changes, creations, deletions, and logging telemetry events in real time.<br>`v run applications/watcher_studio.v` |

---

## 🎮 Interactive Demos & Showcases (24 Demos)

| Demo | Screenshot | Highlights & Source |
|---|---|---|
| **01 - Standard Controls** | <img src="resources/screenshots/demo_01_standard_controls.png" width="300" alt="Standard Controls" /> | Buttons, text inputs, textareas, links, labels, and callbacks.<br>`v run demos/01_standard_controls.v` |
| **02 - Advanced Modern Controls** | <img src="resources/screenshots/demo_02_advanced_modern_controls.png" width="300" alt="Advanced Controls" /> | Dropdowns, toggles, segmented controls, badges, and progress bars.<br>`v run demos/02_advanced_modern_controls.v` |
| **03 - Data & Non-Visual Controls** | <img src="resources/screenshots/demo_03_data_and_non_visual.png" width="300" alt="Data & Non-Visual" /> | Timers, dialog alerts, native file pickers, and OS notifications.<br>`v run demos/03_data_and_non_visual.v` |
| **04 - Window Placement & Pin** | <img src="resources/screenshots/demo_04_window_placement_and_pin.png" width="300" alt="Window Placement" /> | 9 placement presets, stay-on-top window pinning, and clean process exit.<br>`v run demos/04_window_placement_and_pin.v` |
| **05 - CRUD Todo Table** | <img src="resources/screenshots/demo_05_crud_todo_table.png" width="300" alt="CRUD Todo Table" /> | Dynamic table row insertion, deletion, and reactive state sync.<br>`v run demos/05_crud_todo_table.v` |
| **06 - Timer Control Studio** | <img src="resources/screenshots/demo_06_timer_control_studio.png" width="300" alt="Timer Control Studio" /> | Interval timers, countdown clocks, progress updates, and audio chimes.<br>`v run demos/06_timer_control_studio.v` |
| **07 - Labeled Forms & Layouts** | <img src="resources/screenshots/demo_07_labeled_form_and_desktop_controls.png" width="300" alt="Labeled Forms" /> | Form layouts, input validations, radio groups, and help tooltips.<br>`v run demos/07_labeled_form_and_desktop_controls.v` |
| **08 - Analytics Dashboard Template** | <img src="resources/screenshots/demo_08_analytics_dashboard_template.png" width="300" alt="Analytics Dashboard" /> | KPI metrics, side-by-side data cards, and telemetry status displays.<br>`v run demos/08_analytics_dashboard_template.v` |
| **09 - File Explorer IDE Template** | <img src="resources/screenshots/demo_09_file_explorer_ide_template.png" width="300" alt="File Explorer" /> | File tree navigation, folder inspection, file details, and path explorer.<br>`v run demos/09_file_explorer_ide_template.v` |
| **10 - DB Query Editor Template** | <img src="resources/screenshots/demo_10_db_studio_query_editor_template.png" width="300" alt="DB Query Editor" /> | SQL query console, table result grids, and execution timing metrics.<br>`v run demos/10_db_studio_query_editor_template.v` |
| **11 - App Settings & Preferences** | <img src="resources/screenshots/demo_11_app_settings_preferences_template.png" width="300" alt="App Settings" /> | Tabbed preferences, switch controls, slider adjustments, and save states.<br>`v run demos/11_app_settings_preferences_template.v` |
| **12 - Advanced Desktop Controls** | <img src="resources/screenshots/demo_12_advanced_desktop_app_controls.png" width="300" alt="Desktop Controls" /> | Clipboard history, split buttons, search inputs, and status badges.<br>`v run demos/12_advanced_desktop_app_controls.v` |
| **13 - Productivity Studio** | <img src="resources/screenshots/demo_13_productivity_controls_studio.png" width="300" alt="Productivity Studio" /> | Task lists, priority flags, progress indicators, and completion metrics.<br>`v run demos/13_productivity_controls_studio.v` |
| **14 - SimpleGUI Fluent Form** | <img src="resources/screenshots/demo_14_simplegui_fluent_form_demo.png" width="300" alt="Fluent Form" /> | Fluent declarative builder API with clean chaining and reactive events.<br>`v run demos/14_simplegui_fluent_form_demo.v` |
| **15 - All Controls Showcase** | <img src="resources/screenshots/demo_15_simplegui_all_controls_showcase.png" width="300" alt="All Controls Showcase" /> | Complete catalog of all SimpleGUI controls rendered in Monokai Pro.<br>`v run demos/15_simplegui_all_controls_showcase.v` |
| **16 - Parity API Demo** | <img src="resources/screenshots/demo_16_simplegui_parity_api_demo.png" width="300" alt="Parity API Demo" /> | Named builder methods matching `vlang_simplegui` control signatures.<br>`v run demos/16_simplegui_parity_api_demo.v` |
| **17 - Layout Types Showcase** | <img src="resources/screenshots/demo_17_simplegui_layout_types_showcase.png" width="300" alt="Layout Types" /> | Rows, grids, flex containers, KPI cards, and responsive layouts.<br>`v run demos/17_simplegui_layout_types_showcase.v` |
| **18 - SimpleGUI Ergonomics** | <img src="resources/screenshots/demo_18_simplegui_ergonomics_demo.png" width="300" alt="Ergonomics Demo" /> | Idiomatic V builder syntax with minimum boilerplate code.<br>`v run demos/18_simplegui_ergonomics_demo.v` |
| **19 - State Persistence & Binding** | <img src="resources/screenshots/demo_19_state_persistence_and_binding_demo.png" width="300" alt="State Persistence" /> | Two-way reactive data synchronization with atomic file saving.<br>`v run demos/19_state_persistence_and_binding_demo.v` |
| **20 - CodeFreelance Theme Demo** | <img src="resources/screenshots/demo_20_codefreelance_theme_demo.png" width="300" alt="CodeFreelance Theme" /> | Monokai, Dracula, Tokyo Night, and hacker phosphor theme styling.<br>`v run demos/20_codefreelance_theme_demo.v` |
| **21 - Vlang Parity Controls** | <img src="resources/screenshots/demo_21_vlang_parity_controls_showcase.png" width="300" alt="Vlang Parity Controls" /> | Verification demo testing all visual controls and modifier methods.<br>`v run demos/21_vlang_parity_controls_showcase.v` |
| **22 - Context Menu & Menubar** | <img src="resources/screenshots/demo_22_context_menu_and_menu_demo.png" width="300" alt="Context Menu & Menubar" /> | Custom desktop menubar dropdowns and right-click context menus.<br>`v run demos/22_context_menu_and_menu_demo.v` |
| **23 - 42 All-Themes Showcase** | <img src="resources/screenshots/demo_23_all_themes_all_controls_showcase.png" width="300" alt="42 Themes Showcase" /> | Interactive live switcher across all 42 built-in desktop themes.<br>`v run demos/23_all_themes_all_controls_showcase.v` |
| **24 - DevOps Sentinel Workstation** | <img src="resources/screenshots/demo_24_devops_sentinel_guide.png" width="300" alt="DevOps Sentinel" /> | Production workstation with CPU, RAM, disk, and protected network health.<br>`v run demos/24_devops_sentinel_guide.v` |

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
│   └── theme.v                    # Catalog of 42 desktop form themes
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
├── demos/                         # 23 Interactive Feature Demos
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
│   └── 23_all_themes_all_controls_showcase.v
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
- Linux: `gtk3`, `webkit2gtk-4.1` (or `webkit2gtk-4.0`)
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

# The ultimate 42-theme showcase
v run demos/23_all_themes_all_controls_showcase.v
```

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

---

## 🌐 Other Cross-Platform RAD GUI Projects

These are other projects I like that are cross platform for rad gui development by other people:
- **[pywebview](https://github.com/r0x0r/pywebview)** — Lightweight cross-platform native wrapper around webview components for building desktop GUIs with Python, HTML, CSS, and JavaScript.
- **[neutralinojs](https://github.com/neutralinojs/neutralinojs)** — Portable, lightweight cross-platform desktop application framework that lets you build native desktop apps using web technologies without the overhead of Chromium/Node.js.

---

## 📄 License
MIT License. Created for the Vlang and RAD development community.
