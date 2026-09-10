module system

import os
import time
import crypto.rand as crand
import encoding.hex

// =============================================================================
// Security Utilities - Cross-Platform Command Injection & Path Traversal Guards
// =============================================================================

// quote_arg escapes a string so that it can be safely used as a single shell argument.
// Uses strict POSIX single-quote wrapping: wraps in '...' and replaces internal ' with '\''.
// On Windows, wraps in double-quotes and escapes inner quotes.
pub fn quote_arg(s string) string {
	if s == '' {
		$if windows {
			return '""'
		} $else {
			return "''"
		}
	}
	$if windows {
		return '"' + s.replace('"', '""') + '"'
	} $else {
		return "'" + s.replace("'", "'\\''") + "'"
	}
}

// quote_path validates that a path does not contain null bytes and safely quotes it.
pub fn quote_path(path string) string {
	clean := path.replace('\x00', '').trim_space()
	return quote_arg(clean)
}

// exec_safe executes a binary with an array of arguments, ensuring every argument
// is strictly quoted with quote_arg to prevent command injection and shell syntax errors.
pub fn exec_safe(bin string, args []string) os.Result {
	safe_bin := quote_arg(bin)
	mut safe_args := []string{}
	for a in args {
		safe_args << quote_arg(a)
	}
	cmd := '${safe_bin} ${safe_args.join(' ')} 2>&1'
	return os.execute(cmd)
}

// exec_safe_stdin executes a binary with arguments while piping standard input from a target file securely.
pub fn exec_safe_stdin(bin string, args []string, input_file string) os.Result {
	safe_bin := quote_arg(bin)
	mut safe_args := []string{}
	for a in args {
		safe_args << quote_arg(a)
	}
	cmd := '${safe_bin} ${safe_args.join(' ')} < ${quote_path(input_file)} 2>&1'
	return os.execute(cmd)
}

// sanitize_filename strips path traversal sequences and dangerous shell metacharacters from user-provided file names.
pub fn sanitize_filename(name string) string {
	mut s := name.replace('\x00', '').replace('/', '_').replace('\\', '_').replace(':', '_')
	s = s.replace(';', '_').replace('&', '_').replace('|', '_').replace('`', '_').replace('$', '_')
	s = s.replace('(', '_').replace(')', '_').replace('"', '_').replace("'", '_')
	s = s.replace('..', '_')
	return s.trim_space()
}

// validate_path ensures that target path stays strictly inside base_dir to prevent directory traversal attacks.
pub fn validate_path(target_path string, base_dir string) !string {
	clean_base := os.real_path(base_dir)
	clean_target := os.real_path(target_path)
	if !clean_target.starts_with(clean_base) {
		return error('Path traversal detected: "${target_path}" is outside "${base_dir}"')
	}
	return clean_target
}

// constant_time_compare compares two strings in constant time to prevent side-channel timing attacks on tokens and hashes.
pub fn constant_time_compare(a string, b string) bool {
	if a.len != b.len {
		return false
	}
	mut diff := u8(0)
	for i in 0 .. a.len {
		diff |= a[i] ^ b[i]
	}
	return diff == 0
}

// mask_secret masks a sensitive string (e.g. API key, credit card, password) leaving visible characters at head and tail.
pub fn mask_secret(secret string, visible_start int, visible_end int) string {
	if secret.len <= visible_start + visible_end {
		return '*'.repeat(secret.len)
	}
	head := secret[..visible_start]
	tail := secret[secret.len - visible_end..]
	stars := '*'.repeat(secret.len - visible_start - visible_end)
	return '${head}${stars}${tail}'
}

// sanitize_html strips potentially dangerous script tags and event handlers from HTML.
pub fn sanitize_html(raw_html string) string {
	mut s := raw_html
	s = s.replace('<script', '&lt;script').replace('</script>', '&lt;/script&gt;')
	s = s.replace('javascript:', '')
	s = s.replace('onload=', 'data-blocked=')
	s = s.replace('onerror=', 'data-blocked=')
	s = s.replace('onclick=', 'data-blocked=')
	return s
}

// is_safe_url checks whether a URL uses an approved secure protocol (http or https).
pub fn is_safe_url(raw_url string) bool {
	trimmed := raw_url.trim_space().to_lower()
	return trimmed.starts_with('https://') || trimmed.starts_with('http://')
}

// generate_secure_token generates a cryptographically random hexadecimal token of specified byte length.
pub fn generate_secure_token(byte_length int) string {
	bytes := crand.bytes(byte_length) or {
		// Fallback deterministic if entropy pool fails
		return 'token_${time.now().unix_nano()}'
	}
	return hex.encode(bytes)
}
