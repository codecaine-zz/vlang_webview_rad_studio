module system

import os
import json2
import time

// =============================================================================
// State & Configuration Persistence Utilities
// =============================================================================

// write_file_atomic writes data safely to a temporary file before atomically renaming it,
// ensuring that crashes, power cuts, or concurrent readers never observe corrupted partial files.
pub fn write_file_atomic(file_path string, content string) ! {
	resolved := resolve_user_path(file_path)
	parent_dir := os.dir(resolved)
	if parent_dir != '' && !os.exists(parent_dir) {
		os.mkdir_all(parent_dir) or { return error('Failed to create parent directory: ${parent_dir} (${err.msg()})') }
	}

	rand_id := '${os.getpid()}_${time.now().unix_nano()}'
	tmp_path := '${resolved}.${rand_id}.tmp'

	os.write_file(tmp_path, content) or {
		return error('Failed to write temporary state file: ${tmp_path} (${err.msg()})')
	}

	$if windows {
		if os.exists(resolved) {
			os.rm(resolved) or {}
		}
	}
	os.mv(tmp_path, resolved) or {
		os.rm(tmp_path) or {}
		return error('Failed to atomically rename state file to: ${resolved} (${err.msg()})')
	}
}

// save_state_to_file serializes a key-value state store dictionary to JSON at target path atomically.
pub fn save_state_to_file(file_path string, store map[string]string) ! {
	resolved := resolve_user_path(file_path)
	data := json2.encode(store)
	write_file_atomic(resolved, data) or { return error(err.msg()) }
}

// load_state_from_file reads and deserializes a JSON state map from disk.
pub fn load_state_from_file(file_path string) !map[string]string {
	resolved := resolve_user_path(file_path)
	if !os.exists(resolved) {
		return error('State file not found: ${resolved}')
	}
	content := os.read_file(resolved) or { return error(err.msg()) }
	if content.trim_space() == '' {
		return map[string]string{}
	}
	loaded := json2.decode[map[string]string](content) or { return error(err.msg()) }
	return loaded
}

// save_app_state persists a state store into the recommended OS user state directory.
// Default target file: '<app_state_dir>/state.json'.
// Employs atomic file writing to prevent state corruption across crashes or interruptions.
pub fn save_app_state(app_name string, store map[string]string, file_name ...string) ! {
	fname := if file_name.len > 0 && file_name[0] != '' { file_name[0] } else { 'state.json' }
	target_file := get_app_state_file(app_name, fname)
	save_state_to_file(target_file, store) or { return error(err.msg()) }
}

// save_app_state_or persists the state store into the recommended OS user directory, returning a boolean success flag.
pub fn save_app_state_or(app_name string, store map[string]string, file_name ...string) bool {
	save_app_state(app_name, store, ...file_name) or { return false }
	return true
}

// load_app_state reads persisted JSON state from the recommended OS user state directory.
// Returns map of state key-values, or error if unreadable.
pub fn load_app_state(app_name string, file_name ...string) !map[string]string {
	fname := if file_name.len > 0 && file_name[0] != '' { file_name[0] } else { 'state.json' }
	target_file := get_app_state_file(app_name, fname)
	if !os.exists(target_file) {
		fallback_file := get_app_config_file(app_name, fname)
		if !os.exists(fallback_file) {
			return map[string]string{}
		}
		return load_state_from_file(fallback_file)
	}
	return load_state_from_file(target_file)
}

// load_app_state_or loads state from recommended OS user state directory, returning empty map on failure.
pub fn load_app_state_or(app_name string, file_name ...string) map[string]string {
	res := load_app_state(app_name, ...file_name) or { return map[string]string{} }
	return res
}

// has_saved_app_state checks whether persisted state file exists on disk for an application.
pub fn has_saved_app_state(app_name string, file_name ...string) bool {
	fname := if file_name.len > 0 && file_name[0] != '' { file_name[0] } else { 'state.json' }
	target_file := get_app_state_file(app_name, fname)
	if os.exists(target_file) {
		return true
	}
	fallback_file := get_app_config_file(app_name, fname)
	return os.exists(fallback_file)
}

// clear_app_state removes persisted state file from disk.
pub fn clear_app_state(app_name string, file_name ...string) ! {
	fname := if file_name.len > 0 && file_name[0] != '' { file_name[0] } else { 'state.json' }
	target_file := get_app_state_file(app_name, fname)
	if os.exists(target_file) {
		os.rm(target_file) or { return error(err.msg()) }
	}
	fallback_file := get_app_config_file(app_name, fname)
	if os.exists(fallback_file) {
		os.rm(fallback_file) or {}
	}
}
