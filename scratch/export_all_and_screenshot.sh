#!/usr/bin/env bash
set -e

mkdir -p scratch/html
mkdir -p resources/screenshots

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
BASE_DIR="$(pwd)"

echo "=== 1. Capturing Screenshots for all 16 Applications ==="
for app in applications/*.v; do
    name=$(basename "$app" .v)
    html_file="scratch/html/${name}.html"
    png_file="resources/screenshots/app_${name}.png"
    echo "Processing Application: $name..."
    SIMPLEGUI_EXPORT_HTML="$html_file" v run "$app"
    "$CHROME" --headless --disable-gpu --screenshot="$png_file" --window-size=1150,850 "file://${BASE_DIR}/${html_file}" 2>/dev/null || true
    echo "Captured: $png_file"
done

echo "=== 2. Capturing Screenshots for all 24 Demos ==="
for demo in demos/*.v; do
    name=$(basename "$demo" .v)
    html_file="scratch/html/${name}.html"
    png_file="resources/screenshots/demo_${name}.png"
    echo "Processing Demo: $name..."
    SIMPLEGUI_EXPORT_HTML="$html_file" v run "$demo"
    "$CHROME" --headless --disable-gpu --screenshot="$png_file" --window-size=1150,850 "file://${BASE_DIR}/${html_file}" 2>/dev/null || true
    echo "Captured: $png_file"
done

echo "=== 3. Capturing Visual RAD Studio IDE ==="
"$CHROME" --headless --disable-gpu --screenshot="resources/screenshots/rad_studio_ide.png" --window-size=1280,880 "file://${BASE_DIR}/resources/ide.html" 2>/dev/null || true

echo "=== All screenshots captured successfully! ==="
