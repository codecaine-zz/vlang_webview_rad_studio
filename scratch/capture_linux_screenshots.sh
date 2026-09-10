#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$project_root/resources/screenshots/linux"
v_bin="${V_BIN:-$(command -v v)}"

if ! command -v gnome-screenshot >/dev/null; then
	echo "Install the Wayland-aware screenshot utility first: sudo apt-get install -y gnome-screenshot" >&2
	exit 1
fi

mkdir -p "$output_dir"

capture_window() {
	local source_file="$1"
	local output_file="$2"
	local executable="/tmp/rad_linux_capture_${output_file%.png}"
	local log_file="${executable}.log"

	env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
		PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
		"$v_bin" -o "$executable" "$source_file"

	env -u PKG_CONFIG_PATH -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_SYSROOT_DIR -u LD_LIBRARY_PATH \
		"$executable" >"$log_file" 2>&1 &
	local application_pid=$!

	gnome-screenshot --window --delay=3 --file="$output_dir/$output_file"
	if ! kill -0 "$application_pid" 2>/dev/null; then
		sed -n '1,120p' "$log_file" >&2
		echo "Application exited before its screenshot was captured: $source_file" >&2
		exit 1
	fi
	kill "$application_pid" 2>/dev/null || true
	wait "$application_pid" 2>/dev/null || true
	test -s "$output_dir/$output_file"
}

cd "$project_root"
for source_file in demos/*.v; do
	file_name="$(basename "${source_file%.v}")"
	capture_window "$source_file" "demo_${file_name}.png"
done

for source_file in applications/*.v; do
	file_name="$(basename "${source_file%.v}")"
	capture_window "$source_file" "app_${file_name}.png"
done

echo "Linux screenshots written to $output_dir"