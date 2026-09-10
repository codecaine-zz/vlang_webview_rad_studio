module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('app_bundler_cli')
	fp.version('2.0.0')
	fp.description('Cross-Platform Application Bundler & Packager CLI')
	fp.skip_executable()

	name := fp.string('name', `n`, 'MyApp', 'Application Name')
	entry := fp.string('entry', `e`, 'main.v', 'Entry point V file')
	out := fp.string('out', `o`, 'dist', 'Output directory')
	target := fp.string('target', `t`, 'current', 'Target OS: current, macos, linux, windows')

	_ := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	println('====================================================================')
	println('📦 RAD STUDIO APP BUNDLER CLI')
	println('====================================================================')
	println('App Name: ${name}')
	println('Entry:    ${entry}')
	println('Output:   ${out}')
	println('Target:   ${target}')
	println('--------------------------------------------------------------------')

	if !os.exists(entry) {
		eprintln('❌ Entry file "${entry}" does not exist!')
		exit(1)
	}

	os.mkdir_all(out) or {}

	$if macos {
		if target in ['current', 'macos'] {
			println('🚀 Packaging macOS .app bundle...')
			app_dir := os.join_path(out, '${name}.app')
			contents := os.join_path(app_dir, 'Contents')
			macos_dir := os.join_path(contents, 'MacOS')
			os.mkdir_all(macos_dir) or {}

			bin_path := os.join_path(macos_dir, name)
			cmd := 'v -prod -o "${bin_path}" "${entry}"'
			println('  Compiling: ${cmd}')
			out_str, code := system.exec(cmd)
			if code != 0 {
				eprintln('❌ Compilation failed: ${out_str}')
				exit(1)
			}

			plist := '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.txt">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${name}</string>
    <key>CFBundleIdentifier</key>
    <string>com.radstudio.${name.to_lower()}</string>
    <key>CFBundleName</key>
    <string>${name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13.0</string>
</dict>
</plist>'
			os.write_file(os.join_path(contents, 'Info.plist'), plist) or {}
			system.exec('codesign --force --deep --sign - "${app_dir}"')
			println('✅ macOS app bundle created at: ${app_dir}')
			return
		}
	}

	// Default executable compilation
	bin_ext := $if windows { '.exe' } $else { '' }
	target_bin := os.join_path(out, '${name}${bin_ext}')
	cmd := 'v -prod -o "${target_bin}" "${entry}"'
	println('  Compiling standalone executable: ${cmd}')
	out_str, code := system.exec(cmd)
	if code != 0 {
		eprintln('❌ Compilation failed: ${out_str}')
		exit(1)
	}
	println('✅ Standalone binary created at: ${target_bin}')
}
