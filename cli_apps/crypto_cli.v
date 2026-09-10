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
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	input := if additional_args.len > 0 { additional_args.join(' ') } else { 'Hello, RAD Studio!' }

	if is_b64_enc {
		println(system.encode_base64(input))
		return
	}
	if is_b64_dec {
		println(system.decode_base64(input))
		return
	}
	if is_hex_enc {
		println(system.encode_hex(input))
		return
	}
	if is_hex_dec {
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
				exit(1)
			}
			println(system.hmac_sha256(key, input))
		}
		else {
			println(system.hash_sha256(input))
		}
	}
}
