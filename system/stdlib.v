// Module system - Standard Library & Developer Utilities for RAD Studio
// Ported from simple_gg and vlang_simplegui
// Cross-platform support for macOS, Windows, and Linux.

module system

import net.http
import regex
import compress.gzip
import compress.zlib
import crypto.sha256
import crypto.sha512
import crypto.sha1
import crypto.md5
import crypto.hmac
import crypto.aes
import crypto.cipher
import crypto.ed25519
import crypto.pbkdf2
import crypto.bcrypt
import crypto.rand as crand
import rand
import time
import net.urllib
import net.html
import json2
import encoding.hex
import encoding.base64
import encoding.utf8
import encoding.csv
import datatypes
import strings
import math
import math.complex
import math.stats
import sync
import hash as vhash

// =============================================================================
// 1. HTTP Client Utilities
// =============================================================================

pub struct HttpResponse {
pub mut:
	status_code int
	body        string
	headers     map[string]string
}

pub struct SimpleHttpResponse {
pub mut:
	status_code int
	body        string
	raw_headers string
	url         string
}

pub struct SimpleHttpRequestOptions {
pub mut:
	headers        map[string]string
	user_agent     string = 'RADStudio/1.0'
	retries        int    = 1
	retry_delay_ms int    = 250
	expect_success bool
}

pub fn http_get(url string) HttpResponse {
	res := http.get(url) or {
		return HttpResponse{
			status_code: 0
			body: 'Error: ${err}'
		}
	}
	mut headers_map := map[string]string{}
	for h in res.header.keys() {
		headers_map[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body: res.body
		headers: headers_map
	}
}

pub fn http_get_body(url string) string {
	res := http.get(url) or { return '' }
	return res.body
}

pub fn http_post(url string, data string, content_type string) HttpResponse {
	mut req := http.new_request(.post, url, data)
	ct := if content_type != '' { content_type } else { 'application/json' }
	req.header.set(.content_type, ct)
	res := req.do() or {
		return HttpResponse{
			status_code: 0
			body: 'Error: ${err}'
		}
	}
	mut headers_map := map[string]string{}
	for h in res.header.keys() {
		headers_map[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body: res.body
		headers: headers_map
	}
}

pub fn http_post_body(url string, data string) string {
	res := http.post(url, data) or { return '' }
	return res.body
}

pub fn http_request(method_name string, url string, data string, headers map[string]string) HttpResponse {
	method := match method_name.to_upper() {
		'GET' { http.Method.get }
		'POST' { http.Method.post }
		'PUT' { http.Method.put }
		'DELETE' { http.Method.delete }
		'PATCH' { http.Method.patch }
		'HEAD' { http.Method.head }
		else { http.Method.get }
	}
	mut req := http.new_request(method, url, data)
	for k, v in headers {
		req.header.set_custom(k, v) or {}
	}
	res := req.do() or {
		return HttpResponse{
			status_code: 0
			body: 'Error: ${err}'
		}
	}
	mut resp_headers := map[string]string{}
	for h in res.header.keys() {
		resp_headers[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body: res.body
		headers: resp_headers
	}
}

pub fn http_get_strict(url string) !string {
	res := http.get(url)!
	if res.status_code >= 400 {
		return error('HTTP ${res.status_code}: ${res.body}')
	}
	return res.body
}

pub fn http_post_strict(url string, data string) !string {
	res := http.post(url, data)!
	if res.status_code >= 400 {
		return error('HTTP ${res.status_code}: ${res.body}')
	}
	return res.body
}

// =============================================================================
// 2. Regular Expressions & Pattern Matching
// =============================================================================

pub fn regex_match(text string, pattern string) bool {
	mut re := regex.regex_opt(pattern) or { return false }
	return re.matches_string(text)
}

pub fn regex_find(text string, pattern string) []string {
	mut re := regex.regex_opt(pattern) or { return []string{} }
	return re.find_all_str(text)
}

pub fn regex_replace(text string, pattern string, replacement string) string {
	mut re := regex.regex_opt(pattern) or { return text }
	return re.replace(text, replacement)
}

pub fn regex_match_strict(text string, pattern string) !bool {
	mut re := regex.regex_opt(pattern)!
	return re.matches_string(text)
}

pub fn regex_find_strict(text string, pattern string) ![]string {
	mut re := regex.regex_opt(pattern)!
	return re.find_all_str(text)
}

pub fn regex_replace_strict(text string, pattern string, replacement string) !string {
	mut re := regex.regex_opt(pattern)!
	return re.replace(text, replacement)
}

// =============================================================================
// 3. Cryptography, Hashing, Encoders & Digital Signatures
// =============================================================================

pub fn hash_sha256(text string) string {
	return sha256.hexhash(text)
}

pub fn crypto_sha256(text string) string {
	return sha256.hexhash(text)
}

pub fn hash_sha512(text string) string {
	return sha512.hexhash(text)
}

pub fn crypto_sha512(text string) string {
	return sha512.hexhash(text)
}

pub fn crypto_sha1(text string) string {
	return sha1.hexhash(text)
}

pub fn hash_md5(text string) string {
	return md5.hexhash(text)
}

pub fn crypto_md5(text string) string {
	return md5.hexhash(text)
}

pub fn hmac_sha256(key string, data string) string {
	sum := hmac.new(key.bytes(), data.bytes(), sha256.sum, sha256.block_size)
	return sum.hex()
}

pub fn crypto_hmac_sha256(text string, key string) string {
	return hmac_sha256(key, text)
}

pub fn crypto_hmac_sha512(text string, key string) string {
	sum := hmac.new(key.bytes(), text.bytes(), sha512.sum512, sha512.block_size)
	return sum.hex()
}

pub fn crypto_hmac_sha1(text string, key string) string {
	sum := hmac.new(key.bytes(), text.bytes(), sha1.sum, sha1.block_size)
	return sum.hex()
}

pub fn encode_base64(text string) string {
	return base64.encode_str(text)
}

pub fn decode_base64(encoded string) string {
	mut s := encoded.trim_space().replace('\r', '').replace('\n', '').replace(' ', '')
	s = s.replace('-', '+').replace('_', '/')
	if s.len == 0 {
		return ''
	}
	for s.len % 4 != 0 {
		s += '='
	}
	return base64.decode_str(s)
}

pub fn encode_hex(data string) string {
	return hex.encode(data.bytes())
}

pub fn decode_hex(encoded string) string {
	b := hex.decode(encoded) or { []u8{} }
	return b.bytestr()
}

pub fn crypto_wyhash(text string, seed u64) u64 {
	return vhash.sum64_string(text, seed)
}

// AES-128 CBC Encryption & Decryption
pub fn crypto_encrypt_aes(plain_text string, key_hex string) string {
	decoded_key := hex.decode(key_hex) or { []u8{} }
	mut key := decoded_key.clone()
	if key.len != 16 && key.len != 24 && key.len != 32 {
		if key.len < 16 {
			for key.len < 16 { key << u8(0) }
		} else {
			key = key[..16].clone()
		}
	}
	iv := [u8(9), 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 4]
	block := aes.new_cipher(key) or { return '' }
	mut enc := cipher.new_cbc(block, iv)

	plaintext := plain_text.bytes()
	mut padded := plaintext.clone()
	pad_len := 16 - (padded.len % 16)
	for _ in 0 .. pad_len {
		padded << u8(pad_len)
	}

	mut ciphertext := []u8{len: padded.len}
	enc.encrypt_blocks(mut ciphertext, padded)
	return hex.encode(ciphertext)
}

pub fn crypto_decrypt_aes(cipher_hex string, key_hex string) string {
	decoded_key := hex.decode(key_hex) or { []u8{} }
	mut key := decoded_key.clone()
	if key.len != 16 && key.len != 24 && key.len != 32 {
		if key.len < 16 {
			for key.len < 16 { key << u8(0) }
		} else {
			key = key[..16].clone()
		}
	}
	iv := [u8(9), 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 4]
	ciphertext := hex.decode(cipher_hex) or { return '' }
	if ciphertext.len % 16 != 0 || ciphertext.len == 0 {
		return ''
	}

	block := aes.new_cipher(key) or { return '' }
	mut dec := cipher.new_cbc(block, iv)
	mut decrypted := []u8{len: ciphertext.len}
	dec.decrypt_blocks(mut decrypted, ciphertext)

	if decrypted.len == 0 { return '' }
	unpadded_len := decrypted.len - int(decrypted.last())
	if unpadded_len < 0 || unpadded_len > decrypted.len {
		return decrypted.bytestr()
	}
	return decrypted[..unpadded_len].bytestr()
}

fn pkcs7_pad_bytes(data []u8, block_size int) []u8 {
	mut out := data.clone()
	pad_len := block_size - (out.len % block_size)
	for _ in 0 .. pad_len {
		out << u8(pad_len)
	}
	return out
}

fn pkcs7_unpad_bytes(data []u8, block_size int) ![]u8 {
	if data.len == 0 || data.len % block_size != 0 {
		return error('invalid padded payload length')
	}
	pad_len := int(data[data.len - 1])
	if pad_len <= 0 || pad_len > block_size || pad_len > data.len {
		return error('invalid PKCS7 padding')
	}
	for i in data.len - pad_len .. data.len {
		if int(data[i]) != pad_len {
			return error('invalid PKCS7 padding bytes')
		}
	}
	return data[..data.len - pad_len].clone()
}

pub fn crypto_encrypt_aes_secure(plain_text string, key_hex string) !string {
	key := hex.decode(key_hex)!
	if key.len != 16 && key.len != 24 && key.len != 32 {
		return error('AES key must be 16, 24, or 32 bytes')
	}
	iv := crand.bytes(16)!
	block := aes.new_cipher(key)!
	mut enc := cipher.new_cbc(block, iv)
	padded := pkcs7_pad_bytes(plain_text.bytes(), 16)
	mut ciphertext := []u8{len: padded.len}
	enc.encrypt_blocks(mut ciphertext, padded)
	mut payload := []u8{}
	payload << iv
	payload << ciphertext
	return hex.encode(payload)
}

pub fn crypto_decrypt_aes_secure(payload_hex string, key_hex string) !string {
	key := hex.decode(key_hex)!
	if key.len != 16 && key.len != 24 && key.len != 32 {
		return error('AES key must be 16, 24, or 32 bytes')
	}
	payload := hex.decode(payload_hex)!
	if payload.len < 32 || payload.len % 16 != 0 {
		return error('payload must include 16-byte IV plus aligned ciphertext')
	}
	iv := payload[..16].clone()
	ciphertext := payload[16..]
	block := aes.new_cipher(key)!
	mut dec := cipher.new_cbc(block, iv)
	mut decrypted := []u8{len: ciphertext.len}
	dec.decrypt_blocks(mut decrypted, ciphertext)
	plain := pkcs7_unpad_bytes(decrypted, 16)!
	return plain.bytestr()
}

// Ed25519 Digital Signatures
pub struct SimpleEd25519KeyPair {
pub:
	pub_key  []u8
	priv_key []u8
}

pub fn crypto_ed25519_generate_key() !SimpleEd25519KeyPair {
	pub_k, priv_k := ed25519.generate_key()!
	return SimpleEd25519KeyPair{
		pub_key:  pub_k
		priv_key: priv_k
	}
}

pub fn crypto_ed25519_sign(priv_key []u8, msg string) ![]u8 {
	return ed25519.sign(priv_key, msg.bytes())!
}

pub fn crypto_ed25519_verify(pub_key []u8, msg string, sig []u8) bool {
	return ed25519.verify(pub_key, msg.bytes(), sig) or { false }
}

// PBKDF2 Key Derivation
pub fn crypto_pbkdf2(password string, salt string, iterations int, key_len int) []u8 {
	h := sha256.new()
	derived := pbkdf2.key(password.bytes(), salt.bytes(), iterations, key_len, h) or { []u8{} }
	return derived
}

// Bcrypt Password Hashing & Verification
pub fn crypto_bcrypt_hash(password string) !string {
	return bcrypt.generate_from_password(password.bytes(), bcrypt.default_cost)!
}

pub fn crypto_bcrypt_verify(password string, hash string) bool {
	bcrypt.compare_hash_and_password(password.bytes(), hash.bytes()) or { return false }
	return true
}

// Secure Random & UUID
pub fn crypto_rand_bytes(length int) []u8 {
	if length <= 0 {
		return []u8{}
	}
	return crand.bytes(length) or { return []u8{len: length} }
}

pub fn crypto_rand_hex(length int) string {
	return hex.encode(crypto_rand_bytes(length))
}

pub fn crypto_rand_uuid() string {
	mut b := crypto_rand_bytes(16)
	if b.len < 16 {
		return '00000000-0000-4000-8000-000000000000'
	}
	b[6] = (b[6] & u8(0x0f)) | u8(0x40)
	b[8] = (b[8] & u8(0x3f)) | u8(0x80)
	h := hex.encode(b)
	return '${h[0..8]}-${h[8..12]}-${h[12..16]}-${h[16..20]}-${h[20..32]}'
}

// =============================================================================
// 4. Compression (Gzip & Zlib)
// =============================================================================

pub fn compress_gzip(text string) []u8 {
	return gzip.compress(text.bytes()) or { []u8{} }
}

pub fn decompress_gzip(data []u8) string {
	decompressed := gzip.decompress(data) or { return '' }
	return decompressed.bytestr()
}

pub fn compress_zlib(text string) []u8 {
	return zlib.compress(text.bytes()) or { []u8{} }
}

pub fn decompress_zlib(data []u8) string {
	decompressed := zlib.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// =============================================================================
// 5. Random Numbers & Safe Combinatorics
// =============================================================================

pub fn rand_int(min int, max int) int {
	return rand.int_in_range(min, max) or { min }
}

pub fn rand_string(length int) string {
	return rand.string(length)
}

pub fn rand_shuffle_strings(mut arr []string) {
	for i := arr.len - 1; i > 0; i-- {
		j := rand.intn(i + 1) or { 0 }
		temp := arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	}
}

pub fn rand_choice_strings(items []string) string {
	if items.len == 0 { return '' }
	idx := rand.intn(items.len) or { 0 }
	return items[idx]
}

pub fn rand_choice_ints(items []int) int {
	if items.len == 0 { return 0 }
	idx := rand.intn(items.len) or { 0 }
	return items[idx]
}

pub fn rand_weighted_choice_strings(items []string, weights []f64) string {
	if items.len == 0 || items.len != weights.len { return '' }
	mut total := 0.0
	for w in weights { total += w }
	if total <= 0.0 { return items[0] }
	r := rand.f64_in_range(0.0, total) or { 0.0 }
	mut acc := 0.0
	for i in 0 .. items.len {
		acc += weights[i]
		if r <= acc { return items[i] }
	}
	return items.last()
}

pub fn rand_weighted_choice_ints(items []int, weights []f64) int {
	if items.len == 0 || items.len != weights.len { return 0 }
	mut total := 0.0
	for w in weights { total += w }
	if total <= 0.0 { return items[0] }
	r := rand.f64_in_range(0.0, total) or { 0.0 }
	mut acc := 0.0
	for i in 0 .. items.len {
		acc += weights[i]
		if r <= acc { return items[i] }
	}
	return items.last()
}

// =============================================================================
// 6. Concurrency Primitives (SimpleMutex & SimpleWaitGroup)
// =============================================================================

pub struct SimpleMutex {
mut:
	m sync.Mutex
}

pub fn (mut sm SimpleMutex) lock() {
	sm.m.lock()
}

pub fn (mut sm SimpleMutex) unlock() {
	sm.m.unlock()
}

pub fn new_mutex() SimpleMutex {
	return SimpleMutex{}
}

pub struct SimpleWaitGroup {
mut:
	wg sync.WaitGroup
}

pub fn (mut swg SimpleWaitGroup) add(delta int) {
	swg.wg.add(delta)
}

pub fn (mut swg SimpleWaitGroup) done() {
	swg.wg.done()
}

pub fn (mut swg SimpleWaitGroup) wait() {
	swg.wg.wait()
}

pub fn new_wait_group() SimpleWaitGroup {
	return SimpleWaitGroup{}
}

// =============================================================================
// 7. Math, Complex Numbers & Statistical Analysis
// =============================================================================

pub struct SimpleComplex {
pub mut:
	c complex.Complex
}

pub fn (sc SimpleComplex) add(other SimpleComplex) SimpleComplex {
	return SimpleComplex{ c: sc.c.add(other.c) }
}

pub fn (sc SimpleComplex) sub(other SimpleComplex) SimpleComplex {
	return SimpleComplex{ c: sc.c.subtract(other.c) }
}

pub fn (sc SimpleComplex) mul(other SimpleComplex) SimpleComplex {
	return SimpleComplex{ c: sc.c.multiply(other.c) }
}

pub fn (sc SimpleComplex) div(other SimpleComplex) SimpleComplex {
	return SimpleComplex{ c: sc.c.divide(other.c) }
}

pub fn (sc SimpleComplex) abs() f64 {
	return sc.c.abs()
}

pub fn (sc SimpleComplex) arg() f64 {
	return sc.c.arg()
}

pub fn (sc SimpleComplex) conj() SimpleComplex {
	return SimpleComplex{ c: sc.c.conjugate() }
}

pub fn (sc SimpleComplex) exp() SimpleComplex {
	return SimpleComplex{ c: sc.c.exp() }
}

pub fn (sc SimpleComplex) str() string {
	return sc.c.str()
}

pub fn complex_new(re f64, im f64) SimpleComplex {
	return SimpleComplex{ c: complex.complex(re, im) }
}

pub fn math_degrees(radians f64) f64 { return math.degrees(radians) }
pub fn math_radians(degrees f64) f64 { return math.radians(degrees) }
pub fn math_hypot(x f64, y f64) f64 { return math.hypot(x, y) }
pub fn math_gcd(a i64, b i64) i64 { return math.gcd(a, b) }
pub fn math_lcm(a i64, b i64) i64 { return math.lcm(a, b) }
pub fn math_remap(x f64, in_min f64, in_max f64, out_min f64, out_max f64) f64 {
	return math.remap(x, in_min, in_max, out_min, out_max)
}
pub fn math_smoothstep(edge0 f64, edge1 f64, x f64) f64 { return math.smoothstep(edge0, edge1, x) }
pub fn math_atan2(y f64, x f64) f64 { return math.atan2(y, x) }
pub fn math_log10(x f64) f64 { return math.log10(x) }
pub fn math_log2(x f64) f64 { return math.log2(x) }
pub fn math_round_sig(x f64, sig_digits int) f64 { return math.round_sig(x, sig_digits) }

pub struct MathStats {
pub mut:
	count    int
	mean     f64
	median   f64
	variance f64
	std_dev  f64
	min      f64
	max      f64
	sum      f64
}

pub fn calculate_stats(values []f64) !MathStats {
	if values.len == 0 {
		return error('no numbers provided')
	}
	mut sum := 0.0
	mut min := values[0]
	mut max := values[0]
	for v in values {
		sum += v
		if v < min { min = v }
		if v > max { max = v }
	}
	mean := sum / f64(values.len)
	mut sorted := values.clone()
	sorted.sort()
	mid := sorted.len / 2
	median := if sorted.len % 2 == 0 { (sorted[mid - 1] + sorted[mid]) / 2.0 } else { sorted[mid] }

	mut var_sum := 0.0
	for v in values {
		diff := v - mean
		var_sum += diff * diff
	}
	variance := var_sum / f64(values.len)
	std_dev := math.sqrt(variance)

	return MathStats{
		count: values.len
		mean: mean
		median: median
		variance: variance
		std_dev: std_dev
		min: min
		max: max
		sum: sum
	}
}

pub fn stats_geometric_mean(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.geometric_mean(data)
}

pub fn stats_harmonic_mean(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.harmonic_mean(data)
}

pub fn stats_rms(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.rms(data)
}

pub fn stats_mode(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.mode(data)
}

pub fn stats_range(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.range(data)
}

pub fn stats_kurtosis(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.kurtosis(data)
}

pub fn stats_skew(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.skew(data)
}

pub fn stats_covariance(data1 []f64, data2 []f64) f64 {
	if data1.len == 0 || data1.len != data2.len { return 0.0 }
	return stats.covariance(data1, data2)
}

// =============================================================================
// 8. String Utilities & High-Performance Builder
// =============================================================================

pub fn slugify(text string) string {
	mut res := []u8{}
	for ch in text.to_lower() {
		if (ch >= `a` && ch <= `z`) || (ch >= `0` && ch <= `9`) {
			res << ch
		} else if ch == ` ` || ch == `_` || ch == `-` {
			if res.len > 0 && res.last() != `-` {
				res << `-`
			}
		}
	}
	return res.bytestr().trim('-')
}

pub fn title_case(text string) string {
	words := text.split(' ')
	mut res := []string{}
	for w in words {
		if w.len > 0 {
			res << w[..1].to_upper() + w[1..].to_lower()
		}
	}
	return res.join(' ')
}

pub fn reverse_string(text string) string {
	return text.reverse()
}

pub fn is_palindrome(text string) bool {
	clean := text.to_lower().replace(' ', '')
	return clean == clean.reverse()
}

pub fn word_count(text string) int {
	return text.fields().len
}

pub fn utf8_len(text string) int {
	return utf8.len(text)
}

pub fn utf8_is_valid(text string) bool {
	return utf8.validate_str(text)
}

pub fn string_jaro_similarity(s1 string, s2 string) f64 {
	return strings.jaro_similarity(s1, s2)
}

pub fn string_jaro_winkler_similarity(s1 string, s2 string) f64 {
	return strings.jaro_winkler_similarity(s1, s2)
}

pub fn string_hamming_distance(s1 string, s2 string) int {
	return strings.hamming_distance(s1, s2)
}

pub fn string_between(input string, start string, end string) string {
	return strings.find_between_pair_string(input, start, end)
}

pub fn string_pad_left(input string, length int, pad_char string) string {
	if input.len >= length || pad_char.len == 0 { return input }
	pad_len := length - input.len
	mut pad := strings.repeat_string(pad_char, pad_len)
	return pad + input
}

pub fn string_pad_right(input string, length int, pad_char string) string {
	if input.len >= length || pad_char.len == 0 { return input }
	pad_len := length - input.len
	mut pad := strings.repeat_string(pad_char, pad_len)
	return input + pad
}

pub fn string_repeat(input string, count int) string {
	if count <= 0 { return '' }
	return strings.repeat_string(input, count)
}

pub fn string_count_words(input string) int {
	return input.fields().len
}

pub struct SimpleStringBuilder {
mut:
	sb strings.Builder = strings.new_builder(256)
}

pub fn (mut ssb SimpleStringBuilder) write(text string) {
	ssb.sb.write_string(text)
}

pub fn (mut ssb SimpleStringBuilder) write_line(text string) {
	ssb.sb.writeln(text)
}

pub fn (mut ssb SimpleStringBuilder) writeln(text string) {
	ssb.sb.writeln(text)
}

pub fn (mut ssb SimpleStringBuilder) str() string {
	return ssb.sb.str()
}

pub fn (ssb &SimpleStringBuilder) len() int {
	return ssb.sb.len
}

pub fn new_string_builder() SimpleStringBuilder {
	return SimpleStringBuilder{}
}

// =============================================================================
// 9. URL Parsing & Assembly
// =============================================================================

pub struct SimpleURL {
pub mut:
	scheme   string
	host     string
	port     string
	path     string
	query    map[string]string
	fragment string
}

pub fn (u SimpleURL) build_url() string {
	mut sb := strings.new_builder(128)
	if u.scheme.len > 0 {
		sb.write_string(u.scheme)
		sb.write_string('://')
	}
	sb.write_string(u.host)
	if u.port.len > 0 {
		sb.write_string(':')
		sb.write_string(u.port)
	}
	if u.path.len > 0 {
		if !u.path.starts_with('/') {
			sb.write_string('/')
		}
		sb.write_string(u.path)
	}
	if u.query.len > 0 {
		sb.write_string('?')
		mut parts := []string{}
		for k, v in u.query {
			parts << '${urllib.query_escape(k)}=${urllib.query_escape(v)}'
		}
		sb.write_string(parts.join('&'))
	}
	if u.fragment.len > 0 {
		sb.write_string('#')
		sb.write_string(u.fragment)
	}
	return sb.str()
}

pub fn url_parse(raw_url string) SimpleURL {
	u := urllib.parse(raw_url) or { return SimpleURL{} }
	mut query_map := map[string]string{}
	q_vals := u.query()
	for k in q_vals.data {
		if v := q_vals.get(k.key) {
			query_map[k.key] = v
		}
	}
	return SimpleURL{
		scheme:   u.scheme
		host:     u.hostname()
		port:     u.port()
		path:     u.path
		query:    query_map
		fragment: u.fragment
	}
}

pub fn url_build(scheme string, host string, path string, query_params map[string]string) string {
	su := SimpleURL{
		scheme: scheme
		host:   host
		path:   path
		query:  query_params
	}
	return su.build_url()
}

// =============================================================================
// 10. HTML Document Parsing & Tag Extraction
// =============================================================================

pub struct SimpleHTMLDocument {
pub mut:
	doc html.DocumentObjectModel
}

pub fn html_parse(content string) SimpleHTMLDocument {
	return SimpleHTMLDocument{
		doc: html.parse(content)
	}
}

pub fn parse_html(html_str string) SimpleHTMLDocument {
	return html_parse(html_str)
}

pub fn (d &SimpleHTMLDocument) get_tag_text(name string) string {
	tags := d.doc.get_tags(name: name)
	if tags.len > 0 {
		return tags[0].text().trim_space()
	}
	return ''
}

pub fn (d &SimpleHTMLDocument) get_tags_by_class(class_name string) []string {
	tags := d.doc.get_tags_by_class_name(class_name)
	mut res := []string{}
	for t in tags {
		res << t.text().trim_space()
	}
	return res
}

pub fn (d &SimpleHTMLDocument) get_attr(tag_name string, attr_name string) string {
	tags := d.doc.get_tags(name: tag_name)
	if tags.len > 0 {
		return tags[0].attributes[attr_name]
	}
	return ''
}

pub fn (d &SimpleHTMLDocument) get_all_links() []string {
	tags := d.doc.get_tags(name: 'a')
	mut links := []string{}
	for t in tags {
		if href := t.attributes['href'] {
			links << href
		}
	}
	return links
}

pub fn (d &SimpleHTMLDocument) get_all_images() []string {
	tags := d.doc.get_tags(name: 'img')
	mut imgs := []string{}
	for t in tags {
		if src := t.attributes['src'] {
			imgs << src
		}
	}
	return imgs
}

pub fn (d &SimpleHTMLDocument) strip_tags() string {
	root := d.doc.get_root()
	if root != unsafe { nil } {
		return root.text().trim_space()
	}
	return ''
}

// =============================================================================
// 11. CSV Parsing & Column Tools
// =============================================================================

pub fn csv_parse(content string) [][]string {
	mut r := csv.new_reader(content)
	mut rows := [][]string{}
	for {
		row := r.read() or { break }
		rows << row
	}
	return rows
}

pub fn csv_encode(rows [][]string) string {
	mut sb := strings.new_builder(256)
	for row in rows {
		mut line := []string{}
		for col in row {
			if col.contains(',') || col.contains('"') || col.contains('\n') {
				escaped := col.replace('"', '""')
				line << '"${escaped}"'
			} else {
				line << col
			}
		}
		sb.writeln(line.join(','))
	}
	return sb.str()
}

pub fn csv_extract_column(rows [][]string, col_idx int) []string {
	mut res := []string{}
	for row in rows {
		if col_idx >= 0 && col_idx < row.len {
			res << row[col_idx]
		}
	}
	return res
}

pub fn csv_filter_by_column(rows [][]string, col_idx int, search_term string) [][]string {
	mut filtered := [][]string{}
	for row in rows {
		if col_idx >= 0 && col_idx < row.len {
			if row[col_idx] == search_term {
				filtered << row
			}
		}
	}
	return filtered
}

// =============================================================================
// 12. Generic Data Collections (MinHeap, Stack, Queue, Set)
// =============================================================================

pub struct SimpleMinHeap[T] {
mut:
	heap datatypes.MinHeap[T]
}

pub fn (mut smh SimpleMinHeap[T]) push(item T) {
	smh.heap.insert(item)
}

pub fn (mut smh SimpleMinHeap[T]) pop() !T {
	return smh.heap.pop()
}

pub fn (smh &SimpleMinHeap[T]) peek() !T {
	return smh.heap.peek()
}

pub fn (smh &SimpleMinHeap[T]) len() int {
	return smh.heap.len()
}

pub fn new_min_heap[T]() SimpleMinHeap[T] {
	return SimpleMinHeap[T]{}
}

pub struct SimpleStack[T] {
mut:
	s datatypes.Stack[T]
}

pub fn (mut ss SimpleStack[T]) push(item T) {
	ss.s.push(item)
}

pub fn (mut ss SimpleStack[T]) pop() !T {
	return ss.s.pop()
}

pub fn (ss &SimpleStack[T]) peek() !T {
	return ss.s.peek()
}

pub fn (ss &SimpleStack[T]) len() int {
	return ss.s.len()
}

pub fn (ss &SimpleStack[T]) is_empty() bool {
	return ss.s.is_empty()
}

pub fn new_stack[T]() SimpleStack[T] {
	return SimpleStack[T]{}
}

pub struct SimpleQueue[T] {
mut:
	q datatypes.Queue[T]
}

pub fn (mut sq SimpleQueue[T]) push(item T) {
	sq.q.push(item)
}

pub fn (mut sq SimpleQueue[T]) pop() !T {
	return sq.q.pop()
}

pub fn (sq &SimpleQueue[T]) peek() !T {
	return sq.q.peek()
}

pub fn (sq &SimpleQueue[T]) len() int {
	return sq.q.len()
}

pub fn (sq &SimpleQueue[T]) is_empty() bool {
	return sq.q.is_empty()
}

pub fn new_queue[T]() SimpleQueue[T] {
	return SimpleQueue[T]{}
}

pub struct SimpleSet[T] {
mut:
	set datatypes.Set[T]
}

pub fn (mut ss SimpleSet[T]) add(item T) {
	ss.set.add(item)
}

pub fn (mut ss SimpleSet[T]) remove(item T) {
	ss.set.remove(item)
}

pub fn (ss &SimpleSet[T]) exists(item T) bool {
	return ss.set.exists(item)
}

pub fn (ss &SimpleSet[T]) len() int {
	return ss.set.size()
}

pub fn (ss &SimpleSet[T]) is_empty() bool {
	return ss.set.is_empty()
}

pub fn (ss &SimpleSet[T]) to_array() []T {
	return ss.set.array()
}

pub fn new_set[T]() SimpleSet[T] {
	return SimpleSet[T]{}
}

// =============================================================================
// 13. Extended Time & Calendar Utilities
// =============================================================================

pub fn time_now() string {
	return time.now().custom_format('YYYY-MM-DD HH:mm:ss')
}

pub fn time_unix_timestamp() i64 {
	return time.now().unix()
}

pub fn time_from_unix(timestamp i64) string {
	t := time.unix(timestamp)
	return t.custom_format('YYYY-MM-DD HH:mm:ss')
}

pub fn time_is_leap_year(year int) bool {
	return time.is_leap_year(year)
}

pub fn time_days_in_month(year int, month int) int {
	return time.days_in_month(month, year) or { 30 }
}

pub fn is_valid_date_str(date_str string) bool {
	parts := date_str.split('-')
	if parts.len != 3 { return false }
	if parts[0].len != 4 || parts[1].len != 2 || parts[2].len != 2 { return false }
	year := parts[0].int()
	month := parts[1].int()
	day := parts[2].int()
	if year < 1000 || year > 9999 { return false }
	if month < 1 || month > 12 { return false }
	max_days := time_days_in_month(year, month)
	if day < 1 || day > max_days { return false }
	return true
}

pub fn is_valid_time_str(time_str string) bool {
	parts := time_str.split(':')
	if parts.len != 2 { return false }
	if parts[0].len != 2 || parts[1].len != 2 { return false }
	h := parts[0].int()
	m := parts[1].int()
	return h >= 0 && h <= 23 && m >= 0 && m <= 59
}

// =============================================================================
// 14. JSON Decoding & Pretty Printing
// =============================================================================

pub fn json_validate(json_str string) bool {
	_ := json2.decode[map[string]string](json_str) or { return false }
	return true
}

pub fn json_pretty_print(json_str string) string {
	m := json2.decode[map[string]string](json_str) or { return json_str }
	mut sb := strings.new_builder(128)
	sb.writeln('{')
	mut count := 0
	for k, v in m {
		count++
		comma := if count < m.len { ',' } else { '' }
		sb.writeln('  "${k}": "${v}"${comma}')
	}
	sb.writeln('}')
	return sb.str()
}

pub fn json_decode_map(json_str string) map[string]string {
	res := json2.decode[map[string]string](json_str) or { return map[string]string{} }
	return res
}

pub fn json_decode_map_strict(json_str string) !map[string]string {
	return json2.decode[map[string]string](json_str)!
}
