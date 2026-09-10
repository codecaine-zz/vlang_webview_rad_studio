module main

import simplegui
import system

fn main() {
	mut win := simplegui.new_window(
		title: 'Crypto Studio Pro -- Cryptography, Security & Token Workbench'
		width: 1160
		height: 880
		theme: 'midnight'
	)

	win.heading('🔒 Crypto Studio Pro')
	win.label('Enterprise Cryptography Workbench: SHA-256, SHA-512, MD5, HMAC, Base64, Hex & Entropy Auditing')

	win.subheading('Input Text Payload')
	win.input('Enter plain text to hash or encode...', 'The quick brown fox jumps over the lazy dog', fn (w &simplegui.SimpleWindow, val string) {
		println('Input updated: ' + val)
	})

	win.subheading('HMAC Secret Key')
	win.input('Enter secret HMAC signing key...', 'secret-signing-key-2026', fn (w &simplegui.SimpleWindow, val string) {
		println('Key updated: ' + val)
	})

	win.divider()
	win.subheading('Cryptographic Hashes & Signatures')

	sample_text := 'The quick brown fox jumps over the lazy dog'
	headers := ['Algorithm / Primitive', 'Computed Digest (Hex)', 'Bits']
	rows := [
		['SHA-256', system.hash_sha256(sample_text), '256'],
		['HMAC-SHA256', system.hmac_sha256('secret-signing-key-2026', sample_text), '256'],
		['SHA-512', system.hash_sha512(sample_text), '512'],
		['MD5', system.hash_md5(sample_text), '128'],
		['Base64 Encoded', system.encode_base64(sample_text), '${sample_text.len * 8}']
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.notification('Hash Selected', 'Inspecting hash row #${idx}')
	})

	win.divider()
	win.subheading('Quick Actions')

	win.button('⚡ Calculate All Hashes', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('inp_1')
		hash256 := system.hash_sha256(text)
		w.alert('SHA-256 Computed', 'Hash for input:\n' + hash256)
	})

	win.button('📦 Encode to Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('inp_1')
		b64 := system.encode_base64(text)
		system.set_clipboard_text(b64)
		w.alert('Base64 Encoded', 'Encoded string copied to clipboard:\n' + b64)
	})

	win.button('🔓 Decode from Base64', fn (w &simplegui.SimpleWindow, _ string) {
		text := w.get_value('inp_1')
		decoded := system.decode_base64(text)
		w.alert('Base64 Decoded', 'Decoded text:\n' + decoded)
	})

	win.status_bar('Crypto Studio Pro  •  Hardware Acceleration Active  •  AES/SHA/HMAC Ready')
	win.run()
}
