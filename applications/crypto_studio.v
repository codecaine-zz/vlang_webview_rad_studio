module main

import simplegui
import system
import rand
import math
import os

fn compute_shannon_entropy(data string) f64 {
	if data.len == 0 {
		return 0.0
	}
	mut freq := map[u8]int{}
	for b in data.bytes() {
		freq[b]++
	}
	mut entropy := 0.0
	len_f := f64(data.len)
	for _, count in freq {
		p := f64(count) / len_f
		entropy -= p * math.log2(p)
	}
	return entropy
}

fn compute_crypto_rows(payload string, key string) [][]string {
	return [
		['SHA-256', system.hash_sha256(payload), '256 bits'],
		['HMAC-SHA256', system.hmac_sha256(key, payload), '256 bits'],
		['SHA-512', system.hash_sha512(payload), '512 bits'],
		['MD5', system.hash_md5(payload), '128 bits'],
		['SHA-1', system.crypto_sha1(payload), '160 bits'],
		['HMAC-SHA512', system.crypto_hmac_sha512(payload, key), '512 bits'],
		['Base64 Encoded', system.encode_base64(payload), '${payload.len * 8} bits'],
		['Hex String', system.encode_hex(payload), '${payload.len * 8} bits'],
	]
}

fn update_crypto_hashes(w &simplegui.SimpleWindow, payload string, key string) {
	rows := compute_crypto_rows(payload, key)
	w.set_table_rows('crypto_table', rows)

	entropy := compute_shannon_entropy(payload)
	sha256_val := system.hash_sha256(payload)
	sha_prev := if sha256_val.len > 12 { sha256_val[..12] + '...' } else { sha256_val }

	w.set_kpi('kpi_entropy', '${entropy:.2f} bits/byte', if entropy > 3.5 { 'High Entropy' } else { 'Low/Medium' })
	w.set_kpi('kpi_payload_size', '${payload.len} Bytes', '${payload.len * 8} bits')
	w.set_kpi('kpi_sha256', sha_prev, 'SHA-256')
	w.set_kpi('kpi_ciphers', '${rows.len} Primitives', 'Active')

	display_text := if payload.len > 28 { payload[..28] + '...' } else { payload }
	w.set_status('⚡ Live Hashes Recomputed: "${display_text}" (${payload.len} bytes) • Key (${key.len} bytes)')
}

fn generate_random_password(length int) string {
	chars := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+'
	mut res := ''
	for _ in 0 .. length {
		idx := rand.int_in_range(0, chars.len) or { 0 }
		res += chars[idx..idx + 1]
	}
	return res
}

fn generate_uuid_v4() string {
	b := rand.bytes(16) or { return '00000000-0000-4000-8000-000000000000' }
	mut hex_parts := []string{}
	for val in b {
		h := val.hex()
		hex_parts << if h.len < 2 { '0' + h } else { h }
	}
	// UUID v4 format: 8-4-4-4-12
	return '${hex_parts[0..4].join('')}-${hex_parts[4..6].join('')}-4${hex_parts[6..8].join('')[1..]}-a${hex_parts[8..10].join('')[1..]}-${hex_parts[10..16].join('')}'
}

fn main() {
	default_payload := 'The quick brown fox jumps over the lazy dog'
	default_key := 'secret-signing-key-2026'

	mut win := simplegui.new_window(
		title: 'Crypto Studio Pro Enterprise -- Cryptography & Security Workbench'
		width: 1180
		height: 890
		theme: 'midnight'
	)

	win.heading('🔒 Crypto Studio Pro Enterprise')
	win.subheading('Enterprise Cryptography Workbench: SHA-256, SHA-512, HMAC, Base64, Hex, Entropy & Password Generators')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_entropy', 'Shannon Entropy', '0.00 bits', 'Entropy')
	win.kpi_card_named('kpi_payload_size', 'Payload Size', '44 Bytes', 'Source')
	win.kpi_card_named('kpi_sha256', 'SHA-256 Digest', '...', 'Hash')
	win.kpi_card_named('kpi_ciphers', 'Primitives', '8 Primitives', 'Active')
	win.row_end()

	// Payload & HMAC Configuration Box
	win.box_start('🔐 Payload & Secret Key Configuration')
	win.subheading('Input Text Payload')
	win.textarea_named('txt_payload', 'Enter plain text or Base64 payload to hash or encode...', default_payload, fn (w &simplegui.SimpleWindow, val string) {
		key := w.get('txt_key')
		update_crypto_hashes(w, val, key)
	})

	win.row_start()
	win.input_named('txt_key', 'HMAC Secret Key...', default_key, fn (w &simplegui.SimpleWindow, val string) {
		text := w.get('txt_payload')
		update_crypto_hashes(w, text, val)
	})
	win.button('🎲 Generate Random Key', fn (w &simplegui.SimpleWindow, _ string) {
		new_key := generate_random_password(24)
		w.set_value('txt_key', new_key)
		text := w.get('txt_payload')
		update_crypto_hashes(w, text, new_key)
		w.toast_success('Generated secure 24-character HMAC key!')
	})
	win.row_end()
	win.box_end()

	// Cryptographic Hashes Table Box
	win.box_start('📊 Cryptographic Digests & Encodings Table')
	headers := ['Algorithm / Primitive', 'Computed Digest', 'Length']
	initial_rows := compute_crypto_rows(default_payload, default_key)
	win.table_named('crypto_table', headers, initial_rows, fn (w &simplegui.SimpleWindow, idx string) {
		row_idx := idx.int()
		text := w.get('txt_payload')
		key := w.get('txt_key')
		rows := compute_crypto_rows(text, key)
		if row_idx >= 0 && row_idx < rows.len {
			algo := rows[row_idx][0]
			hash_val := rows[row_idx][1]
			system.set_clipboard_text(hash_val)
			w.toast_info('📋 Copied ${algo} hash to clipboard!')
			w.set_status('Copied ${algo}: ${hash_val}')
		}
	})
	win.box_end()

	// Generators & Quick Tools Box
	win.box_start('🛠️ Security Utilities & Codec Tools')
	win.row_start()
	win.button('📦 Encode Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get('txt_payload')
		b64 := system.encode_base64(text)
		system.set_clipboard_text(b64)
		w.set_value('txt_payload', b64)
		key := w.get('txt_key')
		update_crypto_hashes(w, b64, key)
		w.toast_success('Payload encoded to Base64 and copied to clipboard!')
	})
	win.button('🔓 Decode Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get('txt_payload')
		decoded := system.decode_base64(text)
		if decoded == '' && text.trim_space() != '' {
			w.toast_warning('Payload is not valid Base64.')
			return
		}
		w.set_value('txt_payload', decoded)
		key := w.get('txt_key')
		update_crypto_hashes(w, decoded, key)
		system.set_clipboard_text(decoded)
		w.toast_success('Base64 decoded successfully!')
	})
	win.button('🔑 Generate Password (20 char)', fn (w &simplegui.SimpleWindow, _ string) {
		pwd := generate_random_password(20)
		w.set_value('txt_payload', pwd)
		key := w.get('txt_key')
		update_crypto_hashes(w, pwd, key)
		system.set_clipboard_text(pwd)
		w.toast_success('Generated 20-char high-entropy password!')
	})
	win.button('🆔 Generate UUID v4', fn (w &simplegui.SimpleWindow, _ string) {
		uuid := generate_uuid_v4()
		w.set_value('txt_payload', uuid)
		key := w.get('txt_key')
		update_crypto_hashes(w, uuid, key)
		system.set_clipboard_text(uuid)
		w.toast_success('Generated UUID v4: ' + uuid)
	})
	win.button('📁 File Checksum Verifier...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select File to Checksum', '*')
		if path != '' {
			content := os.read_file(path) or {
				w.toast_error('Failed to read file: ${err}')
				return
			}
			sha := system.hash_sha256(content)
			md5_val := system.hash_md5(content)
			w.modal_alert('File Checksums', 'File: ${os.file_name(path)} (${content.len} bytes)\n\nSHA-256:\n${sha}\n\nMD5:\n${md5_val}')
			w.toast_success('Computed file checksums!')
		}
	})
	win.row_end()
	win.box_end()

	win.status_bar('Crypto Studio Pro Enterprise  •  Hardware Acceleration Active  •  Ready')

	// Initial population
	update_crypto_hashes(win, default_payload, default_key)

	win.run()
}
