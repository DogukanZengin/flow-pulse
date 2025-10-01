# Creature Assets Directory

This directory contains all creature images for FlowPulse, organized by biome and rarity.

## Directory Structure

```
assets/creatures/
├── raw/                    # Original PNG files (1MB+ each)
│   ├── shallow_waters/
│   │   ├── common/
│   │   ├── uncommon/
│   │   ├── rare/
│   │   └── legendary/
│   ├── coral_garden/
│   ├── deep_ocean/
│   └── abyssal_zone/
├── optimized/              # WebP optimized files (30-50% smaller)
│   └── [same structure as raw/]
└── placeholders/           # Fallback placeholder images
    ├── shallow_waters.webp
    ├── coral_garden.webp
    ├── deep_ocean.webp
    ├── abyssal_zone.webp
    └── default.webp
```

## File Naming Convention

All creature assets follow this naming pattern:
- `{biome_prefix}_{number}_{creature_name}.{ext}`
- Example: `sw_001_clownfish.png`

### Biome Prefixes:
- `sw_` = Shallow Waters
- `cg_` = Coral Garden
- `do_` = Deep Ocean
- `az_` = Abyssal Zone

## Asset Optimization

### Step 1: Add Raw Assets
Place original PNG files in the appropriate `raw/{biome}/{rarity}/` directory.

### Step 2: Run Optimization Script
```bash
cd /path/to/flow_pulse
./scripts/optimize_creature_assets.sh
```

This script will:
- Convert PNG → WebP with 85% quality
- Use advanced compression (method=6)
- Reduce file sizes by 30-50% without visible quality loss
- Maintain original directory structure in `optimized/`

### Step 3: Review Results
- Check optimized images in `assets/creatures/optimized/`
- Original files remain in `raw/` for backup
- App will automatically use WebP versions when available

## Image Requirements

### Recommended Specifications:
- **Format**: PNG (will be converted to WebP)
- **Size**: 512x512px or 1024x1024px
- **Background**: Transparent
- **Style**: Consistent art style across all creatures
- **Quality**: High-resolution source files

### File Size Guidelines:
- Raw PNG: 500KB - 1.5MB per file
- Optimized WebP: 150KB - 500KB per file
- Total raw assets: ~43MB (current shallow waters only)
- Total optimized: ~15-20MB (after WebP conversion)

## Fallback System

The app uses a 6-level fallback hierarchy:

1. **Optimized WebP** - `optimized/{biome}/{rarity}/{id}.webp`
2. **Raw PNG** - `raw/{biome}/{rarity}/{id}.png`
3. **Biome+Rarity Placeholder** - `placeholders/{biome}_{rarity}.webp`
4. **Biome Placeholder** - `placeholders/{biome}.webp`
5. **Rarity Placeholder** - `placeholders/{rarity}.webp`
6. **Emoji Fallback** - Uses biome-appropriate emoji

This ensures the app always has something to display, even if specific creature assets are missing.

## Adding New Creatures

1. Generate or acquire creature image (512x512px, transparent PNG)
2. Name according to convention: `{prefix}_{number}_{name}.png`
3. Place in `raw/{biome}/{rarity}/` directory
4. Run optimization script: `./scripts/optimize_creature_assets.sh`
5. Run `flutter pub get` to register new assets
6. Test in app to verify display

## Tools Used

- **cwebp**: Google's WebP encoder
- **Install**: `brew install webp` (macOS)
- **Documentation**: https://developers.google.com/speed/webp

## Performance Impact

### Before Optimization (PNG only):
- 43MB for 37 shallow water creatures
- Estimated 172MB for all 144 creatures
- Slower load times, higher memory usage

### After Optimization (WebP):
- ~15MB for 37 shallow water creatures
- Estimated ~60MB for all 144 creatures
- **60% reduction in app size**
- Faster loading, lower memory footprint
- No perceptible quality loss

## Current Status

✅ Shallow Waters: 37 creatures (raw PNGs available)
⏳ Coral Garden: 0 creatures (coming soon)
⏳ Deep Ocean: 0 creatures (coming soon)
⏳ Abyssal Zone: 0 creatures (coming soon)

**Total**: 37/144 creatures (26%)

## Notes

- WebP format is supported on iOS 14+, Android 4.0+
- Flutter has built-in WebP support
- Raw PNG files can be deleted after verifying WebP quality
- Placeholders use biome colors and emoji for visual consistency