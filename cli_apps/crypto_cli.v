module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('crypto_cli')
	fp.version('2.0.0')
	fp.description('Enterprise Cryptographic Tool & Hashing Workstation')
	fp.skip_executable()

	algo := fp.string('algo', `a`, 'sha256', 'Hashing algorithm: md5, sha256, sha512, hmac')
	key := fp.string('key', `k`, '', 'Secret key for HMAC hashing')
	is_b64_enc := fp.bool('b64-encode', `e`, false, 'Base64 encode the input')
	is_b64_dec := fp.bool('b64-decode', `d`, false, 'Base64 decode the input')
	is_hex_enc := fp.bool('hex-encode', `x`, false, 'Hex encode the input')
	is_hex_dec := fp.bool('hex-decode', `y`, false, 'Hex decode the input')
	show_all := fp.bool('all', `A`, false, 'Compute all hashes simultaneously')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}

	input := if additional_args.len > 0 { additional_args.join(' ') } else { 'Hello, RAD Studio!' }
	mode_count := int(is_b64_enc) + int(is_b64_dec) + int(is_hex_enc) + int(is_hex_dec) + int(show_all)
	if mode_count > 1 {
		eprintln('Error: Encoding, decoding, and --all modes are mutually exclusive')
		exit(2)
	}

	if is_b64_enc {
		println(system.encode_base64(input))
		return
	}
	if is_b64_dec {
		clean := input.trim_space().replace('\r', '').replace('\n', '').replace(' ', '')
		padding := clean.count('=')
		if clean == '' || clean.len % 4 == 1 || padding > 2
			|| (padding > 0 && !clean.ends_with('='.repeat(padding)))
			|| clean[..clean.len - padding].contains('=')
			|| clean.bytes().any(!(it.is_alnum() || it in [`+`, `/`, `-`, `_`, `=`])) {
			eprintln('Error: Invalid Base64 input')
			exit(2)
		}
		println(system.decode_base64(input))
		return
	}
	if is_hex_enc {
		println(system.encode_hex(input))
		return
	}
	if is_hex_dec {
		if input == '' || input.len % 2 != 0 || input.bytes().any(!it.is_hex_digit()) {
			eprintln('Error: Invalid hexadecimal input')
			exit(2)
		}
		println(system.decode_hex(input))
		return
	}

	if show_all {
		println('====================================================================')
		println('🔐 CRYPTOGRAPHIC HASH WORKSTATION (vlang)')
		println('====================================================================')
		println('Input:       ${input}')
		println('MD5:         ${system.hash_md5(input)}')
		println('SHA-256:     ${system.hash_sha256(input)}')
		println('SHA-512:     ${system.hash_sha512(input)}')
		println('Base64:      ${system.encode_base64(input)}')
		println('Hex:         ${system.encode_hex(input)}')
		if key != '' {
			println('HMAC-SHA256: ${system.hmac_sha256(key, input)}')
		}
		println('====================================================================')
		return
	}

	match algo.to_lower() {
		'md5' {
			println(system.hash_md5(input))
		}
		'sha512' {
			println(system.hash_sha512(input))
		}
		'hmac' {
			if key == '' {
				eprintln('Error: --key required for HMAC')
				exit(2)
			}
			println(system.hmac_sha256(key, input))
		}
		'sha256' {
			println(system.hash_sha256(input))
		}
		else {
			eprintln('Error: Unsupported hashing algorithm "${algo}"')
			exit(2)
		}
	}
}
