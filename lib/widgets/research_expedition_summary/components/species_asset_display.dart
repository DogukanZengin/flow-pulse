import 'package:flutter/material.dart';
import '../../../models/creature.dart';
import '../utils/biome_color_inheritance.dart';

/// Species asset display framework that gracefully handles image loading
/// with intelligent fallbacks and biome-aware styling.
///
/// Fallback hierarchy (from best to basic):
/// 1. Specific species images when available
/// 2. Default biome/type images when species assets missing
/// 3. Silhouette fallbacks for undiscovered species
/// 4. Biome-themed icons when all images fail
/// 5. Text-only mode for complete fallback
class SpeciesAssetDisplay extends StatefulWidget {
  final Creature? creature;
  final double? width;
  final double? height;
  final SpeciesDisplayMode displayMode;
  final bool showRarityIndicator;
  final bool showName;
  final Color? overrideColor;
  final String? defaultImagePath;
  final bool useDefaultImageFallback;

  const SpeciesAssetDisplay({
    super.key,
    this.creature,
    this.width,
    this.height,
    this.displayMode = SpeciesDisplayMode.adaptive,
    this.showRarityIndicator = true,
    this.showName = false,
    this.overrideColor,
    this.defaultImagePath,
    this.useDefaultImageFallback = true,
  });

  @override
  State<SpeciesAssetDisplay> createState() => _SpeciesAssetDisplayState();
}

class _SpeciesAssetDisplayState extends State<SpeciesAssetDisplay>
    with SingleTickerProviderStateMixin {

  AssetLoadingState _loadingState = AssetLoadingState.loading;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAsset();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadAsset() {
    if (widget.creature == null) {
      setState(() {
        _loadingState = AssetLoadingState.noCreature;
      });
      return;
    }

    final creature = widget.creature!;

    // Try to load specific species asset first
    final specificAssetPath = _getSpeciesAssetPath(creature);

    // Simulate asset loading (in real app, this would check if asset exists)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (specificAssetPath.isNotEmpty && _assetExists(specificAssetPath)) {
          setState(() {
            _loadingState = AssetLoadingState.loaded;
          });
        } else if (widget.useDefaultImageFallback) {
          // Try default image fallback
          final defaultPath = _getDefaultImagePath(creature);
          if (defaultPath.isNotEmpty && _assetExists(defaultPath)) {
            setState(() {
              _loadingState = AssetLoadingState.loadedDefault;
            });
          } else {
            setState(() {
              _loadingState = AssetLoadingState.failed;
            });
          }
        } else {
          setState(() {
            _loadingState = AssetLoadingState.failed;
          });
        }
      }
    });
  }

  String _getSpeciesAssetPath(Creature creature) {
    // Asset naming convention: assets/species/{biome}/{rarity}/{creature_id}.png
    final biomeName = creature.habitat.name.toLowerCase();
    final rarityName = creature.rarity.name.toLowerCase();

    // Try multiple asset path strategies
    final possiblePaths = [
      'assets/species/$biomeName/$rarityName/${creature.id}.png',
      'assets/species/$biomeName/${creature.id}.png',
      'assets/species/${creature.id}.png',
      'assets/creatures/${creature.animationAsset}', // Use existing animation asset
    ];

    // Return first non-empty path (in real app, would validate existence)
    return possiblePaths.firstWhere(
      (path) => path.isNotEmpty && !path.contains('null'),
      orElse: () => '',
    );
  }

  String _getDefaultImagePath(Creature creature) {
    if (widget.defaultImagePath != null) {
      return widget.defaultImagePath!;
    }

    // Fallback to biome/type-based default images
    final biomeName = creature.habitat.name.toLowerCase();
    final typeName = creature.type.name.toLowerCase();

    final possibleDefaults = [
      'assets/defaults/$biomeName/$typeName.png',
      'assets/defaults/$biomeName/generic.png',
      'assets/defaults/generic_creature.png',
    ];

    return possibleDefaults.firstWhere(
      (path) => path.isNotEmpty,
      orElse: () => '',
    );
  }

  bool _assetExists(String path) {
    // In real implementation, this would check if the asset file exists
    // For now, return false to trigger fallback to silhouette
    // (since we don't have actual image assets yet)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final creature = widget.creature;
    final effectiveWidth = widget.width ?? 120.0;
    final effectiveHeight = widget.height ?? 120.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
                width: effectiveWidth,
                height: effectiveHeight,
                decoration: _buildContainerDecoration(creature),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main species display
                    Center(child: _buildSpeciesContent(creature, effectiveWidth, effectiveHeight)),

                    // Rarity indicator
                    if (widget.showRarityIndicator && creature != null)
                      _buildRarityIndicator(creature),

                    // Note: Discovery status indicator removed since expedition summary
                    // only shows discovered creatures
                  ],
                ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildContainerDecoration(Creature? creature) {
    final biomeColor = creature != null
        ? BiomeColorInheritance.getBiomeAccentColor(creature.habitat)
        : const Color(0xFF4682B4);

    final effectiveColor = widget.overrideColor ?? biomeColor;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          effectiveColor.withValues(alpha: 0.1),
          effectiveColor.withValues(alpha: 0.05),
        ],
      ),
      border: Border.all(
        color: effectiveColor.withValues(alpha: 0.3),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: effectiveColor.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSpeciesContent(Creature? creature, double width, double height) {
    switch (_loadingState) {
      case AssetLoadingState.loading:
        return _buildLoadingState(width, height);

      case AssetLoadingState.loaded:
        return _buildImageDisplay(creature!, width, height);

      case AssetLoadingState.loadedDefault:
        return _buildDefaultImageDisplay(creature!, width, height);

      case AssetLoadingState.failed:
      case AssetLoadingState.noAsset:
        return _buildSilhouetteFallback(creature!, width, height);

      case AssetLoadingState.noCreature:
        return _buildEmptyState(width, height);
    }
  }

  Widget _buildLoadingState(double width, double height) {
    return SizedBox(
      width: width * 0.5,
      height: height * 0.5,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.overrideColor?.withValues(alpha: 0.7) ??
          const Color(0xFF4682B4).withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(Creature creature, double width, double height) {
    final assetPath = _getSpeciesAssetPath(creature);

    if (assetPath.isEmpty) {
      // No asset path available, fall back to default or silhouette
      if (widget.useDefaultImageFallback) {
        return _buildDefaultImageDisplay(creature, width, height);
      }
      return _buildSilhouetteFallback(creature, width, height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        assetPath,
        width: width * 0.8,
        height: height * 0.8,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default image if species image fails
          if (widget.useDefaultImageFallback) {
            return _buildDefaultImageDisplay(creature, width, height);
          }
          return _buildSilhouetteFallback(creature, width, height);
        },
      ),
    );
  }

  Widget _buildDefaultImageDisplay(Creature creature, double width, double height) {
    final defaultPath = _getDefaultImagePath(creature);

    if (defaultPath.isEmpty) {
      return _buildSilhouetteFallback(creature, width, height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        defaultPath,
        width: width * 0.8,
        height: width * 0.8,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Final fallback to silhouette if default image fails
          return _buildSilhouetteFallback(creature, width, height);
        },
      ),
    );
  }

  Widget _buildSilhouetteFallback(Creature creature, double width, double height) {
    final biomeColor = BiomeColorInheritance.getBiomeAccentColor(creature.habitat);
    final effectiveColor = widget.overrideColor ?? biomeColor;

    // Always treat creatures as discovered when shown in the species display
    // (The unified dashboard should only show actually discovered creatures)
    final isDiscovered = true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Biome-themed icon based on creature type and habitat
        Icon(
          _getCreatureIcon(creature),
          size: width * 0.5,
          color: effectiveColor,
        ),

        if (widget.showName) ...[
          const SizedBox(height: 8),
          Text(
            creature.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: effectiveColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(double width, double height) {
    return Icon(
      Icons.help_outline,
      size: width * 0.4,
      color: const Color(0xFF9E9E9E),
    );
  }

  IconData _getCreatureIcon(Creature creature) {
    // Map creature types to appropriate icons
    switch (creature.type) {
      case CreatureType.starterFish:
        return _getFishIcon(creature.habitat);
      case CreatureType.reefBuilder:
        return Icons.filter_vintage;
      case CreatureType.predator:
        return Icons.pest_control;
      case CreatureType.deepSeaDweller:
        return Icons.timeline;
      case CreatureType.mythical:
        return Icons.auto_awesome;
    }
  }

  IconData _getFishIcon(BiomeType habitat) {
    switch (habitat) {
      case BiomeType.shallowWaters:
        return Icons.set_meal; // Tropical fish
      case BiomeType.coralGarden:
        return Icons.colorize; // Reef fish
      case BiomeType.deepOcean:
        return Icons.timeline; // Deep sea fish
      case BiomeType.abyssalZone:
        return Icons.auto_awesome; // Mysterious creatures
    }
  }

  Widget _buildRarityIndicator(Creature creature) {
    final rarityColor = _getRarityColor(creature.rarity);

    return Positioned(
      top: -4,
      right: -4,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: rarityColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getRaritySymbol(creature.rarity),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUndiscoveredOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.black.withValues(alpha: 0.6),
        ),
        child: const Center(
          child: Icon(
            Icons.lock,
            color: Colors.white70,
            size: 32,
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return const Color(0xFF757575); // Grey
      case CreatureRarity.uncommon:
        return const Color(0xFF4CAF50); // Green
      case CreatureRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case CreatureRarity.legendary:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  String _getRaritySymbol(CreatureRarity rarity) {
    switch (rarity) {
      case CreatureRarity.common:
        return 'C';
      case CreatureRarity.uncommon:
        return 'U';
      case CreatureRarity.rare:
        return 'R';
      case CreatureRarity.legendary:
        return 'L';
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Display modes for species assets
enum SpeciesDisplayMode {
  /// Automatically choose best display based on availability
  adaptive,
  /// Force image display (fallback to silhouette if unavailable)
  imageOnly,
  /// Force silhouette display
  silhouetteOnly,
  /// Force text-only display
  textOnly,
}

/// Asset loading states for internal state management
enum AssetLoadingState {
  loading,
  loaded,
  loadedDefault,
  failed,
  noAsset,
  noCreature,
}