import 'package:audioplayers/audioplayers.dart';
import '../models/aquarium.dart';
import '../models/coral.dart';
import '../models/creature.dart'; // BiomeType is defined here
import 'audio_service.dart';

class OceanAudioService {
  static OceanAudioService? _instance;
  static OceanAudioService get instance => _instance ??= OceanAudioService._();
  
  OceanAudioService._();
  
  final AudioService _audioService = AudioService.instance;
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();
  
  BiomeType? _currentBiome;
  bool _isPlaying = false;
  double _ambientVolume = 0.3;
  double _effectsVolume = 0.5;
  
  // Ocean-specific sound mappings
  final Map<BiomeType, SoundType> _biomeAmbientSounds = {
    BiomeType.shallowWaters: SoundType.gentleWaves,
    BiomeType.coralGarden: SoundType.ocean,
    BiomeType.deepOcean: SoundType.oceanStorm,
    BiomeType.abyssalZone: SoundType.spaceDrone, // Deep mysterious sound
  };
  
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
      
      // Get the appropriate sound for the biome
      final soundType = _biomeAmbientSounds[biome] ?? SoundType.ocean;
      
      // For web and demo, use available ocean sound
      String assetPath = 'sounds/ocean.mp3';
      
      // Use available ocean sound for all biomes for now
      switch (biome) {
        case BiomeType.shallowWaters:
          assetPath = 'sounds/ocean.mp3';
          break;
        case BiomeType.coralGarden:
          assetPath = 'sounds/ocean.mp3';
          break;
        case BiomeType.deepOcean:
          assetPath = 'sounds/ocean.mp3';
          break;
        case BiomeType.abyssalZone:
          assetPath = 'sounds/ocean.mp3';
          break;
      }
      
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
}

// Session-specific ocean sounds
enum SessionOceanSound {
  sessionStart,
  sessionComplete,
  sessionAbandon,
  breakTime,
}