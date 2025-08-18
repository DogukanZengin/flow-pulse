import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../services/audio_service.dart';
import '../providers/theme_provider.dart';

class PremiumAudioControls extends StatefulWidget {
  const PremiumAudioControls({super.key});

  @override
  State<PremiumAudioControls> createState() => _PremiumAudioControlsState();
}

class _PremiumAudioControlsState extends State<PremiumAudioControls> {
  final AudioService _audioService = AudioService.instance;
  SoundCategory _selectedCategory = SoundCategory.nature;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final subscriptionService = SubscriptionService.instance; // Removed subscription service
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with mixing toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Premium Audio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Mixing',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _audioService.isMixingMode,
                          onChanged: false ? (value) {
                            setState(() {
                              if (value) {
                                _audioService.enableMixingMode();
                              } else {
                                _audioService.disableMixingMode();
                              }
                            });
                          } : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Category selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SoundCategory.values.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            _getCategoryName(category),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.black.withOpacity(0.7),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: Colors.white.withOpacity(0.8),
                          selectedColor: Colors.white.withOpacity(0.9),
                          checkmarkColor: Colors.black,
                          side: BorderSide(
                            color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.6),
                            width: isSelected ? 2 : 1,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sound library
                if (!false)
                  _buildPremiumUpgradePrompt(context)
                else
                  _buildSoundLibrary(context, themeProvider),
                
                const SizedBox(height: 16),
                
                // Active sounds (mixing mode)
                if (_audioService.isMixingMode && _audioService.activeSounds.isNotEmpty)
                  _buildActiveSoundsPanel(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumUpgradePrompt(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headphones,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              '25+ Premium Sounds',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock advanced sound mixing\nand premium audio library',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPremiumDialog(context),
              child: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSoundLibrary(BuildContext context, ThemeProvider themeProvider) {
    final categorySounds = _getSoundsForCategory(_selectedCategory);
    
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: categorySounds.length,
        itemBuilder: (context, index) {
          final sound = categorySounds[index];
          final isPlaying = _audioService.isMixingMode 
              ? _audioService.activeSounds.contains(sound)
              : _audioService.currentSound == sound && _audioService.isPlaying;
          final isPremium = sound.isPremium;
          
          return GestureDetector(
            onTap: () {
              if (_audioService.isMixingMode) {
                if (isPlaying) {
                  _audioService.removeSoundLayer(sound);
                } else {
                  _audioService.addSoundLayer(sound);
                }
              } else {
                if (isPlaying) {
                  _audioService.stopSound();
                } else {
                  _audioService.playSound(sound);
                }
              }
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isPlaying 
                    ? themeProvider.isDarkMode 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: isPlaying 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  width: isPlaying ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSoundIcon(sound),
                          size: 24,
                          color: isPlaying 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sound.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                            color: isPlaying 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActiveSoundsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Sounds',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ..._audioService.activeSounds.map((sound) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    sound.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Slider(
                    value: 0.5, // Would get from audio service in production
                    onChanged: (value) {
                      _audioService.setSoundLayerVolume(sound, value);
                    },
                    min: 0,
                    max: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _audioService.removeSoundLayer(sound);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  List<SoundType> _getSoundsForCategory(SoundCategory category) {
    return SoundType.values.where((sound) => sound.category == category).toList();
  }
  
  String _getCategoryName(SoundCategory category) {
    switch (category) {
      case SoundCategory.nature:
        return 'Nature';
      case SoundCategory.ambient:
        return 'Ambient';
      case SoundCategory.focus:
        return 'Focus';
      case SoundCategory.relaxation:
        return 'Relaxation';
      case SoundCategory.urban:
        return 'Urban';
    }
  }
  
  IconData _getSoundIcon(SoundType sound) {
    switch (sound.category) {
      case SoundCategory.nature:
        return Icons.park;
      case SoundCategory.ambient:
        return Icons.waves;
      case SoundCategory.focus:
        return Icons.psychology;
      case SoundCategory.relaxation:
        return Icons.spa;
      case SoundCategory.urban:
        return Icons.location_city;
    }
  }
  
  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Premium audio features have been removed from this version.'),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Premium functionality removed
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}