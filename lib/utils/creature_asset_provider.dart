import 'package:flutter/material.dart';
import '../models/creature.dart';

/// Provides creature asset paths with intelligent fallback system
///
/// Asset Hierarchy:
/// 1. Optimized WebP assets (preferred)
/// 2. Raw PNG assets (if WebP not available)
/// 3. Biome-specific placeholder
/// 4. Rarity-specific placeholder
/// 5. Generic creature placeholder
class CreatureAssetProvider {
  /// Base paths for creature assets
  static const String _optimizedBasePath = 'assets/creatures/optimized';
  static const String _rawBasePath = 'assets/creatures/raw';
  static const String _placeholdersPath = 'assets/creatures/placeholders';

  /// Get the asset path for a creature with fallback system
  ///
  /// Priority order:
  /// 1. assets/creatures/optimized/{biome}/{rarity}/{id}_{name}.webp
  /// 2. assets/creatures/raw/{biome}/{rarity}/{id}_{name}.png
  /// 3. assets/creatures/placeholders/{biome}.webp
  /// 4. assets/creatures/placeholders/{rarity}.webp
  /// 5. assets/creatures/placeholders/default.webp
  static String getAssetPath(Creature creature, {bool preferOptimized = true}) {
    final biome = _getBiomeFolder(creature.habitat);
    final rarity = _getRarityFolder(creature.rarity);
    final id = creature.id;
    final name = creature.name.toLowerCase().replaceAll(' ', '_');

    // Return path (actual checking happens in widget with AssetImage)
    if (preferOptimized) {
      return '$_optimizedBasePath/$biome/$rarity/${id}_$name.webp';
    } else {
      return '$_rawBasePath/$biome/$rarity/${id}_$name.png';
    }
  }

  /// Get all possible fallback paths for an asset
  static List<String> getFallbackPaths(Creature creature) {
    final biome = _getBiomeFolder(creature.habitat);
    final rarity = _getRarityFolder(creature.rarity);
    final id = creature.id;
    final name = creature.name.toLowerCase().replaceAll(' ', '_');

    final paths = [
      '$_optimizedBasePath/$biome/$rarity/${id}_$name.webp',
    ];

    return paths;
  }

  /// Get biome folder name from BiomeType
  static String _getBiomeFolder(BiomeType biome) {
    switch (biome) {
      case BiomeType.shallowWaters:
        return 'shallow_waters';
      case BiomeType.coralGarden:
        return 'coral_garden';
      case BiomeType.deepOcean:
        return 'deep_ocean';
      case BiomeType.abyssalZone:
        return 'abyssal_zone';
    }
  }

  /// Get rarity folder name from CreatureRarity
  static String _getRarityFolder(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'common';
      case CreatureRarity.uncommon:
        return 'uncommon';
      case CreatureRarity.rare:
        return 'rare';
      case CreatureRarity.legendary:
        return 'legendary';
    }
  }

  /// Build an image widget with automatic fallback
  static Widget buildCreatureImage({
    required Creature creature,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool showPlaceholder = true,
  }) {
    return _FallbackImage(
      creature: creature,
      width: width,
      height: height,
      fit: fit,
      showPlaceholder: showPlaceholder,
    );
  }
}

/// Internal widget that handles fallback logic
class _FallbackImage extends StatefulWidget {
  final Creature creature;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showPlaceholder;

  const _FallbackImage({
    required this.creature,
    this.width,
    this.height,
    required this.fit,
    required this.showPlaceholder,
  });

  @override
  State<_FallbackImage> createState() => _FallbackImageState();
}

class _FallbackImageState extends State<_FallbackImage> {
  int _currentFallbackIndex = 0;
  List<String> _fallbackPaths = [];

  @override
  void initState() {
    super.initState();
    _fallbackPaths = CreatureAssetProvider.getFallbackPaths(widget.creature);
  }

  void _tryNextFallback() {
    if (_currentFallbackIndex < _fallbackPaths.length - 1) {
      setState(() {
        _currentFallbackIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFallbackIndex >= _fallbackPaths.length) {
      // All fallbacks exhausted - show emoji placeholder
      return _buildEmojiPlaceholder();
    }

    final currentPath = _fallbackPaths[_currentFallbackIndex];

    return Image.asset(
      currentPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {

        // Try next fallback on error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryNextFallback();
        });

        // Return emoji placeholder while trying fallbacks
        return _buildEmojiPlaceholder();
      },
      // Optional: show loading indicator
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }

  Widget _buildEmojiPlaceholder() {
    if (!widget.showPlaceholder) {
      return const SizedBox.shrink();
    }

    // Use biome-appropriate emoji as final fallback
    String emoji = _getCreatureEmoji(widget.creature.habitat);
    Color backgroundColor = _getRarityColor(widget.creature.rarity).withValues(alpha: 0.1);

    // Calculate safe font size (handle infinity width/height)
    double safeFontSize = 40.0; // Default emoji size
    if (widget.width != null && widget.width!.isFinite) {
      safeFontSize = widget.width! * 0.5;
    } else if (widget.height != null && widget.height!.isFinite) {
      safeFontSize = widget.height! * 0.5;
    }

    return Container(
      width: widget.width?.isFinite == true ? widget.width : null,
      height: widget.height?.isFinite == true ? widget.height : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: safeFontSize.clamp(20.0, 60.0), // Clamp between 20-60px
          ),
        ),
      ),
    );
  }

  String _getCreatureEmoji(BiomeType habitat) {
    switch (habitat) {
      case BiomeType.shallowWaters:
        return '🐠';
      case BiomeType.coralGarden:
        return '🐟';
      case BiomeType.deepOcean:
        return '🦈';
      case BiomeType.abyssalZone:
        return '🐙';
    }
  }

  Color _getRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return Colors.green;
      case CreatureRarity.uncommon:
        return Colors.blue;
      case CreatureRarity.rare:
        return Colors.purple;
      case CreatureRarity.legendary:
        return Colors.orange;
    }
  }
}