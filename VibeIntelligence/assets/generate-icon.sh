#!/bin/bash
# Generate PNG icons from SVG
# Requires: Inkscape or rsvg-convert

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SVG_FILE="$SCRIPT_DIR/icon.svg"
OUTPUT_DIR="$SCRIPT_DIR"

# Check for conversion tools
if command -v rsvg-convert &>/dev/null; then
    CONVERTER="rsvg-convert"
elif command -v inkscape &>/dev/null; then
    CONVERTER="inkscape"
elif command -v convert &>/dev/null; then
    CONVERTER="imagemagick"
else
    echo "Error: No SVG converter found."
    echo "Install one of: librsvg, inkscape, or imagemagick"
    exit 1
fi

echo "Using converter: $CONVERTER"

# Generate different sizes
sizes=(16 32 64 128 256 512 1024)

for size in "${sizes[@]}"; do
    output="$OUTPUT_DIR/icon_${size}x${size}.png"
    
    case "$CONVERTER" in
        rsvg-convert)
            rsvg-convert -w "$size" -h "$size" "$SVG_FILE" -o "$output"
            ;;
        inkscape)
            inkscape -w "$size" -h "$size" "$SVG_FILE" -o "$output"
            ;;
        imagemagick)
            convert -background none -resize "${size}x${size}" "$SVG_FILE" "$output"
            ;;
    esac
    
    echo "Generated: $output"
done

# Create main icon.png (512x512)
cp "$OUTPUT_DIR/icon_512x512.png" "$OUTPUT_DIR/icon.png" 2>/dev/null || true

# macOS: Create .icns file if iconutil is available
if command -v iconutil &>/dev/null; then
    iconset="$OUTPUT_DIR/icon.iconset"
    mkdir -p "$iconset"
    
    cp "$OUTPUT_DIR/icon_16x16.png" "$iconset/icon_16x16.png"
    cp "$OUTPUT_DIR/icon_32x32.png" "$iconset/icon_16x16@2x.png"
    cp "$OUTPUT_DIR/icon_32x32.png" "$iconset/icon_32x32.png"
    cp "$OUTPUT_DIR/icon_64x64.png" "$iconset/icon_32x32@2x.png"
    cp "$OUTPUT_DIR/icon_128x128.png" "$iconset/icon_128x128.png"
    cp "$OUTPUT_DIR/icon_256x256.png" "$iconset/icon_128x128@2x.png"
    cp "$OUTPUT_DIR/icon_256x256.png" "$iconset/icon_256x256.png"
    cp "$OUTPUT_DIR/icon_512x512.png" "$iconset/icon_256x256@2x.png"
    cp "$OUTPUT_DIR/icon_512x512.png" "$iconset/icon_512x512.png"
    cp "$OUTPUT_DIR/icon_1024x1024.png" "$iconset/icon_512x512@2x.png"
    
    iconutil -c icns "$iconset" -o "$OUTPUT_DIR/icon.icns"
    rm -rf "$iconset"
    
    echo "Generated: $OUTPUT_DIR/icon.icns"
fi

echo "Done!"
