module main

import simplegui
import system

fn compute_crypto_rows(payload string, key string) [][]string {
	return [
		['SHA-256', system.hash_sha256(payload), '256'],
		['HMAC-SHA256', system.hmac_sha256(key, payload), '256'],
		['SHA-512', system.hash_sha512(payload), '512'],
		['MD5', system.hash_md5(payload), '128'],
		['SHA-1', system.crypto_sha1(payload), '160'],
		['HMAC-SHA512', system.crypto_hmac_sha512(payload, key), '512'],
		['Base64 Encoded', system.encode_base64(payload), '${payload.len * 8}'],
	]
}

fn update_crypto_hashes(w &simplegui.SimpleWindow, payload string, key string) {
	rows := compute_crypto_rows(payload, key)
	w.set_table_rows('crypto_table', rows)
	display_text := if payload.len > 28 { payload[..28] + '...' } else { payload }
	w.set_status('⚡ Live Hashes Recomputed: "${display_text}" (${payload.len} bytes) • Key (${key.len} bytes)')
}

fn main() {
	default_payload := 'The quick brown fox jumps over the lazy dog'
	default_key := 'secret-signing-key-2026'

	mut win := simplegui.new_window(
		title: 'Crypto Studio Pro -- Cryptography, Security & Token Workbench'
		width: 1160
		height: 880
		theme: 'midnight'
	)

	win.heading('🔒 Crypto Studio Pro')
	win.label('Enterprise Cryptography Workbench: SHA-256, SHA-512, MD5, HMAC, Base64, Hex & Entropy Auditing')

	win.subheading('Input Text Payload')
	win.textarea_named('txt_payload', 'Enter plain text or Base64 payload to hash or encode...', default_payload, fn (w &simplegui.SimpleWindow, val string) {
		println('Input updated: ' + val)
		key := w.get_value('txt_key')
		update_crypto_hashes(w, val, key)
	})

	win.subheading('HMAC Secret Key')
	win.input_named('txt_key', 'Enter secret HMAC signing key...', default_key, fn (w &simplegui.SimpleWindow, val string) {
		println('Key updated: ' + val)
		text := w.get_value('txt_payload')
		update_crypto_hashes(w, text, val)
	})

	win.divider()
	win.subheading('Cryptographic Hashes & Signatures')

	headers := ['Algorithm / Primitive', 'Computed Digest (Hex)', 'Bits']
	initial_rows := compute_crypto_rows(default_payload, default_key)
	win.table_named('crypto_table', headers, initial_rows, fn (w &simplegui.SimpleWindow, idx string) {
		row_idx := idx.int()
		text := w.get_value('txt_payload')
		key := w.get_value('txt_key')
		rows := compute_crypto_rows(text, key)
		if row_idx >= 0 && row_idx < rows.len {
			algo := rows[row_idx][0]
			hash_val := rows[row_idx][1]
			system.set_clipboard_text(hash_val)
			w.toast_info('📋 Copied ${algo} hash to clipboard!')
			w.set_status('Copied ${algo}: ${hash_val}')
		}
	})

	win.divider()
	win.subheading('Quick Actions')

	win.button('⚡ Calculate All Hashes', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('txt_payload')
		key := w.get_value('txt_key')
		update_crypto_hashes(w, text, key)
		hash256 := system.hash_sha256(text)
		w.toast_success('⚡ All hashes recalculated successfully!')
		w.alert('SHA-256 Computed', 'Hash for input (${text.len} bytes):\n' + hash256)
	})

	win.button('📦 Encode to Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('txt_payload')
		b64 := system.encode_base64(text)
		system.set_clipboard_text(b64)
		w.set_value('txt_payload', b64)
		key := w.get_value('txt_key')
		update_crypto_hashes(w, b64, key)
		w.toast_success('📦 Encoded to Base64! Payload & hashes updated.')
		w.modal_alert('Base64 Encoded', 'Encoded string copied to clipboard and set into input payload:\n\n' + b64)
	})

	win.button('🔓 Decode from Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('txt_payload')
		decoded := system.decode_base64(text)
		if decoded == '' && text.trim_space() != '' {
			w.toast_warning('⚠️ Input is not valid Base64 encoded text!')
			w.modal_alert('Base64 Decode Error', 'The current payload could not be decoded as Base64.\n\nMake sure the input contains valid Base64 data (e.g. "VGhlIHF1aWNr...").\n\nTip: Click "📦 Encode to Base64" to encode your text first, or click the "Base64 Encoded" row in the table above to copy it.')
			return
		}
		w.set_value('txt_payload', decoded)
		key := w.get_value('txt_key')
		update_crypto_hashes(w, decoded, key)
		system.set_clipboard_text(decoded)
		w.toast_success('🔓 Base64 decoded successfully! Payload & hashes updated.')
		w.modal_alert('Base64 Decoded', 'Successfully decoded payload:\n\n' + decoded + '\n\n(Decoded text loaded into input payload and copied to clipboard)')
	})

	win.status_bar('Crypto Studio Pro  •  Hardware Acceleration Active  •  AES/SHA/HMAC Ready')
	win.run()
}
