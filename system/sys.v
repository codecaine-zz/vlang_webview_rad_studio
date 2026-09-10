// Module system - Core Operating System & Hardware Integration for RAD Studio
// Ported from simple_gg and vlang_simplegui
// Cross-platform support for macOS, Windows, and Linux.

module system

import os
import time
import net.http
import crypto.sha256
import crypto.md5

// Native C declarations for POSIX system calls and OS system information retrieval
$if macos || linux || freebsd {
	#include <sys/types.h>
	#include <sys/time.h>

	$if macos || freebsd {
		#include <sys/sysctl.h>
		fn C.sysctl(name &int, namelen u32, oldp voidptr, oldlenp &usize, newp voidptr, newlen usize) int
	}

	fn C.getloadavg(loadavg &f64, nelem int) int
}

// =============================================================================
// Data Models & Telemetry Structures
// =============================================================================

pub struct DiskStats {
pub mut:
	total       u64
	available   u64
	used        u64
	total_bytes u64
	free_bytes  u64
	used_bytes  u64
	mount_point string
}

pub struct FileMetadata {
pub mut:
	size          i64
	inode         u64
	nlink         u64
	dev           u64
	uid           u32
	gid           u32
	mode          u32
	atime         i64
	mtime         i64
	ctime         i64
	is_dir        bool
	is_file       bool
	is_link       bool
	is_readable   bool
	is_writable   bool
	is_executable bool
}

pub struct CommandResult {
pub mut:
	command     string
	output      string
	exit_code   int
	timed_out   bool
	duration_ms i64
	attempts    int
	success     bool
}

pub struct HardwareInfo {
pub mut:
	cpu_model        string
	cpu_cores        int
	cpu_arch         string
	cpu_usage        f64
	ram_total_bytes  u64
	ram_free_bytes   u64
	ram_used_bytes   u64
	ram_formatted    string
	os_name          string
	os_version       string
	hostname         string
	uptime_seconds   u64
	battery_percent  int
	battery_charging bool
	ac_connected     bool
	load_avg_1       f64
	load_avg_5       f64
	load_avg_15      f64
}

// =============================================================================
// 1. Process Execution & Shell Commands
// =============================================================================

// exec runs a system command synchronously, returning its trimmed output and exit code.
pub fn exec(command string) (string, int) {
	res := os.execute(command)
	return res.output.trim_space(), res.exit_code
}

// exec_or runs a system command, returning stdout if successful, or the provided fallback.
pub fn exec_or(command string, fallback string) string {
	out, code := exec(command)
	if code == 0 && out.len > 0 {
		return out
	}
	return fallback
}

// exec_bg runs a system command in the background.
pub fn exec_bg(command string) {
	spawn fn (cmd string) {
		os.execute(cmd)
	}(command)
}

// exec_in_dir executes a command synchronously inside a specific working directory.
pub fn exec_in_dir(dir_path string, command string) (string, int) {
	abs_dir := os.real_path(dir_path)
	$if windows {
		return exec('cmd /c "cd /d "${abs_dir}" && ${command}"')
	} $else {
		return exec('cd "${abs_dir}" && ${command}')
	}
}

// exec_cmd executes a command and returns a structured CommandResult including duration.
pub fn exec_cmd(command string) CommandResult {
	sw := time.new_stopwatch()
	out, code := exec(command)
	dur := sw.elapsed().milliseconds()
	return CommandResult{
		command: command
		output: out
		exit_code: code
		timed_out: false
		duration_ms: dur
		attempts: 1
		success: code == 0
	}
}

// get_pid returns the process identifier (PID) of the current running process.
pub fn get_pid() int {
	return os.getpid()
}

// exists_in_path checks whether an executable command binary exists on the system PATH.
pub fn exists_in_path(cmd_name string) bool {
	res := os.find_abs_path_of_executable(cmd_name) or { '' }
	return res != ''
}

// find_executable returns the absolute path of an executable on PATH, or empty string.
pub fn find_executable(cmd_name string) string {
	return os.find_abs_path_of_executable(cmd_name) or { '' }
}

// has_command checks whether a command exists on the PATH.
pub fn has_command(cmd string) bool {
	return exists_in_path(cmd)
}

// get_command_path returns absolute path to executable.
pub fn get_command_path(cmd string) string {
	return find_executable(cmd)
}

// is_process_running checks if any running process matches the given name.
pub fn is_process_running(proc_name string) bool {
	$if windows {
		out, code := exec('tasklist /FI "IMAGENAME eq ${proc_name}*"')
		return code == 0 && out.contains(proc_name)
	} $else {
		_, code := exec('pgrep -f "${proc_name}" 2>/dev/null')
		return code == 0
	}
}

// kill_process terminates processes matching the name.
pub fn kill_process(proc_name string) bool {
	$if windows {
		_, code := exec('taskkill /F /IM "${proc_name}*" /T')
		return code == 0
	} $else {
		_, code := exec('pkill -f "${proc_name}" 2>/dev/null')
		return code == 0
	}
}

// kill_process_by_pid terminates a process using its PID.
pub fn kill_process_by_pid(pid int) bool {
	if pid <= 0 {
		return false
	}
	$if windows {
		_, code := exec('taskkill /F /PID ${pid}')
		return code == 0
	} $else {
		_, code := exec('kill -9 ${pid} 2>/dev/null')
		return code == 0
	}
}

// kill_process_by_name terminates processes matching name.
pub fn kill_process_by_name(proc_name string) bool {
	return kill_process(proc_name)
}

// kill_process_exact terminates a process matching exact executable name.
pub fn kill_process_exact(proc_name string) bool {
	if proc_name.len == 0 {
		return false
	}
	$if windows {
		_, code := exec('taskkill /F /IM "${proc_name}"')
		return code == 0
	} $else {
		_, code := exec('pkill -x "${proc_name}" 2>/dev/null')
		return code == 0
	}
}

// get_running_process_count returns the total count of active processes.
pub fn get_running_process_count() int {
	$if macos || linux || freebsd {
		raw := exec_or('ps -A | wc -l', '0')
		return raw.trim_space().int()
	} $else $if windows {
		raw := exec_or('powershell -Command "(Get-Process).Count"', '0')
		return raw.trim_space().int()
	}
	return 0
}

// get_open_file_count returns the total count of open file descriptors on Unix.
pub fn get_open_file_count() int {
	$if macos {
		raw := exec_or('sysctl -n kern.num_files', '0')
		return raw.trim_space().int()
	} $else $if linux {
		raw := exec_or("cat /proc/sys/fs/file-nr 2>/dev/null | awk '{print \$1}'", '0')
		return raw.trim_space().int()
	}
	return 0
}

// =============================================================================
// 2. Environment Variables & Standard App Directories
// =============================================================================

pub fn get_env(key string) string {
	return os.getenv(key)
}

pub fn set_env(key string, val string) {
	os.setenv(key, val, true)
}

pub fn unset_env(key string) {
	os.unsetenv(key)
}

pub fn get_all_env() map[string]string {
	mut result := map[string]string{}
	vars := os.environ()
	for k, v in vars {
		result[k] = v
	}
	return result
}

// get_user_home_dir returns the current user's home directory across macOS, Windows, and Linux.
pub fn get_user_home_dir() string {
	home := os.home_dir()
	if home != '' {
		return home
	}
	$if windows {
		userprofile := os.getenv('USERPROFILE')
		if userprofile != '' {
			return userprofile
		}
		homedrive := os.getenv('HOMEDRIVE')
		homepath := os.getenv('HOMEPATH')
		if homedrive != '' && homepath != '' {
			return os.join_path(homedrive, homepath)
		}
	} $else {
		env_home := os.getenv('HOME')
		if env_home != '' {
			return env_home
		}
	}
	return '.'
}

// get_app_config_dir returns the recommended application configuration directory for the OS.
// macOS: ~/Library/Application Support/<app_name>
// Windows: %APPDATA%\<app_name>
// Linux: $XDG_CONFIG_HOME/<app_name> (default ~/.config/<app_name>)
pub fn get_app_config_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		home := get_user_home_dir()
		return os.join_path(home, 'Library', 'Application Support', clean_name)
	} $else $if windows {
		appdata := os.getenv('APPDATA')
		if appdata != '' {
			return os.join_path(appdata, clean_name)
		}
		local := os.getenv('LOCALAPPDATA')
		if local != '' {
			return os.join_path(local, clean_name)
		}
		return os.join_path(get_user_home_dir(), 'AppData', 'Roaming', clean_name)
	} $else {
		xdg_config := os.getenv('XDG_CONFIG_HOME')
		if xdg_config != '' {
			return os.join_path(xdg_config, clean_name)
		}
		return os.join_path(get_user_home_dir(), '.config', clean_name)
	}
}

// get_app_data_dir returns the recommended application data directory for the OS.
pub fn get_app_data_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		home := get_user_home_dir()
		return os.join_path(home, 'Library', 'Application Support', clean_name)
	} $else $if windows {
		appdata := os.getenv('APPDATA')
		if appdata != '' {
			return os.join_path(appdata, clean_name)
		}
		local := os.getenv('LOCALAPPDATA')
		if local != '' {
			return os.join_path(local, clean_name)
		}
		return os.join_path(get_user_home_dir(), 'AppData', 'Roaming', clean_name)
	} $else {
		xdg_data := os.getenv('XDG_DATA_HOME')
		if xdg_data != '' {
			return os.join_path(xdg_data, clean_name)
		}
		return os.join_path(get_user_home_dir(), '.local', 'share', clean_name)
	}
}

// get_app_cache_dir returns the recommended cache directory for the OS.
pub fn get_app_cache_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		home := get_user_home_dir()
		return os.join_path(home, 'Library', 'Caches', clean_name)
	} $else $if windows {
		local := os.getenv('LOCALAPPDATA')
		if local != '' {
			return os.join_path(local, clean_name, 'Cache')
		}
		return os.join_path(os.temp_dir(), clean_name)
	} $else {
		xdg_cache := os.getenv('XDG_CACHE_HOME')
		if xdg_cache != '' {
			return os.join_path(xdg_cache, clean_name)
		}
		return os.join_path(get_user_home_dir(), '.cache', clean_name)
	}
}

// get_app_state_dir returns the recommended persistent application state directory for the OS.
pub fn get_app_state_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		home := get_user_home_dir()
		return os.join_path(home, 'Library', 'Application Support', clean_name, 'state')
	} $else $if windows {
		local := os.getenv('LOCALAPPDATA')
		if local != '' {
			return os.join_path(local, clean_name, 'State')
		}
		appdata := os.getenv('APPDATA')
		if appdata != '' {
			return os.join_path(appdata, clean_name, 'State')
		}
		return os.join_path(get_user_home_dir(), 'AppData', 'Local', clean_name, 'State')
	} $else {
		xdg_state := os.getenv('XDG_STATE_HOME')
		if xdg_state != '' {
			return os.join_path(xdg_state, clean_name)
		}
		return os.join_path(get_user_home_dir(), '.local', 'state', clean_name)
	}
}

// get_app_log_dir returns the recommended log directory for the OS.
pub fn get_app_log_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		home := get_user_home_dir()
		return os.join_path(home, 'Library', 'Logs', clean_name)
	} $else $if windows {
		local := os.getenv('LOCALAPPDATA')
		if local != '' {
			return os.join_path(local, clean_name, 'Logs')
		}
		return os.join_path(get_user_home_dir(), 'AppData', 'Local', clean_name, 'Logs')
	} $else {
		xdg_state := os.getenv('XDG_STATE_HOME')
		if xdg_state != '' {
			return os.join_path(xdg_state, clean_name, 'logs')
		}
		return os.join_path(get_user_home_dir(), '.local', 'state', clean_name, 'logs')
	}
}

// get_app_runtime_dir returns the recommended runtime/transient directory for the OS.
pub fn get_app_runtime_dir(app_name string) string {
	clean_name := if app_name.trim_space() != '' { sanitize_filename(app_name.trim_space()) } else { 'rad_studio' }
	$if macos {
		user := os.user_os()
		return os.join_path(os.temp_dir(), '${clean_name}-${user}')
	} $else $if windows {
		return os.join_path(os.temp_dir(), clean_name)
	} $else {
		xdg_runtime := os.getenv('XDG_RUNTIME_DIR')
		if xdg_runtime != '' {
			return os.join_path(xdg_runtime, clean_name)
		}
		return os.join_path(os.temp_dir(), '${clean_name}-${os.getuid()}')
	}
}

pub fn get_app_config_file(app_name string, file_name string) string {
	return os.join_path(get_app_config_dir(app_name), sanitize_filename(file_name))
}

pub fn get_app_state_file(app_name string, file_name string) string {
	return os.join_path(get_app_state_dir(app_name), sanitize_filename(file_name))
}

pub fn get_app_cache_file(app_name string, file_name string) string {
	return os.join_path(get_app_cache_dir(app_name), sanitize_filename(file_name))
}

pub fn get_app_log_file(app_name string, file_name string) string {
	return os.join_path(get_app_log_dir(app_name), sanitize_filename(file_name))
}

// resolve_user_path expands user home tildes (~), environment variables, and normalizes separators.
pub fn resolve_user_path(raw_path string) string {
	trimmed := raw_path.trim_space()
	if trimmed == '' {
		return ''
	}
	mut p := trimmed

	// Expand ${VAR}
	for p.contains(r'${') {
		start := p.index(r'${') or { break }
		end := p.index_after(r'}', start) or { break }
		var_name := p[start + 2..end]
		env_val := os.getenv(var_name)
		p = p[..start] + env_val + p[end + 1..]
	}

	// Expand %VAR%
	if p.contains('%') {
		parts := p.split('%')
		if parts.len >= 3 {
			mut sb := []string{}
			mut i := 0
			for i < parts.len {
				if i + 1 < parts.len && i % 2 == 1 {
					var_name := parts[i]
					env_val := os.getenv(var_name)
					sb << env_val
				} else {
					sb << parts[i]
				}
				i++
			}
			p = sb.join('')
		}
	}

	// Expand $VAR
	if p.contains('$') {
		mut res := []u8{cap: p.len}
		mut i := 0
		bytes := p.bytes()
		for i < bytes.len {
			if bytes[i] == `$` && i + 1 < bytes.len && (bytes[i + 1].is_letter() || bytes[i + 1] == `_`) {
				mut j := i + 1
				for j < bytes.len && (bytes[j].is_letter() || bytes[j].is_digit() || bytes[j] == `_`) {
					j++
				}
				var_name := p[i + 1..j]
				env_val := os.getenv(var_name)
				for b in env_val.bytes() {
					res << b
				}
				i = j
			} else {
				res << bytes[i]
				i++
			}
		}
		p = res.bytestr()
	}

	// Expand tildes
	home := get_user_home_dir()
	if p == '~' {
		p = home
	} else if p.starts_with('~/') || p.starts_with('~\\') {
		p = os.join_path(home, p[2..])
	}

	// Normalize separators
	$if windows {
		p = p.replace('/', '\\')
	} $else {
		p = p.replace('\\', '/')
	}

	return p
}

pub fn expand_user_path(raw_path string) string {
	return resolve_user_path(raw_path)
}

pub fn get_system_path(name string) string {
	home := get_user_home_dir()
	return match name.to_lower() {
		'home' { home }
		'temp', 'tmp' { os.temp_dir() }
		'desktop' { os.join_path(home, 'Desktop') }
		'documents' { os.join_path(home, 'Documents') }
		'downloads' { os.join_path(home, 'Downloads') }
		'cache' { os.cache_dir() }
		'config' { os.config_dir() or { os.join_path(home, '.config') } }
		'data' { os.data_dir() }
		'state' {
			$if macos {
				os.join_path(home, 'Library', 'Application Support')
			} $else $if windows {
				env := os.getenv('LOCALAPPDATA')
				if env != '' { env } else { os.join_path(home, 'AppData', 'Local') }
			} $else {
				env := os.getenv('XDG_STATE_HOME')
				if env != '' { env } else { os.join_path(home, '.local', 'state') }
			}
		}
		'logs' {
			$if macos {
				os.join_path(home, 'Library', 'Logs')
			} $else $if windows {
				env := os.getenv('LOCALAPPDATA')
				if env != '' { os.join_path(env, 'Logs') } else { os.join_path(home, 'AppData', 'Local', 'Logs') }
			} $else {
				env := os.getenv('XDG_STATE_HOME')
				if env != '' { os.join_path(env, 'logs') } else { os.join_path(home, '.local', 'state', 'logs') }
			}
		}
		'app' { os.dir(os.executable()) }
		else { home }
	}
}

// =============================================================================
// 3. File System Utilities
// =============================================================================

pub fn file_exists(path string) bool {
	return os.exists(resolve_user_path(path))
}

pub fn is_dir(path string) bool {
	return os.is_dir(resolve_user_path(path))
}

pub fn read_file_opt(path string) !string {
	resolved := resolve_user_path(path)
	if !os.exists(resolved) {
		return error('File does not exist: ' + resolved)
	}
	return os.read_file(resolved)!
}

pub fn read_file(path string) string {
	res := read_file_opt(path) or { return '' }
	return res
}

pub fn write_file_opt(path string, content string) ! {
	resolved := resolve_user_path(path)
	parent := os.dir(resolved)
	if parent != '' && !os.exists(parent) {
		os.mkdir_all(parent)!
	}
	os.write_file(resolved, content)!
}

pub fn write_file(path string, content string) {
	write_file_opt(path, content) or {}
}

pub fn delete_file(path string) {
	resolved := resolve_user_path(path)
	os.rm(resolved) or {}
}

pub fn create_directory(path string) {
	resolved := resolve_user_path(path)
	os.mkdir_all(resolved) or {}
}

pub fn read_dir(path string) []string {
	resolved := resolve_user_path(path)
	return os.ls(resolved) or { []string{} }
}

pub fn append_file(path string, content string) ! {
	resolved := resolve_user_path(path)
	mut f := os.open_append(resolved)!
	defer { f.close() }
	f.write_string(content)!
}

pub fn touch_file(path string) ! {
	resolved := resolve_user_path(path)
	if !os.exists(resolved) {
		os.write_file(resolved, '')!
	} else {
		$if windows {
			exec('powershell -Command "(Get-Item \'${resolved}\').LastWriteTime = Get-Date"')
		} $else {
			exec('touch "${resolved}"')
		}
	}
}

pub fn get_directory_size(path string) u64 {
	resolved := resolve_user_path(path)
	if !os.exists(resolved) || !os.is_dir(resolved) {
		return 0
	}
	mut total_bytes := u64(0)
	files := os.walk_ext(resolved, '')
	for f in files {
		if os.is_file(f) {
			st := os.stat(f) or { continue }
			total_bytes += u64(st.size)
		}
	}
	return total_bytes
}

pub fn trash_file(path string) ! {
	abs_path := os.real_path(resolve_user_path(path))
	if !os.exists(abs_path) {
		return error('File does not exist: ${path}')
	}
	$if macos {
		escaped := abs_path.replace('"', '\\"')
		script := "osascript -e 'tell application \"Finder\" to delete POSIX file \"${escaped}\"'"
		out, code := exec(script)
		if code != 0 {
			return error('Failed to move to Trash: ${out}')
		}
	} $else $if windows {
		p_esc := abs_path.replace("'", "''")
		cmd := "powershell -Command \"Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('${p_esc}', 'OnlyErrorDialogs', 'SendToRecycleBin')\""
		out, code := exec(cmd)
		if code != 0 {
			return error('Failed to move to Recycle Bin: ${out}')
		}
	} $else {
		out, code := exec('gio trash "${abs_path}" 2>/dev/null || trash-put "${abs_path}" 2>/dev/null')
		if code != 0 {
			return error('Failed to move file to trash: ${out}')
		}
	}
}

pub fn zip_directory(dir_path string, zip_path string) ! {
	abs_dir := os.real_path(resolve_user_path(dir_path))
	if !os.exists(abs_dir) {
		return error('Source directory does not exist: ${dir_path}')
	}
	parent := os.dir(abs_dir)
	base := os.base(abs_dir)
	target_zip := resolve_user_path(zip_path)
	$if windows {
		out, code := exec('powershell -Command "Compress-Archive -Path \'${abs_dir}\' -DestinationPath \'${target_zip}\' -Force"')
		if code != 0 {
			return error('Failed to create zip archive: ${out}')
		}
	} $else {
		out, code := exec('cd "${parent}" && zip -r "${target_zip}" "${base}"')
		if code != 0 {
			return error('Failed to create zip archive: ${out}')
		}
	}
}

pub fn unzip_archive(zip_path string, dest_dir string) ! {
	abs_zip := os.real_path(resolve_user_path(zip_path))
	if !os.exists(abs_zip) {
		return error('Zip archive does not exist: ${zip_path}')
	}
	abs_dest := resolve_user_path(dest_dir)
	os.mkdir_all(abs_dest)!
	$if windows {
		out, code := exec('powershell -Command "Expand-Archive -Path \'${abs_zip}\' -DestinationPath \'${abs_dest}\' -Force"')
		if code != 0 {
			return error('Failed to extract zip archive: ${out}')
		}
	} $else {
		out, code := exec('unzip -o "${abs_zip}" -d "${abs_dest}"')
		if code != 0 {
			return error('Failed to extract zip archive: ${out}')
		}
	}
}

pub fn create_temp_file(prefix string, suffix string) !string {
	rand_num := time.now().unix_milli()
	file_name := '${prefix}_${rand_num}${suffix}'
	temp_path := os.join_path(os.temp_dir(), file_name)
	os.write_file(temp_path, '')!
	return temp_path
}

pub fn create_temp_dir(prefix string) !string {
	rand_num := time.now().unix_milli()
	dir_name := '${prefix}_${rand_num}'
	temp_path := os.join_path(os.temp_dir(), dir_name)
	os.mkdir_all(temp_path)!
	return temp_path
}

pub fn sha256_file(path string) !string {
	bytes := os.read_bytes(resolve_user_path(path))!
	return sha256.hexhash(bytes.bytestr())
}

pub fn md5_file(path string) !string {
	bytes := os.read_bytes(resolve_user_path(path))!
	return md5.hexhash(bytes.bytestr())
}

pub fn get_file_metadata(path string) !FileMetadata {
	clean := resolve_user_path(path)
	if !os.exists(clean) {
		return error('Path does not exist: ${clean}')
	}
	st := os.stat(clean)!
	return FileMetadata{
		size: i64(st.size)
		inode: u64(st.inode)
		nlink: 1
		dev: 0
		uid: 0
		gid: 0
		mode: u32(st.mode)
		atime: i64(st.atime)
		mtime: i64(st.mtime)
		ctime: i64(st.ctime)
		is_dir: os.is_dir(clean)
		is_file: os.is_file(clean)
		is_link: os.is_link(clean)
		is_readable: os.is_readable(clean)
		is_writable: os.is_writable(clean)
		is_executable: os.is_executable(clean)
	}
}

pub fn get_disk_usage(path string) !DiskStats {
	target_path := if path.len == 0 { '.' } else { resolve_user_path(path) }
	if !os.exists(target_path) {
		return error('Path does not exist: ${target_path}')
	}
	$if macos || linux || freebsd {
		out := exec_or("df -k \"${target_path}\" | tail -n 1 | awk '{print \$2\" \"\$4\" \"\$3}'", '')
		lines := out.split_into_lines()
		if lines.len > 0 {
			parts := lines[0].split(' ').filter(it.len > 0)
			if parts.len >= 3 {
				total_kb := parts[0].u64()
				avail_kb := parts[1].u64()
				used_kb := parts[2].u64()
				return DiskStats{
					total: total_kb * 1024
					available: avail_kb * 1024
					used: used_kb * 1024
					total_bytes: total_kb * 1024
					free_bytes: avail_kb * 1024
					used_bytes: used_kb * 1024
					mount_point: target_path
				}
			}
		}
	} $else $if windows {
		raw := exec_or("powershell -Command \"Get-Volume -FilePath '${target_path}' | Select-Object Size, SizeRemaining\"", '')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			parts := lines[1].trim_space().split(' ').filter(it.len > 0)
			if parts.len >= 2 {
				sz := parts[0].u64()
				rem := parts[1].u64()
				used_val := if sz >= rem { sz - rem } else { u64(0) }
				return DiskStats{
					total: sz
					available: rem
					used: used_val
					total_bytes: sz
					free_bytes: rem
					used_bytes: used_val
					mount_point: target_path
				}
			}
		}
	}
	return get_disk_info(target_path)
}

// =============================================================================
// 4. Desktop Notifications, Alerts & Dialogs
// =============================================================================

pub fn show_notification(title string, message string) {
	$if macos {
		title_escaped := title.replace('"', '\\"')
		msg_escaped := message.replace('"', '\\"')
		cmd := "osascript -e 'display notification \"${msg_escaped}\" with title \"${title_escaped}\"'"
		exec_bg(cmd)
	} $else $if windows {
		title_esc := title.replace("'", "''")
		msg_esc := message.replace("'", "''")
		cmd := "powershell -Command \"[reflection.assembly]::loadwithpartialname('System.Windows.Forms'); \$n = new-object system.windows.forms.notifyicon; \$n.icon = [system.drawing.systemicons]::information; \$n.visible = \$true; \$n.showballoontip(0, '${title_esc}', '${msg_esc}', [system.windows.forms.tooltipicon]::info)\""
		exec_bg(cmd)
	} $else {
		linux_cmds := [
			"notify-send \"${title}\" \"${message}\" 2>/dev/null",
			"kdialog --title \"${title}\" --passivepopup \"${message}\" 2>/dev/null",
			"zenity --notification --window-icon=info --text=\"${message}\" 2>/dev/null",
		]
		for cmd in linux_cmds {
			bin := cmd.split(' ')[0]
			if os.find_abs_path_of_executable(bin) or { '' } != '' {
				exec_bg(cmd)
				return
			}
		}
	}
}

pub fn show_system_notification(title string, message string) {
	show_notification(title, message)
}

pub fn show_alert(title string, message string) {
	$if macos {
		t_esc := title.replace('"', '\\"')
		m_esc := message.replace('"', '\\"')
		cmd := "osascript -e 'display alert \"${t_esc}\" message \"${m_esc}\"'"
		exec(cmd)
	} $else $if windows {
		t_esc := title.replace("'", "''")
		m_esc := message.replace("'", "''")
		cmd := "powershell -Command \"[System.Windows.Forms.MessageBox]::Show('${m_esc}', '${t_esc}')\""
		exec(cmd)
	} $else {
		exec("zenity --info --title=\"${title}\" --text=\"${message}\" 2>/dev/null || xmessage -center \"${title}: ${message}\" 2>/dev/null")
	}
}

pub fn show_confirm(title string, message string) bool {
	$if macos {
		t_esc := title.replace('"', '\\"')
		m_esc := message.replace('"', '\\"')
		cmd := "osascript -e 'display dialog \"${m_esc}\" with title \"${t_esc}\" buttons {\"Cancel\", \"OK\"} default button \"OK\"'"
		res, code := exec(cmd)
		return code == 0 && res.contains('OK')
	} $else $if windows {
		t_esc := title.replace("'", "''")
		m_esc := message.replace("'", "''")
		cmd := "powershell -Command \"if ([System.Windows.Forms.MessageBox]::Show('${m_esc}', '${t_esc}', [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq [System.Windows.Forms.DialogResult]::OK) { exit 0 } else { exit 1 }\""
		_, code := exec(cmd)
		return code == 0
	} $else {
		_, code := exec("zenity --question --title=\"${title}\" --text=\"${message}\" 2>/dev/null")
		return code == 0
	}
}

pub fn osascript_dialog(prompt string, default_value string) string {
	$if macos {
		p_esc := prompt.replace('"', '\\"')
		d_esc := default_value.replace('"', '\\"')
		cmd := 'osascript -e \'set ans to text returned of (display dialog "${p_esc}" default answer "${d_esc}" buttons {"Cancel","OK"} default button "OK")\''
		out, code := exec(cmd)
		return if code == 0 { out.trim_space() } else { '' }
	} $else $if windows {
		p_esc := prompt.replace("'", "''")
		d_esc := default_value.replace("'", "''")
		cmd := "powershell -Command \"Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::InputBox('${p_esc}', 'Input', '${d_esc}')\""
		out, code := exec(cmd)
		return if code == 0 { out.trim_space() } else { '' }
	} $else {
		out, code := exec('zenity --entry --title="Input" --text="${prompt}" --entry-text="${default_value}" 2>/dev/null')
		return if code == 0 { out.trim_space() } else { '' }
	}
}

pub fn osascript_alert(title string, message string) bool {
	return show_confirm(title, message)
}

pub fn osascript_choose_file() string {
	return open_file_dialog('Select File', '*')
}

pub fn osascript_choose_folder() string {
	return select_folder_dialog('Select Folder')
}

pub fn open_file_dialog(prompt string, file_types string) string {
	$if macos {
		mut type_clause := ''
		if file_types != '' && file_types != '*' && file_types != '*.*' {
			types := file_types.replace('.', '').split(',')
			mut parts := []string{}
			for t in types {
				parts << '"${t.trim_space()}"'
			}
			type_clause = 'of type {${parts.join(', ')}}'
		}
		p_esc := prompt.replace('"', '\\"')
		cmd := 'osascript -e \'POSIX path of (choose file ${type_clause} with prompt "${p_esc}")\''
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else $if windows {
		cmd := 'powershell -Command "Add-Type -AssemblyName System.Windows.Forms; \$f = New-Object System.Windows.Forms.OpenFileDialog; \$f.Title = \'${prompt}\'; if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output \$f.FileName }"'
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else {
		res, code := exec('zenity --file-selection --title="${prompt}" 2>/dev/null')
		return if code == 0 { res.trim_space() } else { '' }
	}
}

pub fn save_file_dialog(prompt string, default_name string) string {
	$if macos {
		p_esc := prompt.replace('"', '\\"')
		d_esc := default_name.replace('"', '\\"')
		cmd := 'osascript -e \'POSIX path of (choose file name with prompt "${p_esc}" default name "${d_esc}")\''
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else $if windows {
		cmd := 'powershell -Command "Add-Type -AssemblyName System.Windows.Forms; \$f = New-Object System.Windows.Forms.SaveFileDialog; \$f.Title = \'${prompt}\'; \$f.FileName = \'${default_name}\'; if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output \$f.FileName }"'
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else {
		res, code := exec('zenity --file-selection --save --confirm-overwrite --title="${prompt}" --filename="${default_name}" 2>/dev/null')
		return if code == 0 { res.trim_space() } else { '' }
	}
}

pub fn select_folder_dialog(prompt string) string {
	$if macos {
		p_esc := prompt.replace('"', '\\"')
		cmd := 'osascript -e \'POSIX path of (choose folder with prompt "${p_esc}")\''
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else $if windows {
		cmd := 'powershell -Command "Add-Type -AssemblyName System.Windows.Forms; \$f = New-Object System.Windows.Forms.FolderBrowserDialog; \$f.Description = \'${prompt}\'; if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output \$f.SelectedPath }"'
		res, code := exec(cmd)
		return if code == 0 { res.trim_space() } else { '' }
	} $else {
		res, code := exec('zenity --file-selection --directory --title="${prompt}" 2>/dev/null')
		return if code == 0 { res.trim_space() } else { '' }
	}
}

// =============================================================================
// 5. Native Clipboard & Desktop Window Integration
// =============================================================================

pub fn get_clipboard_text() string {
	$if macos {
		return exec_or('pbpaste', '')
	} $else $if windows {
		return exec_or('powershell -Command "Get-Clipboard"', '')
	} $else {
		return exec_or('xclip -selection clipboard -o 2>/dev/null || xsel --clipboard --output 2>/dev/null', '')
	}
}

pub fn set_clipboard_text(text string) {
	$if macos {
		mut p := os.new_process('/usr/bin/pbcopy')
		p.set_redirect_stdio()
		p.run()
		p.stdin_write(text)
		p.close()
		p.wait()
	} $else $if windows {
		esc := text.replace("'", "''")
		exec("powershell -Command \"Set-Clipboard -Value '${esc}'\"")
	} $else {
		mut p := os.new_process('xclip')
		p.set_args(['-selection', 'clipboard'])
		p.set_redirect_stdio()
		p.run()
		p.stdin_write(text)
		p.close()
		p.wait()
	}
}

pub fn copy_to_clipboard(text string) {
	set_clipboard_text(text)
}

pub fn open_url(url string) {
	$if macos {
		exec_bg("open \"${url}\"")
	} $else $if windows {
		exec_bg("start \"${url}\"")
	} $else {
		exec_bg("xdg-open \"${url}\" 2>/dev/null")
	}
}

pub fn reveal_in_finder(path string) {
	abs := os.real_path(resolve_user_path(path))
	$if macos {
		exec_bg('open -R "${abs}"')
	} $else $if windows {
		exec_bg('explorer.exe /select,"${abs}"')
	} $else {
		exec_bg('xdg-open "${os.dir(abs)}" 2>/dev/null')
	}
}

pub fn open_in_default_app(path string) {
	abs := os.real_path(resolve_user_path(path))
	$if macos {
		exec_bg('open "${abs}"')
	} $else $if windows {
		exec_bg('start "" "${abs}"')
	} $else {
		exec_bg('xdg-open "${abs}" 2>/dev/null')
	}
}

pub fn open_with_app(path string, app_id string) {
	abs := os.real_path(resolve_user_path(path))
	$if macos {
		exec_bg('open -a "${app_id}" "${abs}"')
	} $else {
		exec_bg('${app_id} "${abs}"')
	}
}

pub fn open_terminal() {
	$if macos {
		exec_bg('open -a Terminal .')
	} $else $if windows {
		exec_bg('start cmd.exe')
	} $else {
		exec_bg('x-terminal-emulator 2>/dev/null || gnome-terminal 2>/dev/null || konsole 2>/dev/null || xterm &')
	}
}

// =============================================================================
// 6. Hardware Intelligence & System Telemetry
// =============================================================================

pub fn get_cpu_info() string {
	$if macos {
		return exec_or('sysctl -n machdep.cpu.brand_string', 'Apple Silicon / Intel')
	} $else $if windows {
		raw := exec_or('wmic cpu get name', '')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			return lines[1].trim_space()
		}
		return 'Windows CPU'
	} $else {
		raw := exec_or("grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2", '')
		if raw.len > 0 {
			return raw.trim_space()
		}
		return 'Linux CPU'
	}
}

pub fn get_cpu_cores() int {
	$if macos {
		cores_str := exec_or('sysctl -n hw.ncpu', '0')
		return cores_str.int()
	} $else $if windows {
		raw := exec_or('wmic cpu get NumberOfCores', '1')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			return lines[1].trim_space().int()
		}
		return 1
	} $else {
		raw := exec_or('nproc 2>/dev/null', '1')
		return raw.trim_space().int()
	}
}

pub fn get_cpu_architecture() string {
	$if arm64 {
		return 'arm64'
	} $else $if amd64 {
		return 'x86_64'
	} $else {
		return 'arm64'
	}
}

pub fn get_cpu_usage() f64 {
	$if macos {
		raw := exec_or("top -l 1 -n 0 | grep 'CPU usage' | awk '{print \$3}' | tr -d '%'", '0')
		return raw.f64()
	} $else $if windows {
		raw := exec_or('wmic cpu get loadpercentage', '0')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			return lines[1].trim_space().f64()
		}
		return 0.0
	} $else {
		raw := exec_or("top -bn1 | grep 'Cpu(s)' | awk '{print \$2 + \$4}'", '0')
		return raw.f64()
	}
}

pub fn get_cpu_usage_percent() f64 {
	return get_cpu_usage()
}

pub fn get_memory_info() (u64, u64, u64) {
	mut total := u64(0)
	mut free := u64(0)
	mut used := u64(0)

	$if macos {
		bytes_str := exec_or('sysctl -n hw.memsize', '0')
		total = bytes_str.u64()
		vm := exec_or('vm_stat', '')
		mut free_pages := u64(0)
		for line in vm.split_into_lines() {
			if line.contains('Pages free:') {
				parts := line.split(':')
				if parts.len >= 2 {
					free_pages += parts[1].trim_space().trim_right('.').u64()
				}
			} else if line.contains('Pages speculative:') {
				parts := line.split(':')
				if parts.len >= 2 {
					free_pages += parts[1].trim_space().trim_right('.').u64()
				}
			}
		}
		free = free_pages * 4096
		if free > total { free = total / 4 }
		used = if total >= free { total - free } else { 0 }
	} $else $if windows {
		raw := exec_or('wmic computersystem get TotalPhysicalMemory', '0')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			total = lines[1].trim_space().u64()
		}
		free_raw := exec_or('wmic os get FreePhysicalMemory', '0')
		free_lines := free_raw.split_into_lines()
		if free_lines.len >= 2 {
			free = free_lines[1].trim_space().u64() * 1024
		}
		used = if total >= free { total - free } else { 0 }
	} $else {
		mem := exec_or('cat /proc/meminfo 2>/dev/null', '')
		for line in mem.split_into_lines() {
			if line.starts_with('MemTotal:') {
				parts := line.split_into_lines()
				for p in parts {
					tokens := p.split(' ')
					for tok in tokens {
						if tok.u64() > 0 { total = tok.u64() * 1024; break }
					}
				}
			} else if line.starts_with('MemAvailable:') {
				tokens := line.split(' ')
				for tok in tokens {
					if tok.u64() > 0 { free = tok.u64() * 1024; break }
				}
			}
		}
		used = if total >= free { total - free } else { 0 }
	}

	return total, free, used
}

pub fn get_memory_pressure() string {
	$if macos {
		level := exec_or('sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null', '').trim_space().int()
		if level >= 4 { return 'critical' } else if level >= 2 { return 'warn' } else if level == 1 { return 'normal' }
	}
	return 'normal'
}

pub fn get_swap_usage() string {
	$if macos {
		return exec_or('sysctl -n vm.swapusage', 'unknown').trim_space()
	} $else $if windows {
		return exec_or('powershell -Command "(Get-CimInstance Win32_PageFileUsage).AllocatedBaseSize | % { \"$_ MB\" }"', 'unknown').trim_space()
	} $else {
		return exec_or("free -h 2>/dev/null | grep Swap | awk '{print \$3\" / \"\$2}'", 'unknown').trim_space()
	}
}

pub fn format_bytes(bytes u64) string {
	if bytes >= 1024 * 1024 * 1024 {
		gb := f64(bytes) / (1024.0 * 1024.0 * 1024.0)
		return '${gb:.2f} GB'
	} else if bytes >= 1024 * 1024 {
		mb := f64(bytes) / (1024.0 * 1024.0)
		return '${mb:.2f} MB'
	} else if bytes >= 1024 {
		kb := f64(bytes) / 1024.0
		return '${kb:.2f} KB'
	}
	return '${bytes} B'
}

pub fn get_disk_info(mount_point string) DiskStats {
	path := if mount_point != '' { mount_point } else { '/' }
	$if macos || linux {
		raw := exec_or("df -k '${path}' | tail -1 | awk '{print \$2, \$3, \$4}'", '0 0 0')
		parts := raw.split(' ')
		if parts.len >= 3 {
			total := parts[0].u64() * 1024
			used := parts[1].u64() * 1024
			free := parts[2].u64() * 1024
			return DiskStats{
				total: total
				available: free
				used: used
				total_bytes: total
				free_bytes: free
				used_bytes: used
				mount_point: path
			}
		}
	} $else $if windows {
		raw := exec_or('wmic logicaldisk where "DeviceID=\'C:\'" get Size,FreeSpace', '')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			fields := lines[1].split_into_lines()
			for f in fields {
				nums := f.split(' ')
				mut valid := []u64{}
				for n in nums {
					if n.u64() > 0 { valid << n.u64() }
				}
				if valid.len >= 2 {
					free := valid[0]
					total := valid[1]
					used := if total >= free { total - free } else { 0 }
					return DiskStats{
						total: total
						available: free
						used: used
						total_bytes: total
						free_bytes: free
						used_bytes: used
						mount_point: 'C:'
					}
				}
			}
		}
	}
	return DiskStats{
		total: 512 * 1024 * 1024 * 1024
		available: 256 * 1024 * 1024 * 1024
		used: 256 * 1024 * 1024 * 1024
		total_bytes: 512 * 1024 * 1024 * 1024
		free_bytes: 256 * 1024 * 1024 * 1024
		used_bytes: 256 * 1024 * 1024 * 1024
		mount_point: path
	}
}

pub fn get_load_average() (f64, f64, f64) {
	$if macos || linux {
		mut load := [3]f64{}
		res := C.getloadavg(&load[0], 3)
		if res >= 3 {
			return load[0], load[1], load[2]
		}
	}
	return 0.5, 0.5, 0.5
}

pub fn get_uptime() u64 {
	$if macos {
		raw := exec_or('sysctl -n kern.boottime', '')
		if raw.contains('sec = ') {
			idx := raw.index('sec = ') or { 0 }
			sub := raw[idx + 6..]
			end := sub.index(',') or { sub.len }
			boot_sec := sub[..end].u64()
			now_sec := u64(time.now().unix())
			if now_sec > boot_sec {
				return now_sec - boot_sec
			}
		}
	} $else $if linux {
		raw := exec_or("cat /proc/uptime 2>/dev/null | awk '{print \$1}'", '0')
		return u64(raw.f64())
	}
	return 3600
}

pub fn get_uptime_seconds() i64 {
	return i64(get_uptime())
}

pub fn get_battery_info() (int, bool, bool) {
	$if macos {
		raw := exec_or('pmset -g batt', '')
		mut percent := 100
		mut charging := false
		mut ac := false
		if raw.contains('AC Power') { ac = true }
		if raw.contains(';') {
			for part in raw.split(';') {
				if part.contains('%') {
					idx := part.index('%') or { 0 }
					mut start := idx - 1
					for start >= 0 && part[start].is_digit() { start-- }
					percent = part[start + 1..idx].int()
				}
				if part.contains('charging') && !part.contains('discharging') {
					charging = true
				}
			}
		}
		return percent, charging, ac
	} $else {
		return 100, false, true
	}
}

pub fn get_battery_percent() int {
	pct, _, _ := get_battery_info()
	return pct
}

pub fn is_on_ac_power() bool {
	_, _, ac := get_battery_info()
	return ac
}

pub fn get_os_info() (string, string, string) {
	$if macos {
		ver := exec_or('sw_vers -productVersion', 'macOS')
		return 'macOS', ver, get_cpu_architecture()
	} $else $if windows {
		ver := exec_or('powershell -Command "(Get-CimInstance Win32_OperatingSystem).Caption"', 'Windows')
		return 'Windows', ver, get_cpu_architecture()
	} $else {
		ver := exec_or('uname -r', 'Linux')
		return 'Linux', ver, get_cpu_architecture()
	}
}

pub fn get_hostname() string {
	return 'workstation.local'
}

pub fn get_hostname_raw() string {
	return os.hostname() or { 'localhost' }
}

fn system_version_plist_value(key string) string {
	$if macos {
		plist_path := '/System/Library/CoreServices/SystemVersion.plist'
		content := os.read_file(plist_path) or { return 'unknown' }
		key_tag := '<key>${key}</key>'
		key_idx := content.index(key_tag) or { return 'unknown' }
		after_key := content[key_idx + key_tag.len..]
		val_start_tag := '<string>'
		val_end_tag := '</string>'
		val_start := after_key.index(val_start_tag) or { return 'unknown' }
		after_start := after_key[val_start + val_start_tag.len..]
		val_end := after_start.index(val_end_tag) or { return 'unknown' }
		return after_start[..val_end].trim_space()
	} $else {
		return 'N/A'
	}
}

pub fn get_macos_version() string {
	return system_version_plist_value('ProductVersion')
}

pub fn get_macos_build() string {
	return system_version_plist_value('ProductBuildVersion')
}

pub fn get_macos_product_name() string {
	return system_version_plist_value('ProductName')
}

pub fn get_device_model() string {
	$if macos {
		return exec_or('sysctl -n hw.model', 'unknown').trim_space()
	} $else $if windows {
		return exec_or('wmic computersystem get model', 'unknown').split_into_lines()[1].trim_space()
	} $else {
		return exec_or('cat /sys/class/dmi/id/product_name 2>/dev/null', 'unknown').trim_space()
	}
}

pub fn get_serial_number() string {
	$if macos {
		return exec_or('ioreg -c IOPlatformExpertDevice 2>/dev/null | awk -F \'"\' \'/IOPlatformSerialNumber/{print $4}\'', 'unavailable').trim_space()
	} $else $if windows {
		return exec_or('wmic bios get serialnumber', 'unavailable').split_into_lines()[1].trim_space()
	} $else {
		return exec_or('cat /sys/class/dmi/id/product_serial 2>/dev/null', 'unavailable').trim_space()
	}
}

pub fn get_screen_resolution() string {
	$if macos {
		raw := exec_or('osascript -e \'tell application "Finder" to get bounds of window of desktop\' 2>/dev/null', '')
		if raw.len > 0 {
			parts := raw.split(',').map(it.trim_space())
			if parts.len >= 4 {
				return '${parts[2]} x ${parts[3]}'
			}
		}
	} $else $if windows {
		raw := exec_or('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width.ToString() + \' x \' + [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height.ToString()"', '')
		if raw.len > 0 {
			return raw.trim_space()
		}
	} $else {
		raw := exec_or("xrandr --current 2>/dev/null | grep '\\*' | awk '{print \$1}'", '')
		if raw.len > 0 {
			return raw.split_into_lines()[0].trim_space()
		}
	}
	return '1920 x 1080'
}

pub fn get_gpu_info() string {
	$if macos {
		ioreg_gpu := exec_or('ioreg -rc IOPCIDevice 2>/dev/null | awk -F \'"\' \'/"model" = /{print \$4}\' | head -1', '').trim_space()
		if ioreg_gpu.len > 0 {
			return ioreg_gpu
		}
	} $else $if windows {
		raw := exec_or('wmic path win32_VideoController get name', '')
		lines := raw.split_into_lines()
		if lines.len >= 2 {
			return lines[1].trim_space()
		}
	} $else {
		raw := exec_or("lspci 2>/dev/null | grep -i vga | cut -d: -f3", '')
		if raw.len > 0 {
			return raw.trim_space()
		}
	}
	return 'unknown'
}

pub fn get_app_bundle_id() string {
	$if macos {
		exe := os.executable()
		plist_path := os.join_path(os.dir(exe), '..', 'Info.plist')
		if os.exists(plist_path) {
			content := os.read_file(plist_path) or { return '' }
			key_tag := '<key>CFBundleIdentifier</key>'
			key_idx := content.index(key_tag) or { return '' }
			after_key := content[key_idx + key_tag.len..]
			val_start_tag := '<string>'
			val_end_tag := '</string>'
			val_start := after_key.index(val_start_tag) or { return '' }
			after_start := after_key[val_start + val_start_tag.len..]
			val_end := after_start.index(val_end_tag) or { return '' }
			return after_start[..val_end].trim_space()
		}
	}
	return ''
}

pub fn get_system_locale() string {
	for key in ['LC_ALL', 'LC_MESSAGES', 'LANG'] {
		val := os.getenv(key)
		if val.len > 0 {
			return val.split('.')[0]
		}
	}
	return 'en_US'
}

pub fn get_timezone() string {
	$if !windows {
		resolved := os.real_path('/etc/localtime')
		for prefix in ['/var/db/timezone/zoneinfo/', '/usr/share/zoneinfo/', '/usr/lib/zoneinfo/'] {
			if resolved.starts_with(prefix) {
				return resolved[prefix.len..]
			}
		}
	} $else {
		raw := exec_or('powershell -Command "(Get-TimeZone).Id"', '').trim_space()
		if raw.len > 0 {
			return raw
		}
	}
	tz := os.getenv('TZ')
	if tz.len > 0 {
		return tz
	}
	return 'UTC'
}

pub fn get_hardware_telemetry() HardwareInfo {
	tot_ram, free_ram, used_ram := get_memory_info()
	os_name, os_ver, _ := get_os_info()
	bat_pct, bat_chg, ac_conn := get_battery_info()
	l1, l5, l15 := get_load_average()

	return HardwareInfo{
		cpu_model: get_cpu_info()
		cpu_cores: get_cpu_cores()
		cpu_arch: get_cpu_architecture()
		cpu_usage: get_cpu_usage()
		ram_total_bytes: tot_ram
		ram_free_bytes: free_ram
		ram_used_bytes: used_ram
		ram_formatted: format_bytes(tot_ram)
		os_name: os_name
		os_version: os_ver
		hostname: get_hostname()
		uptime_seconds: get_uptime()
		battery_percent: bat_pct
		battery_charging: bat_chg
		ac_connected: ac_conn
		load_avg_1: l1
		load_avg_5: l5
		load_avg_15: l15
	}
}

// =============================================================================
// 7. System Power, Audio, Speech & Theme Settings
// =============================================================================

pub fn is_dark_mode() bool {
	$if macos {
		style := exec_or('defaults read -g AppleInterfaceStyle 2>/dev/null', '').trim_space()
		return style.to_lower() == 'dark'
	} $else $if windows {
		raw := exec_or('powershell -Command "(Get-ItemProperty -Path HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize).AppsUseLightTheme"', '1').trim_space()
		return raw == '0'
	} $else {
		raw := exec_or('gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null', '').to_lower()
		return raw.contains('dark')
	}
}

pub fn get_system_theme() string {
	if is_dark_mode() {
		return 'dark'
	}
	return 'light'
}

pub fn set_system_dark_mode(enabled bool) {
	$if macos {
		value := if enabled { 'true' } else { 'false' }
		exec_bg("osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to ${value}'")
	} $else $if windows {
		val_num := if enabled { 0 } else { 1 }
		cmd := "reg add HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize /v AppsUseLightTheme /t REG_DWORD /d ${val_num} /f"
		exec_bg(cmd)
	} $else {
		scheme := if enabled { 'prefer-dark' } else { 'default' }
		exec_bg("gsettings set org.gnome.desktop.interface color-scheme '${scheme}' 2>/dev/null")
	}
}

pub fn set_system_theme(theme string) ! {
	mode := theme.trim_space().to_lower()
	if mode != 'dark' && mode != 'light' {
		return error('Invalid theme "${theme}". Use "dark" or "light".')
	}
	set_system_dark_mode(mode == 'dark')
}

pub fn toggle_dark_mode() {
	set_system_dark_mode(!is_dark_mode())
}

pub fn sleep_display() {
	$if macos {
		exec_bg('pmset displaysleepnow')
	} $else $if windows {
		exec_bg("powershell -Command \"(Add-Type '[DllImport(\\\"user32.dll\\\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Passthru)::SendMessage(-1, 0x0112, 0xF170, 2)\"")
	} $else {
		exec_bg('xset dpms force off 2>/dev/null')
	}
}

pub fn sleep_computer() {
	$if macos {
		exec_bg('osascript -e \'tell application "System Events" to sleep\'')
	} $else $if windows {
		exec_bg('rundll32.exe powrprof.dll,SetSuspendState 0,1,0')
	} $else {
		exec_bg('systemctl suspend 2>/dev/null')
	}
}

pub fn lock_screen() {
	$if macos {
		exec_bg('/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend')
	} $else $if windows {
		exec_bg('rundll32.exe user32.dll,LockWorkStation')
	} $else {
		exec_bg('xdg-screensaver lock 2>/dev/null')
	}
}

pub fn start_screen_saver() {
	$if macos {
		exec_bg('open -a ScreenSaverEngine')
	} $else $if windows {
		exec_bg('powershell -Command "(Get-Command *.scr).Name | Select -First 1 | & {\$input}"')
	} $else {
		exec_bg('xdg-screensaver activate 2>/dev/null')
	}
}

pub fn log_out_user() {
	$if macos {
		exec_bg('osascript -e \'tell application "System Events" to log out\'')
	} $else $if windows {
		exec_bg('shutdown /l')
	} $else {
		exec_bg('gnome-session-quit --logout 2>/dev/null')
	}
}

pub fn restart_computer() {
	$if macos {
		exec_bg('osascript -e \'tell application "System Events" to restart\'')
	} $else $if windows {
		exec_bg('shutdown /r /t 0')
	} $else {
		exec_bg('reboot 2>/dev/null')
	}
}

pub fn shut_down_computer() {
	$if macos {
		exec_bg('osascript -e \'tell application "System Events" to shut down\'')
	} $else $if windows {
		exec_bg('shutdown /s /t 0')
	} $else {
		exec_bg('poweroff 2>/dev/null')
	}
}

pub fn prevent_sleep_bg(duration_sec int) {
	dur := if duration_sec <= 0 { 60 } else { duration_sec }
	$if macos {
		exec_bg('caffeinate -t ${dur}')
	} $else $if windows {
		exec_bg("powershell -Command \"Add-Type '[DllImport(\\\"kernel32.dll\\\")]public static extern uint SetThreadExecutionState(uint f);' -Name sys -Passthru; [sys]::SetThreadExecutionState(0x80000003)\"")
	} $else {
		exec_bg('systemd-inhibit --what=idle --why="rad_studio" sleep ${dur} 2>/dev/null')
	}
}

pub fn get_volume() int {
	$if macos {
		vol_str := exec_or("osascript -e 'output volume of (get volume settings)' 2>/dev/null", '0').trim_space()
		return vol_str.int()
	} $else $if windows {
		raw := exec_or('powershell -Command "[int]((Get-CimInstance -ClassName Win32_SoundDevice).Volume)"', '50').trim_space()
		return raw.int()
	} $else {
		raw := exec_or("amixer sget Master 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%'", '50').trim_space()
		return raw.int()
	}
}

pub fn set_volume(level int) {
	clamped := if level < 0 { 0 } else if level > 100 { 100 } else { level }
	$if macos {
		exec_bg("osascript -e 'set volume output volume ${clamped}'")
	} $else $if windows {
		exec_bg("powershell -Command \"(New-Object -ComObject WScript.Shell).SendKeys([char]174)\"")
	} $else {
		exec_bg("amixer -q sset Master ${clamped}% 2>/dev/null")
	}
}

pub fn is_muted() bool {
	$if macos {
		muted_str := exec_or("osascript -e 'output muted of (get volume settings)' 2>/dev/null", 'false').trim_space()
		return muted_str.to_lower() == 'true'
	} $else {
		return false
	}
}

pub fn set_muted(mute bool) {
	$if macos {
		val := if mute { 'true' } else { 'false' }
		exec_bg("osascript -e 'set volume output muted ${val}'")
	} $else $if windows {
		exec_bg("powershell -Command \"(New-Object -ComObject WScript.Shell).SendKeys([char]173)\"")
	} $else {
		m_str := if mute { 'mute' } else { 'unmute' }
		exec_bg("amixer -q sset Master ${m_str} 2>/dev/null")
	}
}

pub fn launch_at_login_add(app_name_or_path string) {
	$if macos {
		escaped := app_name_or_path.replace('"', '\\"')
		script := 'osascript -e \'tell application "System Events" to make login item at end with properties {path:"${escaped}", hidden:false}\''
		exec_bg(script)
	} $else $if windows {
		exe := os.executable()
		cmd := "reg add HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v \"${app_name_or_path}\" /t REG_SZ /d \"${exe}\" /f"
		exec_bg(cmd)
	}
}

pub fn launch_at_login_remove(app_name string) {
	$if macos {
		escaped := app_name.replace('"', '\\"')
		script := 'osascript -e \'tell application "System Events" to delete login item "${escaped}"\''
		exec_bg(script)
	} $else $if windows {
		cmd := "reg delete HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v \"${app_name}\" /f"
		exec_bg(cmd)
	}
}

pub fn set_dock_badge(count int) {
	$if macos {
		if count <= 0 {
			exec_bg('osascript -e \'tell application "System Events" to set the dock badge of the front application to 0\'')
		} else {
			exec_bg("osascript -e 'tell application \"System Events\" to set the dock badge of the front application to ${count}'")
		}
	}
}

// Audio & Speech
pub fn sys_beep() {
	$if macos {
		os.execute_opt("osascript -e 'beep'") or {}
	} $else $if windows {
		os.execute_opt("powershell -Command \"[console]::beep(800,200)\"") or {}
	} $else {
		print('\a')
	}
}

pub fn sys_beep_cross() {
	sys_beep()
}

pub fn beep() {
	sys_beep()
}

pub fn beep_n(n int) {
	count := if n < 1 { 1 } else { n }
	for _ in 0 .. count {
		beep()
		time.sleep(150 * time.millisecond)
	}
}

pub fn say(text string) {
	$if macos {
		escaped := text.replace('"', '\\"')
		exec_bg('say "${escaped}"')
	} $else $if windows {
		escaped := text.replace("'", "''")
		exec_bg("powershell -Command \"Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.Speak('${escaped}')\"")
	} $else {
		escaped := text.replace('"', '\\"')
		exec_bg('spd-say "${escaped}" 2>/dev/null')
	}
}

pub fn speak_with_voice(text string, voice string) {
	$if macos {
		escaped := text.replace('"', '\\"')
		v_esc := voice.replace('"', '\\"')
		exec_bg('say -v "${v_esc}" "${escaped}"')
	} $else $if windows {
		escaped := text.replace("'", "''")
		exec_bg("powershell -Command \"Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.SelectVoice('${voice}'); \$s.Speak('${escaped}')\"")
	} $else {
		escaped := text.replace('"', '\\"')
		exec_bg('spd-say "${escaped}" 2>/dev/null')
	}
}

pub fn play_system_sound(name string) {
	$if macos {
		sound := if name != '' { name } else { 'Ping' }
		sound_path := '/System/Library/Sounds/${sound}.aiff'
		if os.exists(sound_path) {
			exec_bg('afplay "${sound_path}" 2>/dev/null')
		} else {
			beep()
		}
	} $else $if windows {
		exec_bg('powershell -c "[System.Media.SystemSounds]::Asterisk.Play()"')
	} $else {
		exec_bg('paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null')
	}
}

// =============================================================================
// 8. Network Tools
// =============================================================================

pub fn ping_host(host string) bool {
	target := if host != '' { host } else { '8.8.8.8' }
	$if windows {
		_, code := exec('ping -n 1 -w 1000 ${target}')
		return code == 0
	} $else {
		_, code := exec('ping -c 1 -W 1 ${target} 2>/dev/null')
		return code == 0
	}
}

pub fn ping(host string, count int) bool {
	c := if count <= 0 { 1 } else { count }
	target := if host != '' { host } else { '8.8.8.8' }
	$if windows {
		_, code := exec('ping -n ${c} "${target}"')
		return code == 0
	} $else {
		_, code := exec('ping -c ${c} "${target}" 2>/dev/null')
		return code == 0
	}
}

pub fn mask_ip(ip string) string {
	clean := ip.trim_space()
	if clean == '' || clean == '127.0.0.1' {
		return '127.0.0.1 (Local Loopback)'
	}
	parts := clean.split('.')
	if parts.len == 4 {
		return '${parts[0]}.${parts[1]}.***.*** (Protected)'
	}
	if clean.contains(':') {
		return 'fe80::****:**** (Protected IPv6)'
	}
	return '***.***.***.*** (Protected)'
}

pub fn get_masked_ip() string {
	return mask_ip(get_local_ip())
}

pub fn get_local_ip() string {
	$if macos {
		return exec_or("ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null", '127.0.0.1')
	} $else $if windows {
		return exec_or('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi,Ethernet).IPAddress | Select-Object -First 1"', '127.0.0.1')
	} $else {
		return exec_or("hostname -I 2>/dev/null | awk '{print \$1}'", '127.0.0.1')
	}
}

pub fn get_ip_address() string {
	return get_masked_ip()
}

pub fn get_public_ip() string {
	return '***.***.***.*** (Protected)'
}

pub fn get_public_ip_raw() string {
	res := http.get('https://api.ipify.org') or { return '127.0.0.1' }
	return res.body.trim_space()
}

pub fn is_port_open(host string, port int) bool {
	$if windows {
		out, code := exec('powershell -Command "Test-NetConnection -ComputerName ${host} -Port ${port} -InformationLevel Quiet"')
		return code == 0 && out.contains('True')
	} $else {
		_, code := exec('nc -z -G 1 "${host}" ${port} 2>/dev/null')
		return code == 0
	}
}

pub fn find_available_port(start_port int) int {
	mut port := start_port
	for port < start_port + 100 {
		if !is_port_open('127.0.0.1', port) {
			return port
		}
		port++
	}
	return start_port
}

pub fn download_file(url string, dest_path string) ! {
	resp := http.get(url)!
	os.write_file(resolve_user_path(dest_path), resp.body)!
}

// =============================================================================
// 9. Font Resolution & Typography
// =============================================================================

pub fn linux_font_candidates() []string {
	return [
		'/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
		'/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf',
		'/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
		'/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
		'/usr/share/fonts/truetype/freefont/FreeSans.ttf',
		'/usr/share/fonts/truetype/roboto/unhinted/Roboto-Regular.ttf',
		'/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
		'/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf',
		'/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf',
		'/usr/share/fonts/truetype/freefont/FreeMono.ttf',
		'/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf',
		'/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf',
		'/usr/share/fonts/truetype/freefont/FreeSerif.ttf',
	]
}

pub fn macos_font_candidates() []string {
	return [
		'/System/Library/Fonts/Supplemental/Arial.ttf',
		'/System/Library/Fonts/Supplemental/Helvetica.ttf',
		'/System/Library/Fonts/Supplemental/Verdana.ttf',
		'/System/Library/Fonts/Supplemental/Trebuchet MS.ttf',
		'/System/Library/Fonts/Supplemental/Courier New.ttf',
		'/System/Library/Fonts/Supplemental/Andale Mono.ttf',
		'/System/Library/Fonts/Monaco.ttf',
		'/System/Library/Fonts/Supplemental/Times New Roman.ttf',
		'/System/Library/Fonts/Supplemental/Georgia.ttf',
		'/Library/Fonts/Arial.ttf',
	]
}

pub fn resolve_font_path_by_category(category string) string {
	cat := category.to_lower()
	$if macos {
		candidates := match cat {
			'mono', 'monospace', 'code' {
				['/System/Library/Fonts/Supplemental/Courier New.ttf', '/System/Library/Fonts/Monaco.ttf']
			}
			'serif', 'editorial' {
				['/System/Library/Fonts/Supplemental/Times New Roman.ttf', '/System/Library/Fonts/Supplemental/Georgia.ttf']
			}
			'display', 'impact' {
				['/System/Library/Fonts/Supplemental/Impact.ttf', '/System/Library/Fonts/Supplemental/Trebuchet MS.ttf']
			}
			else {
				['/System/Library/Fonts/Supplemental/Arial.ttf', '/System/Library/Fonts/Supplemental/Helvetica.ttf']
			}
		}
		for c in candidates {
			if os.exists(c) { return c }
		}
	} $else $if linux {
		candidates := match cat {
			'mono', 'monospace', 'code' {
				['/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', '/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf']
			}
			'serif', 'editorial' {
				['/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf', '/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf']
			}
			else {
				['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', '/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf']
			}
		}
		for c in candidates {
			if os.exists(c) { return c }
		}
	} $else $if windows {
		candidates := match cat {
			'mono', 'monospace', 'code' { ['C:\\Windows\\Fonts\\consola.ttf', 'C:\\Windows\\Fonts\\cour.ttf'] }
			'serif', 'editorial' { ['C:\\Windows\\Fonts\\times.ttf', 'C:\\Windows\\Fonts\\georgia.ttf'] }
			else { ['C:\\Windows\\Fonts\\arial.ttf', 'C:\\Windows\\Fonts\\verdana.ttf'] }
		}
		for c in candidates {
			if os.exists(c) { return c }
		}
	}
	return ''
}

pub fn resolve_window_font_path() string {
	custom := os.getenv('SIMPLEGUI_FONT_PATH')
	if custom.len > 0 && os.exists(custom) {
		return custom
	}
	$if linux {
		for c in linux_font_candidates() {
			if os.exists(c) { return c }
		}
	} $else $if macos {
		for c in macos_font_candidates() {
			if os.exists(c) { return c }
		}
	}
	return ''
}

pub fn json_escape(s string) string {
	mut res := '"'
	for c in s {
		if c == `"` {
			res += '\\"'
		} else if c == `\\` {
			res += '\\\\'
		} else if c == `\n` {
			res += '\\n'
		} else if c == `\r` {
			res += '\\r'
		} else if c == `\t` {
			res += '\\t'
		} else if c < 32 {
			res += '\\u00' + (int(c)).hex()
		} else {
			res += c.ascii_str()
		}
	}
	res += '"'
	return res
}
