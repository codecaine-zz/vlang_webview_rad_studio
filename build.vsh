import flag
import os

struct IconSize {
	name string
	size int
}

fn get_vmod_value(content string, key string) string {
	lines := content.split_into_lines()
	for line in lines {
		trimmed := line.trim_space()
		if trimmed.starts_with(key) {
			parts := trimmed.split(':')
			if parts.len >= 2 {
				val := parts[1].trim_space()
				return val.trim_left('\'"').trim_right('\',"')
			}
		}
	}
	return ''
}

fn format_app_name(raw string) string {
	mut result := []string{}
	mut cleaned := ''
	for c in raw {
		if c in [`-`, `_`, ` `] {
			cleaned += ' '
		} else {
			cleaned += c.ascii_str()
		}
	}
	for word in cleaned.split(' ') {
		if word.len > 0 {
			result << word[0..1].to_upper() + word[1..]
		}
	}
	return result.join(' ')
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('build.vsh')
	fp.version('2.0.0')
	fp.description('Cross-Platform Standalone Desktop App Builder for Vlang Webview applications')
	fp.skip_executable()

	icon := fp.string('icon', `i`, '', 'Path to input PNG icon')
	name := fp.string('name', `n`, '', 'App display name')
	identifier := fp.string('identifier', `d`, '', 'Bundle identifier (e.g. com.radstudio.app)')
	app_version := fp.string('version', `v`, '', 'App version')
	out := fp.string('out', `o`, 'dist', 'Output folder')
	target_os := fp.string('target', `t`, 'auto', 'Target OS: auto, macos, linux, windows')
	help := fp.bool('help', `h`, false, 'Show help message')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	if help {
		println(fp.usage())
		return
	}

	entry_file := if additional_args.len > 0 { additional_args[0] } else { 'main.v' }
	if !os.exists(entry_file) {
		eprintln('❌ Entry file not found: ${entry_file}')
		exit(1)
	}

	vmod_content := os.read_file('v.mod') or { '' }
	pkg_name := get_vmod_value(vmod_content, 'name')
	pkg_version := get_vmod_value(vmod_content, 'version')

	folder_name := os.base(os.getwd())
	mut raw_app_name := if name != '' {
		name
	} else if pkg_name != '' {
		pkg_name
	} else {
		folder_name
	}
	if raw_app_name == '' {
		raw_app_name = 'VlangWebviewRadStudio'
	}

	mut app_exe := ''
	for c in raw_app_name {
		if c.is_alnum() {
			app_exe += c.ascii_str()
		}
	}
	if app_exe == '' {
		app_exe = 'VlangWebviewRadStudio'
	}

	app_display_name := format_app_name(raw_app_name)
	clean_id_name := app_exe.to_lower()
	bundle_id_val := if identifier != '' { identifier } else { 'com.radstudio.${clean_id_name}' }
	version_val := if app_version != '' {
		app_version
	} else if pkg_version != '' {
		pkg_version
	} else {
		'2.0.0'
	}
	out_folder := os.real_path(out)

	mut target := target_os
	if target == 'auto' {
		$if macos {
			target = 'macos'
		} $else $if windows {
			target = 'windows'
		} $else {
			target = 'linux'
		}
	}

	println('====================================================================')
	println('🚀 Vlang Webview Cross-Platform Desktop Builder')
	println('====================================================================')
	println('  Entry point:   ${entry_file}')
	println('  App Name:      ${app_display_name}')
	println('  Executable:    ${app_exe}')
	println('  Bundle ID:     ${bundle_id_val}')
	println('  Version:       ${version_val}')
	println('  Target OS:     ${target}')
	println('  Output Path:   ${out_folder}')

	os.mkdir_all(out_folder) or {
		eprintln('❌ Failed to create output directory: ${err}')
		exit(1)
	}

	mut icon_source := ''
	mut icon_search_paths := []string{}
	if icon != '' {
		icon_search_paths << os.real_path(icon)
	}
	icon_search_paths << os.join_path(os.getwd(), 'resources', 'icon.png')
	icon_search_paths << os.join_path(os.getwd(), 'icon.png')

	for path in icon_search_paths {
		if os.exists(path) {
			icon_source = path
			break
		}
	}

	sources := if entry_file == 'main.v' && os.exists('rad_engine.v') {
		'.'
	} else {
		os.quoted_path(entry_file)
	}

	if target == 'macos' {
		app_dir := os.join_path(out_folder, '${app_display_name}.app')
		contents_dir := os.join_path(app_dir, 'Contents')
		macos_dir := os.join_path(contents_dir, 'MacOS')
		resources_dir := os.join_path(contents_dir, 'Resources')
		iconset_dir := os.join_path(out_folder, '${app_exe}_icon.iconset')

		if os.exists(app_dir) {
			println('🧹 Cleaning previous app bundle...')
			os.rmdir_all(app_dir) or {}
		}

		os.mkdir_all(macos_dir) or {}
		os.mkdir_all(resources_dir) or {}

		println('📦 Compiling production binary into macOS bundle...')
		binary_path := os.join_path(macos_dir, app_exe)
		compile_cmd := 'v -prod -o ${os.quoted_path(binary_path)} ${sources}'
		println('  Running: ${compile_cmd}')
		res := os.execute(compile_cmd)
		if res.exit_code != 0 {
			eprintln('❌ Compilation failed: ${res.output}')
			exit(1)
		}
		os.execute('chmod +x ${os.quoted_path(binary_path)}')

		if icon_source != '' {
			println('🎨 Processing and packaging app icon from ${icon_source}...')
			os.mkdir_all(iconset_dir) or {}
			icon_sizes := [
				IconSize{ name: 'icon_16x16.png', size: 16 },
				IconSize{ name: 'icon_16x16@2x.png', size: 32 },
				IconSize{ name: 'icon_32x32.png', size: 32 },
				IconSize{ name: 'icon_32x32@2x.png', size: 64 },
				IconSize{ name: 'icon_128x128.png', size: 128 },
				IconSize{ name: 'icon_128x128@2x.png', size: 256 },
				IconSize{ name: 'icon_256x256.png', size: 256 },
				IconSize{ name: 'icon_256x256@2x.png', size: 512 },
				IconSize{ name: 'icon_512x512.png', size: 512 },
				IconSize{ name: 'icon_512x512@2x.png', size: 1024 },
			]
			for isz in icon_sizes {
				out_p := os.join_path(iconset_dir, isz.name)
				os.execute('sips -s format png -z ${isz.size} ${isz.size} ${os.quoted_path(icon_source)} --out ${os.quoted_path(out_p)}')
			}
			icns_path := os.join_path(resources_dir, 'AppIcon.icns')
			os.execute('iconutil -c icns ${os.quoted_path(iconset_dir)} -o ${os.quoted_path(icns_path)}')
			os.rmdir_all(iconset_dir) or {}
		}

		println('📝 Writing Info.plist...')
		plist := '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.txt">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>${app_exe}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>${bundle_id_val}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${app_display_name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${version_val}</string>
    <key>CFBundleVersion</key>
    <string>${version_val}</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>'
		os.write_file(os.join_path(contents_dir, 'Info.plist'), plist) or {}

		println('🔐 Code signing macOS app bundle...')
		os.execute('codesign --force --deep --sign - ${os.quoted_path(app_dir)}')
		os.execute('xattr -cr ${os.quoted_path(app_dir)}')
		println('\n🎉 Success! macOS .app bundle created at: ${app_dir}')

	} else if target == 'windows' {
		println('📦 Compiling Windows standalone binary...')
		out_exe := os.join_path(out_folder, '${app_exe}.exe')
		cmd := 'v -prod -os windows -o ${os.quoted_path(out_exe)} ${sources}'
		println('  Running: ${cmd}')
		res := os.execute(cmd)
		if res.exit_code != 0 {
			eprintln('❌ Compilation failed: ${res.output}')
			exit(1)
		}
		println('\n🎉 Success! Windows binary created at: ${out_exe}')

	} else {
		// Linux ELF binary
		println('📦 Compiling Linux standalone binary...')
		out_bin := os.join_path(out_folder, app_exe)
		cmd := 'v -prod -o ${os.quoted_path(out_bin)} ${sources}'
		println('  Running: ${cmd}')
		res := os.execute(cmd)
		if res.exit_code != 0 {
			eprintln('❌ Compilation failed: ${res.output}')
			exit(1)
		}
		desktop_file := '[Desktop Entry]
Name=${app_display_name}
Exec=${app_exe}
Icon=${clean_id_name}
Type=Application
Categories=Development;IDE;
'
		os.write_file(os.join_path(out_folder, '${clean_id_name}.desktop'), desktop_file) or {}
		println('\n🎉 Success! Linux executable created at: ${out_bin}')
	}
	println('====================================================================')
}
