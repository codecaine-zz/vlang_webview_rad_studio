# 🖥️ Enterprise Application Studios Suite (18 Complete Desktop Applications)

Welcome to the **18 Enterprise Desktop Application Studios** included in **V Webview RAD Studio**. 

Every application in this directory is a complete, production-grade workstation built with declarative **SimpleGUI**, native OS Webview, and real system/vlib modules. They are designed for enterprise reliability, high performance, and rapid developer workflows.

Unlike typical web or Electron-based developer tools that consume hundreds of megabytes of RAM and launch slowly, each studio compiles to a lean, lightning-fast native binary that runs in milliseconds with minimal memory footprint (~30–50 MB RAM).

---

## 📑 Application Suite Matrix

| Application | File | Primary Function & Highlights | Quick Run Command |
| :--- | :--- | :--- | :--- |
| **API Studio Pro** | [`api_studio.v`](api_studio.v) | Full-featured REST client (GET/POST/PUT/DELETE/PATCH/HEAD), headers editor, payload editor, cURL export, stopwatch latency, request history. | `v run applications/api_studio.v` |
| **System Studio Pro** | [`system_studio.v`](system_studio.v) | Hardware telemetry dashboard, CPU cores/load averages, RAM utilization, storage partitions, battery sensor, host uptime, specs report copy. | `v run applications/system_studio.v` |
| **Database Studio Pro** | [`database_studio.v`](database_studio.v) | SQLite database workbench (`:memory:` & disk DBs), schema auto-discovery, custom query execution with latency tracking, CSV export. | `v run applications/database_studio.v` |
| **Git Workbench Studio** | [`git_studio.v`](git_studio.v) | Visual Git staging, commit authoring, git stash, pull, push, unified monospace diff viewer, and 15-commit history log. | `v run applications/git_studio.v` |
| **DevTools Studio Pro** | [`devtools_studio.v`](devtools_studio.v) | Casing transforms (camelCase, snake_case, kebab-case, Title Case), slugify, JWT header & payload decoder, Unix epoch ↔ RFC3339 converter. | `v run applications/devtools_studio.v` |
| **Crypto Studio Pro** | [`crypto_studio.v`](crypto_studio.v) | Live SHA-256, SHA-512, MD5, SHA-1, HMAC, Base64/Hex codecs, Shannon entropy calculator, UUID v4 generator, password generator, file checksum verifier. | `v run applications/crypto_studio.v` |
| **Network Studio Pro** | [`network_studio.v`](network_studio.v) | ICMP ping probe (3 packets), DNS resolution (`nslookup`), common port scanner (80, 443, 22, 8080), HTTP health checks, streaming terminal console. | `v run applications/network_studio.v` |
| **Markdown Studio Pro** | [`markdown_studio.v`](markdown_studio.v) | Split-pane editor with live HTML generation, word/character/line counters, reading time estimation, document templates, standalone HTML export. | `v run applications/markdown_studio.v` |
| **JSON Studio Pro** | [`json_studio.v`](json_studio.v) | Real-time syntax validation, key/property filtering, 2-space prettify, minify, document size & parse latency telemetry, structural key breakdown table. | `v run applications/json_studio.v` |
| **Process Studio Pro** | [`process_studio.v`](process_studio.v) | Task manager listing top CPU and top Memory processes, dynamic filter by name or PID, POSIX task signaling (`SIGTERM` & `SIGKILL -9`), inspector console. | `v run applications/process_studio.v` |
| **Advanced Task Manager** | [`task_manager_studio.v`](task_manager_studio.v) | Full OS Activity Monitor & Task Manager: live process table, CPU/RAM/State, POSIX controls (`SIGTERM`, `SIGKILL -9`, `SIGSTOP`, `SIGCONT`), PID inspector, CSV export. | `v run applications/task_manager_studio.v` |
| **Finder & File Explorer** | [`finder_studio.v`](finder_studio.v) | Visual desktop file manager & navigator: breadcrumbs, QuickLook text/code/binary inspector, file operations (mkdir/touch/delete/rename), OS app launcher. | `v run applications/finder_studio.v` |
| **Color Studio Pro** | [`color_studio.v`](color_studio.v) | Exact relative luminance & WCAG 2.1 contrast math against white/black/dark themes (AAA/AA certified), harmonious palette generator, CSS `:root`/Tailwind export. | `v run applications/color_studio.v` |
| **DataConvert Studio** | [`dataconvert_studio.v`](dataconvert_studio.v) | High-speed multi-format transformer: JSON ➔ CSV, CSV ➔ JSON Array, JSON ➔ SQL `INSERT INTO`, CSV ➔ HTML `<table>`, buffer swap, file import/export. | `v run applications/dataconvert_studio.v` |
| **Regex Studio Pro** | [`regex_studio.v`](regex_studio.v) | Live regex compilation, match highlighting with character span offsets, capture group extraction table, presets library, replacement workbench. | `v run applications/regex_studio.v` |
| **App Bundler Studio** | [`app_bundler_studio.v`](app_bundler_studio.v) | Desktop app packager: multi-target compiler (`-prod`, `-g`), complete macOS `.app` bundle generator with `Info.plist` generation, live compiler console. | `v run applications/app_bundler_studio.v` |
| **Environment Studio** | [`env_studio.v`](env_studio.v) | Complete alphabetical environment variable table, search filter, runtime variable setter, `.env` file export/import, system `PATH` directory integrity validator. | `v run applications/env_studio.v` |
| **Watcher Studio Pro** | [`watcher_studio.v`](watcher_studio.v) | Pre-indexed baseline (no false startup events), multi-metric change tracking (`mtime`, `ctime`, `size`), VCS noise exclusion, debounce intervals, dynamic placeholders (`{file}`, `{path}`, `{filename}`, `{event}`, `{dir}`, `{time}`), live console, CSV audit export. | `v run applications/watcher_studio.v` |

---

## 🏛️ Enterprise Design & Architecture Patterns

All 16 studios share a unified set of architectural best practices:

1. **Named Control Binding**: Every dynamic control uses explicit identifiers (e.g. `win.input_named('target_path', ...)` or `win.textarea_named('console', ...)`), allowing clean programmatic state retrieval (`win.get_value('name')`) and reactive UI updates (`win.set_value('name', value)`).
2. **Worker-Thread Concurrency**: Long-running or blocking operations (HTTP requests, file system scans, SQLite queries, shell command executions) run without stalling the native OS Webview event loop.
3. **Anti-Autocorrect Form Inputs**: All text inputs and textareas have `autocapitalize="off" autocorrect="off" autocomplete="off" spellcheck="false"` enforced at the framework level, preventing intrusive OS text alterations when editing paths, code, headers, or commands.
4. **Monospace Live Streaming Consoles**: Output logs and terminal streams feature dedicated monospace styling with automatic scroll-to-bottom behavior (`el.scrollTop = el.scrollHeight`) on new content.
5. **Real OS System Integration**: Studios interact with genuine system capabilities (`vlib/os`, `vlib/net.http`, `vlib/sqlite`, `vlib/crypto`, `system.sys`, `system.stdlib`) rather than mock data.

---

## 🔍 Detailed Studio Walkthroughs

### 1. 🌐 API Studio Pro (`applications/api_studio.v`)
An enterprise REST client and API debugging workbench:
- **HTTP Methods**: Full support for `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, and `HEAD`.
- **Headers Editor**: Multi-line key-value header editor with real-time validation and defaults (`Content-Type`, `Accept`, `Authorization`).
- **Payload Editor**: Multi-line JSON/text request body editor for mutation endpoints.
- **Preset Library**: Instant test presets (JSONPlaceholder Users, Posts, HTTPBin Echo, Mock APIs).
- **Telemetry & History**: Stopwatch latency measurement in milliseconds, HTTP status code pills (green for 2xx, blue for 3xx, yellow for 4xx, red for 5xx), and a timestamped request history table.
- **cURL Export**: Generates and copies full RFC-compliant `curl` command strings directly to the clipboard.

### 2. 👁️ Watcher Studio Pro (`applications/watcher_studio.v`)
A high-frequency file system change monitor and automated task runner:
- **Pre-Indexed Baseline**: Scans and hashes the target directory tree prior to starting the listening loop, preventing false `[CREATED]` notifications on startup.
- **Multi-Metric Tracking**: Monitors file modification time (`mtime`), metadata change time (`ctime`), and byte size (`size`) to catch atomic saves and renames.
- **VCS & Noise Filtering**: Automatically ignores `.git/`, `.DS_Store`, and temporary editor swap files.
- **Command Auto-Execution**: Runs configurable shell commands upon detecting changes.
- **Dynamic Variable Placeholders**:
  - `{file}` / `{path}`: Full absolute path of the modified file.
  - `{filename}`: File basename (e.g. `api_studio.v`).
  - `{event}`: Action performed (`CREATED`, `MODIFIED`, `DELETED`).
  - `{dir}`: Parent directory of the affected file.
  - `{time}`: Timestamp of the modification event.
- **Debounce Selector**: Configurable debounce interval (500ms, 1000ms, 2000ms, 5000ms) to prevent event storming during rapid file writes.
- **Audit Logging**: Export full timestamped file change logs to CSV for compliance audits.

### 3. 🗄️ Database Studio Pro (`applications/database_studio.v`)
An integrated SQLite query and schema inspection workstation:
- **Flexible Connection**: Connect to disk-backed SQLite database files or spawn temporary `:memory:` databases.
- **Schema Auto-Discovery**: Automatically enumerates all database tables, columns, indexes, and row counts via `sqlite_master`.
- **Query Execution Engine**: Runs arbitrary SQL statements (`SELECT`, `INSERT`, `UPDATE`, `CREATE TABLE`, etc.) with sub-millisecond execution stopwatch tracking.
- **Result Grid**: Renders formatted tabular data displays with column headers and row count badges.
- **CSV Data Export**: One-click export of any SQL result set to a standard CSV file.
- **Preset Queries**: Quick-insert buttons for common diagnostic queries (`SELECT *`, `COUNT(*)`, Table Info).

### 4. 🐙 Git Workbench Studio (`applications/git_studio.v`)
A visual Git repository control workstation:
- **Working Tree Telemetry**: Real-time tracking of staged, unstaged, and untracked files via `git status --short`.
- **One-Click Staging**: Stage all files (`git add -A`) or unstage all files (`git reset`) with visual feedback.
- **Commit Workbench**: Custom commit message input with input validation and instant working-tree refresh upon commit.
- **Branch Management**: Inspect current active branch and execute `git pull` or `git push` directly from the UI.
- **Unified Diff Viewer**: Live monospace diff viewer showing file modifications (`git diff`) with line-by-line inspection.
- **Commit History**: Renders the 15 most recent repository commits (`git log --oneline`) with commit hashes, authors, and dates.

### 5. 🛠️ DevTools Studio Pro (`applications/devtools_studio.v`)
A multi-purpose developer omnitool suite:
- **String Transformations**: Instant bi-directional casing conversions across `camelCase`, `snake_case`, `kebab-case`, `Title Case`, `UPPERCASE`, and `lowercase`.
- **URL Slug Generator**: Cleans and converts arbitrary text into SEO-friendly, URL-safe slugs.
- **JWT Token Inspector**: Decodes JSON Web Token (JWT) Header and Payload segments without network transmission, formatting claims and expiration timestamps in clean JSON.
- **Timestamp Converter**: Bi-directional conversion between Unix epoch timestamps (seconds/milliseconds) and human-readable ISO 8601 / RFC3339 strings.
- **Math & Statistics**: Calculates mean, median, min, max, variance, and standard deviation from comma-separated number series.

### 6. 🔐 Crypto Studio Pro (`applications/crypto_studio.v`)
A comprehensive cryptography and data security workbench:
- **Hashing Algorithms**: Real-time generation of SHA-256, SHA-512, MD5, and SHA-1 digests.
- **Message Authentication**: HMAC-SHA256 signature generation with custom user-supplied secret keys.
- **Data Encoders**: High-speed Base64 and Hexadecimal encode/decode tools.
- **Shannon Entropy Analyzer**: Computes Shannon entropy (0.0 to 8.0 bits/byte) to evaluate token unpredictability and password strength.
- **UUID v4 Generator**: Generates cryptographically secure RFC 4122 Version 4 UUIDs.
- **Password Generator**: High-entropy password generator with customizable length, numbers, and special character flags.
- **File Checksum Verifier**: Calculates SHA-256 checksums of local disk files with native file picker integration.

### 7. 📡 Network Studio Pro (`applications/network_studio.v`)
An advanced network diagnostics and connectivity workstation:
- **ICMP Ping Probe**: Sends 3 ping packets to remote hosts or IP addresses, reporting packet loss and round-trip latency statistics (min/avg/max).
- **DNS Lookup Engine**: Queries authoritative name servers (`nslookup` / host lookup) to resolve A, AAAA, and CNAME records.
- **Port Scanner**: Rapid multi-port connectivity check across standard services (HTTP 80, HTTPS 443, SSH 22, Dev 8080, or custom port ranges).
- **HTTP Health Checks**: Validates remote URL endpoints, returning status codes, response times, and server headers.
- **Streaming Terminal Console**: Live monospace console displaying raw network diagnostics with timestamped diagnostic history.

### 8. 📝 Markdown Studio Pro (`applications/markdown_studio.v`)
A split-pane Markdown authoring and HTML publishing studio:
- **Live Split-Pane Preview**: Real-time conversion of Markdown source into styled semantic HTML preview.
- **Document Telemetry**: Word counter, character counter, line counter, and estimated reading time calculator.
- **Templates Library**: One-click boilerplate insertion for Software READMEs, REST API Documentation, and Project Changelogs.
- **HTML Export**: Copy raw HTML to the clipboard or export a standalone, styled HTML document to disk.

### 9. 🔍 JSON Studio Pro (`applications/json_studio.v`)
A high-performance JSON formatting, validation, and querying suite:
- **Syntax Validator**: Real-time validation using `json2`, highlighting syntax error locations and invalid tokens.
- **Prettify & Minify**: Formats messy JSON with 2-space indentation or compacts it into a single-line payload.
- **Key & Property Filter**: Search and extract nested objects, keys, and values by substring or property name.
- **Document Telemetry**: Live byte counter, character length, and parse latency stopwatch.
- **Structural Analysis Table**: Automatically analyzes root object keys, reporting their data types and array lengths.

### 10. ⚡ Process Studio Pro (`applications/process_studio.v`)
A task manager and OS process inspection workstation:
- **Process Listing**: Live monitoring of top processes sorted by CPU utilization and Memory footprint.
- **Dynamic Search Filter**: Instant filtering by process name, binary path, or PID.
- **Task Control**: Send POSIX signals directly to processes:
  - Graceful termination (`SIGTERM`)
  - Forced immediate termination (`SIGKILL -9`)
- **Process Inspector**: Detailed console showing PID, PPID, owning user, memory consumption, CPU load, and full execution command line.

### 11. 🎨 Color Studio Pro (`applications/color_studio.v`)
An accessibility-certified color palette and contrast analyzer:
- **WCAG 2.1 Contrast Math**: Calculates exact relative luminance ($L = 0.2126R + 0.7152G + 0.0722B$) and contrast ratios against Pure White (`#FFFFFF`), Pure Black (`#000000`), and Dark Theme (`#1E1E2E`).
- **Compliance Badges**: Visual indicators for WCAG AA (Normal/Large text) and AAA (Normal/Large text) certification.
- **Harmonious Palettes**: Generates Monochromatic, Complementary, Triadic, and Analogous color harmonies.
- **Code Export**: Exports color tokens directly into CSS custom properties (`:root`), Tailwind CSS configuration objects, or Vlang constant structures.

### 12. 🔄 DataConvert Studio (`applications/dataconvert_studio.v`)
A high-speed multi-format data transformer:
- **Transformation Formats**:
  - JSON Array ➔ Standard CSV
  - Standard CSV ➔ JSON Array of Objects
  - JSON Array ➔ SQL `INSERT INTO` statements
  - Standard CSV ➔ Semantic HTML `<table>` markup
- **Buffer Swap**: One-click swap of output buffer to input buffer for multi-stage conversion pipelines.
- **File I/O**: Direct file import and export with native file dialog integration.
- **Data Metrics**: Live byte count and row/line telemetry cards for both input and output payloads.

### 13. 🎯 Regex Studio Pro (`applications/regex_studio.v`)
A regular expression development and testing studio:
- **Live Engine Compilation**: Compiles and tests expressions against sample text using `vlib/regex`.
- **Match Offsets & Highlighting**: Displays matched segments along with start and end character span offsets.
- **Capture Groups Breakdown**: Dedicated table enumerating all indexed capture groups and their extracted substrings.
- **Pattern Presets**: Quick-load common patterns: Email addresses, HTTP/HTTPS URLs, IPv4 addresses, ISO dates, Hex colors, and phone numbers.
- **Substitution Workbench**: Live regex search-and-replace testing with output preview.

### 14. 📦 App Bundler Studio (`applications/app_bundler_studio.v`)
A desktop application packager and distribution compiler:
- **Target Architectures**: Multi-platform compiler frontend supporting macOS, Linux, and Windows targets.
- **Compilation Modes**: Production optimized release mode (`-prod`), debug symbols (`-g`), and custom compiler flags.
- **macOS `.app` Bundle Generator**: Generates complete application bundles with `Contents/MacOS`, `Info.plist`, and Retina icon integration.
- **Build Console**: Monospace build console streaming compiler standard output, warnings, and error diagnostics.

### 15. 🌲 Environment Studio (`applications/env_studio.v`)
An operating system environment variables and configuration workbench:
- **Alphabetical Variable Table**: Inspect all environment variables currently exposed to the process in an alphabetical grid.
- **Search & Filter**: Search variables by name or value substring.
- **Runtime Variable Setter**: Set and test environment variables for the active session.
- **`.env` File Import/Export**: Import environment variables from `.env` files or export current configurations to disk.
- **`PATH` Integrity Validator**: Validates each directory listed in the system `PATH` variable, flagging non-existent or broken directories.

### 16. 💻 System Studio Pro (`applications/system_studio.v`)
A hardware intelligence and operating system telemetry workstation:
- **KPI Metric Cards**: Real-time cards for CPU Load, Active RAM, Storage Usage, Battery State, and Host Uptime.
- **CPU Metrics**: Core counts, 1/5/15-minute load averages, and processor model identification.
- **RAM Telemetry**: Total, used, and free physical memory metrics with utilization percentages.
- **Disk Partitions**: Storage capacity, used bytes, and free space across all mounted filesystem partitions.
- **System Specs Export**: Formats a complete hardware audit report and copies it to the clipboard.

### 17. ⚡ Advanced Task Manager Studio Enterprise (`applications/task_manager_studio.v`)
An OS Activity Monitor and Task Manager workstation:
- **Full Process Grid**: Real-time process listing with PID, PPID, Owning User, CPU%, MEM%, State, and Command Name.
- **POSIX Signal Controls**: Send `SIGTERM` (graceful exit), `SIGKILL -9` (forced termination), `SIGSTOP` (pause/suspend process), or `SIGCONT` (resume process).
- **Interactive PID Selection**: Click any row in the process table to immediately inspect the process and populate action buttons.
- **Deep Process Inspector**: Monospace console displaying executable binary paths, arguments, environment flags, and process parentage.
- **System Telemetry & Storage Inspector**: Detailed report of CPU cores/load averages, physical RAM in use vs. free, battery power profile, and filesystem disk mounts (`df -h`).
- **CSV Data Exporter**: Export the full process snapshot table to CSV with one click.

### 18. 🗂️ Finder & File Explorer Studio Enterprise (`applications/finder_studio.v`)
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

## 🚀 Building & Packaging Applications

### Running Directly from Source
Any application can be executed directly using the V compiler:
```bash
v run applications/api_studio.v
v run applications/watcher_studio.v
v run applications/database_studio.v
```

### Compiling Standalone Optimized Binaries
To compile a high-performance standalone binary:
```bash
v -prod -o dist/api_studio applications/api_studio.v
```

### Packaging with the Universal Desktop Builder
Use the repository's universal builder script `build.vsh` to generate branded macOS `.app` bundles, Windows executables with resources, or Linux desktop packages:
```bash
# Package a macOS .app bundle with Retina icons and Info.plist
v run build.vsh applications/system_studio.v

# Package any other studio application
v run build.vsh applications/watcher_studio.v
```
The resulting bundles are placed in the `dist/` directory ready for deployment.
