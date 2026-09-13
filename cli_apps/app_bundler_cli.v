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

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}
	if additional_args.len > 0 {
		eprintln('Error: Unexpected arguments: ${additional_args.join(' ')}')
		exit(2)
	}
	if target !in ['current', 'macos', 'linux', 'windows'] {
		eprintln('Error: Unsupported target "${target}"')
		exit(2)
	}
	if name == '' || name in ['.', '..'] || name.bytes().any(!(it.is_alnum() || it in [
		`-`,
		`_`,
		`.`,
	])) {
		eprintln('Error: Application name must contain only letters, numbers, ".", "-", and "_"')
		exit(2)
	}

	if !os.is_file(entry) {
		eprintln('❌ Entry file "${entry}" does not exist or is not a regular file!')
		exit(1)
	}

	os.mkdir_all(out) or {
		eprintln('Error: Unable to create output directory "${out}": ${err}')
		exit(1)
	}

	println('====================================================================')
	println('📦 RAD STUDIO APP BUNDLER CLI')
	println('====================================================================')
	println('App Name: ${name}')
	println('Entry:    ${entry}')
	println('Output:   ${out}')
	println('Target:   ${target}')
	println('--------------------------------------------------------------------')

	$if macos {
		if target in ['current', 'macos'] {
			println('🚀 Packaging macOS .app bundle...')
			app_dir := os.join_path(out, '${name}.app')
			contents := os.join_path(app_dir, 'Contents')
			macos_dir := os.join_path(contents, 'MacOS')
			os.mkdir_all(macos_dir) or {
				eprintln('Error: Unable to create bundle directory "${macos_dir}": ${err}')
				exit(1)
			}

			bin_path := os.join_path(macos_dir, name)
			println('  Compiling macOS executable...')
			res := system.exec_safe('v', ['-prod', '-o', bin_path, entry])
			if res.exit_code != 0 {
				eprintln('❌ Compilation failed: ${res.output.trim_space()}')
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
			os.write_file(os.join_path(contents, 'Info.plist'), plist) or {
				eprintln('Error: Unable to write bundle metadata: ${err}')
				exit(1)
			}
			sign_res := system.exec_safe('codesign', ['--force', '--deep', '--sign', '-', app_dir])
			if sign_res.exit_code != 0 {
				eprintln('Error: Code signing failed: ${sign_res.output.trim_space()}')
				exit(1)
			}
			println('✅ macOS app bundle created at: ${app_dir}')
			return
		}
	}

	// Default executable compilation
	bin_ext := if target == 'windows' {
		'.exe'
	} else {
		$if windows {
			'.exe'
		} $else {
			''
		}
	}
	target_bin := os.join_path(out, '${name}${bin_ext}')
	mut compile_args := ['-prod']
	if target != 'current' {
		compile_args << ['-os', target]
	}
	compile_args << ['-o', target_bin, entry]
	println('  Compiling standalone executable for ${target}...')
	res := system.exec_safe('v', compile_args)
	if res.exit_code != 0 {
		eprintln('❌ Compilation failed: ${res.output.trim_space()}')
		exit(1)
	}
	println('✅ Standalone binary created at: ${target_bin}')
}
