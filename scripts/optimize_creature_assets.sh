#!/bin/bash

# Creature Asset Optimization Script
# Converts PNG images to WebP format with high quality compression
# Reduces app size by 30-50% while maintaining visual quality

set -e

echo "🐠 FlowPulse Creature Asset Optimization Script"
echo "=============================================="

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "❌ Error: cwebp is not installed"
    echo "Install with: brew install webp"
    exit 1
fi

# Directories
RAW_DIR="assets/creatures/raw"
OPTIMIZED_DIR="assets/creatures/optimized"

# Create optimized directory structure
echo "📁 Creating optimized asset directories..."
mkdir -p "$OPTIMIZED_DIR"

# Function to optimize a single PNG file
optimize_image() {
    local input_file="$1"
    local relative_path="${input_file#$RAW_DIR/}"
    local output_file="$OPTIMIZED_DIR/${relative_path%.png}.webp"
    local output_dir=$(dirname "$output_file")

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Get original file size
    local original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    local original_size_kb=$((original_size / 1024))

    # Convert to WebP with high quality (quality=85, method=6 for best compression)
    cwebp -q 85 -m 6 -af -mt "$input_file" -o "$output_file" > /dev/null 2>&1

    # Get new file size
    local new_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
    local new_size_kb=$((new_size / 1024))
    local reduction=$((100 - (new_size * 100 / original_size)))

    echo "  ✓ $(basename "$input_file") → $(basename "$output_file")"
    echo "    ${original_size_kb}KB → ${new_size_kb}KB (${reduction}% reduction)"
}

# Find and process all PNG files
echo ""
echo "🔄 Processing creature assets..."
echo ""

total_original=0
total_optimized=0
file_count=0

while IFS= read -r -d '' png_file; do
    optimize_image "$png_file"

    # Track totals
    original_size=$(stat -f%z "$png_file" 2>/dev/null || stat -c%s "$png_file" 2>/dev/null)
    relative_path="${png_file#$RAW_DIR/}"
    optimized_file="$OPTIMIZED_DIR/${relative_path%.png}.webp"
    optimized_size=$(stat -f%z "$optimized_file" 2>/dev/null || stat -c%s "$optimized_file" 2>/dev/null)

    total_original=$((total_original + original_size))
    total_optimized=$((total_optimized + optimized_size))
    file_count=$((file_count + 1))
done < <(find "$RAW_DIR" -type f -name "*.png" -print0)

# Calculate totals
total_original_mb=$((total_original / 1024 / 1024))
total_optimized_mb=$((total_optimized / 1024 / 1024))
total_reduction=$((100 - (total_optimized * 100 / total_original)))

echo ""
echo "=============================================="
echo "✅ Optimization Complete!"
echo "=============================================="
echo "Files processed: $file_count"
echo "Original size:   ${total_original_mb}MB"
echo "Optimized size:  ${total_optimized_mb}MB"
echo "Total reduction: ${total_reduction}%"
echo "Saved:           $((total_original_mb - total_optimized_mb))MB"
echo ""
echo "📝 Next steps:"
echo "1. Review optimized images in: $OPTIMIZED_DIR"
echo "2. Update pubspec.yaml to reference optimized assets"
echo "3. Delete raw assets if satisfied with quality"
echo ""