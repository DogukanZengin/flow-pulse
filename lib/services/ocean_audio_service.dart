import 'package:audioplayers/audioplayers.dart';
import '../models/coral.dart';
import '../models/creature.dart'; // BiomeType is defined here

class OceanAudioService {
  static OceanAudioService? _instance;
  static OceanAudioService get instance => _instance ??= OceanAudioService._();
  
  OceanAudioService._();
  
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();
  
  BiomeType? _currentBiome;
  bool _isPlaying = false;
  double _ambientVolume = 0.3;
  double _effectsVolume = 0.5;
  
  // All biomes use ocean.mp3 for simplicity
  
  // Initialize ocean audio for a biome
  Future<void> initializeBiomeAudio(BiomeType biome) async {
    if (_currentBiome == biome && _isPlaying) return;
    
    _currentBiome = biome;
    await _playBiomeAmbient(biome);
  }
  
  // Play ambient sound based on biome
  Future<void> _playBiomeAmbient(BiomeType biome) async {
    try {
      await _ambientPlayer.stop();
      
      // All biomes use ocean.mp3
      String assetPath = 'sounds/ocean.mp3';
      
      // Fallback to ocean sound if specific sound not available
      try {
        await _ambientPlayer.setSource(AssetSource(assetPath));
      } catch (e) {
        await _ambientPlayer.setSource(AssetSource('sounds/ocean.mp3'));
      }
      
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(_ambientVolume);
      await _ambientPlayer.resume();
      
      _isPlaying = true;
    } catch (e) {
      // Silent fail for demo
      _isPlaying = false;
    }
  }
  
  // Play sound effects for ocean events
  Future<void> playOceanEffect(OceanSoundEffect effect) async {
    try {
      await _effectsPlayer.stop();
      
      // Use ocean.mp3 for all sound effects during development
      // Future versions can add specific sound files back:
      // bubbles.mp3, coral_grow.mp3, discovery.mp3, pearl.mp3, splash.mp3, whale.mp3
      try {
        await _effectsPlayer.setSource(AssetSource('sounds/ocean.mp3'));
      } catch (e) {
        // Silent fail - sound effects are optional for functionality
        return;
      }
      
      await _effectsPlayer.setReleaseMode(ReleaseMode.stop);
      await _effectsPlayer.setVolume(_effectsVolume);
      await _effectsPlayer.resume();
    } catch (e) {
      // Silent fail for demo
    }
  }
  
  // Play coral-specific ambient sounds
  Future<void> playCoralAmbient(CoralType coralType) async {
    // Different coral types can have subtle sound variations
    switch (coralType) {
      case CoralType.brain:
        // Deep, thoughtful ambient
        _ambientVolume = 0.25;
        break;
      case CoralType.staghorn:
        // Light, cheerful ambient
        _ambientVolume = 0.35;
        break;
      case CoralType.table:
        // Balanced ambient
        _ambientVolume = 0.3;
        break;
      case CoralType.soft:
        // Gentle, soft ambient
        _ambientVolume = 0.2;
        break;
      case CoralType.fire:
        // Intense ambient
        _ambientVolume = 0.4;
        break;
    }
    
    if (_isPlaying) {
      await _ambientPlayer.setVolume(_ambientVolume);
    }
  }
  
  // Dynamic volume based on depth (timer progress)
  void updateDepthVolume(double depth) {
    // depth is 0.0 to 1.0 (surface to deep)
    // As we go deeper, ambient gets quieter, more muffled
    final adjustedVolume = _ambientVolume * (1.0 - depth * 0.3);
    _ambientPlayer.setVolume(adjustedVolume);
  }
  
  // Play session-specific sounds
  Future<void> playSessionSound(SessionOceanSound sound) async {
    switch (sound) {
      case SessionOceanSound.sessionStart:
        await playOceanEffect(OceanSoundEffect.splash);
        break;
      case SessionOceanSound.sessionComplete:
        await playOceanEffect(OceanSoundEffect.coralGrow);
        break;
      case SessionOceanSound.sessionAbandon:
        // Play a negative/warning sound
        _effectsVolume = 0.3;
        await playOceanEffect(OceanSoundEffect.bubbles);
        _effectsVolume = 0.5; // Reset
        break;
      case SessionOceanSound.breakTime:
        await playOceanEffect(OceanSoundEffect.whaleSong);
        break;
    }
  }
  
  // Set master volume
  void setMasterVolume(double volume) {
    _ambientVolume = volume * 0.6; // Ambient is quieter
    _effectsVolume = volume;
    
    if (_isPlaying) {
      _ambientPlayer.setVolume(_ambientVolume);
    }
  }
  
  // Pause all ocean sounds
  Future<void> pauseAll() async {
    await _ambientPlayer.pause();
    await _effectsPlayer.pause();
    _isPlaying = false;
  }
  
  // Resume all ocean sounds
  Future<void> resumeAll() async {
    if (_currentBiome != null) {
      await _ambientPlayer.resume();
      _isPlaying = true;
    }
  }
  
  // Stop all ocean sounds
  Future<void> stopAll() async {
    await _ambientPlayer.stop();
    await _effectsPlayer.stop();
    _isPlaying = false;
    _currentBiome = null;
  }
  
  // Phase 5: Play seasonal event sounds
  Future<void> playSeasonalEventSound(String eventType) async {
    switch (eventType) {
      case 'migration':
        await playOceanEffect(OceanSoundEffect.migrationSounds);
        break;
      case 'breeding':
      case 'coral_spawning':
        await playOceanEffect(OceanSoundEffect.breedingSounds);
        break;
      case 'bloom':
      case 'plankton':
        await playOceanEffect(OceanSoundEffect.planktonBloom);
        break;
      case 'predatorActivity':
      case 'shark':
        await playOceanEffect(OceanSoundEffect.predatorAlert);
        break;
      case 'bioluminescence':
        await playOceanEffect(OceanSoundEffect.bioluminescence);
        break;
      case 'mystery':
        await playOceanEffect(OceanSoundEffect.mysteryEncounter);
        break;
      default:
        // General event sound
        await playOceanEffect(OceanSoundEffect.whaleSong);
        break;
    }
  }
  
  // Enhanced creature discovery sound with rarity-based effects
  Future<void> playCreatureDiscoverySound(String creatureRarity) async {
    double volume = _effectsVolume;
    
    // Adjust volume and play different variations based on rarity
    switch (creatureRarity.toLowerCase()) {
      case 'common':
        volume *= 0.7; // Quieter for common discoveries
        break;
      case 'uncommon':
        volume *= 0.85; // Slightly louder
        break;
      case 'rare':
        volume *= 1.0; // Full volume
        break;
      case 'legendary':
        volume *= 1.2; // Extra loud for legendary finds
        // Play twice for legendary creatures
        await playOceanEffect(OceanSoundEffect.creatureDiscover);
        await Future.delayed(const Duration(milliseconds: 500));
        break;
    }
    
    // Store original volume
    final originalVolume = _effectsVolume;
    _effectsVolume = volume;
    
    await playOceanEffect(OceanSoundEffect.creatureDiscover);
    
    // Restore original volume
    _effectsVolume = originalVolume;
  }
  
  // Depth-based ambient adjustment - Phase 5 Enhancement
  void updateAmbientForDepthAndSeason(double depth, bool hasSeasonalEvent) {
    // Base depth adjustment
    updateDepthVolume(depth);
    
    // Seasonal event ambient enhancement
    if (hasSeasonalEvent) {
      // Slightly increase ambient richness during seasonal events
      final adjustedVolume = _ambientVolume * 1.1;
      _ambientPlayer.setVolume(adjustedVolume.clamp(0.0, 1.0));
    }
  }
  
  // Dispose of audio players
  void dispose() {
    _ambientPlayer.dispose();
    _effectsPlayer.dispose();
  }
}

// Ocean sound effects enum
enum OceanSoundEffect {
  bubbles,
  coralGrow,
  creatureDiscover,
  pearlCollect,
  splash,
  whaleSong,
  // Phase 5: Seasonal Event Sounds
  migrationSounds,
  breedingSounds,
  planktonBloom,
  predatorAlert,
  bioluminescence,
  mysteryEncounter,
}

// Session-specific ocean sounds
enum SessionOceanSound {
  sessionStart,
  sessionComplete,
  sessionAbandon,
  breakTime,
}