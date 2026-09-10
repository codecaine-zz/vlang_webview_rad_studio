#!/usr/bin/env -S v run

import os

fn main() {
	webview_dir := os.dir(@FILE)
	os.chdir(webview_dir) or {
		eprintln('Failed to chdir to ${webview_dir}')
		exit(1)
	}

	$if darwin {
		println('Compiling webview for macOS (Universal binary: arm64 + x86_64)...')
		res1 := os.execute('clang++ -arch arm64 -arch x86_64 -c webview.cc -DWEBVIEW_STATIC -std=c++11 -o webview_darwin.o')
		if res1.exit_code != 0 {
			println('Universal build failed, falling back to host arch...')
			res_fallback := os.execute('clang++ -c webview.cc -DWEBVIEW_STATIC -std=c++11 -o webview_darwin.o')
			if res_fallback.exit_code != 0 {
				eprintln('Failed to compile webview_darwin.o:\n${res_fallback.output}')
				exit(1)
			}
		}
		res2 := os.execute('clang -arch arm64 -arch x86_64 -c window_helper.m -o window_helper_darwin.o')
		if res2.exit_code != 0 {
			res_fallback2 := os.execute('clang -c window_helper.m -o window_helper_darwin.o')
			if res_fallback2.exit_code != 0 {
				eprintln('Failed to compile window_helper_darwin.o:\n${res_fallback2.output}')
				exit(1)
			}
		}
		println('✅ macOS webview object files built successfully.')
	} $else $if linux {
		println('Compiling webview for Linux...')
		gtk_cflags := os.execute('pkg-config --cflags gtk+-3.0 webkit2gtk-4.1 2>/dev/null || pkg-config --cflags gtk+-3.0 webkit2gtk-4.0')
		if gtk_cflags.exit_code != 0 {
			eprintln('Failed to find GTK3 / WebKit2GTK headers via pkg-config.')
			exit(1)
		}
		cmd1 := 'g++ -c webview.cc ${gtk_cflags.output.trim_space()} -DWEBVIEW_STATIC -std=c++17 -o webview_linux.o'
		res1 := os.execute(cmd1)
		if res1.exit_code != 0 {
			eprintln('Failed to compile webview_linux.o:\n${res1.output}')
			exit(1)
		}

		gtk_only := os.execute('pkg-config --cflags gtk+-3.0')
		cmd2 := 'gcc -c window_helper_linux.c ${gtk_only.output.trim_space()} -o window_helper_linux.o'
		res2 := os.execute(cmd2)
		if res2.exit_code != 0 {
			eprintln('Failed to compile window_helper_linux.o:\n${res2.output}')
			exit(1)
		}
		println('✅ Linux webview object files built successfully.')
	} $else {
		println('Target OS not handled by this script.')
	}
}
