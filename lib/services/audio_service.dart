import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  // Free sounds
  rain,
  forest,
  ocean,
  whiteNoise,
  brownNoise,
  
  // Premium sounds
  thunderstorm,
  campfire,
  cityRain,
  deepForest,
  oceanStorm,
  gentleWaves,
  mountainStream,
  nightCrickets,
  morningBirds,
  windChimes,
  tibetanBowls,
  pinkNoise,
  coffeeShop,
  library,
  fireplace,
  waterfall,
  desertWind,
  snowfall,
  rainOnRoof,
  trainJourney,
  spaceDrone,
  vintageRadio,
  clockTicking,
  keyboardTyping,
  vinylCrackle,
}

enum SoundCategory {
  nature,
  ambient,
  focus,
  relaxation,
  urban,
}

extension SoundTypeExtension on SoundType {
  String get displayName {
    switch (this) {
      // Free sounds
      case SoundType.rain:
        return 'Rain';
      case SoundType.forest:
        return 'Forest';
      case SoundType.ocean:
        return 'Ocean Waves';
      case SoundType.whiteNoise:
        return 'White Noise';
      case SoundType.brownNoise:
        return 'Brown Noise';
      
      // Premium sounds
      case SoundType.thunderstorm:
        return 'Thunderstorm';
      case SoundType.campfire:
        return 'Campfire';
      case SoundType.cityRain:
        return 'City Rain';
      case SoundType.deepForest:
        return 'Deep Forest';
      case SoundType.oceanStorm:
        return 'Ocean Storm';
      case SoundType.gentleWaves:
        return 'Gentle Waves';
      case SoundType.mountainStream:
        return 'Mountain Stream';
      case SoundType.nightCrickets:
        return 'Night Crickets';
      case SoundType.morningBirds:
        return 'Morning Birds';
      case SoundType.windChimes:
        return 'Wind Chimes';
      case SoundType.tibetanBowls:
        return 'Tibetan Bowls';
      case SoundType.pinkNoise:
        return 'Pink Noise';
      case SoundType.coffeeShop:
        return 'Coffee Shop';
      case SoundType.library:
        return 'Library';
      case SoundType.fireplace:
        return 'Fireplace';
      case SoundType.waterfall:
        return 'Waterfall';
      case SoundType.desertWind:
        return 'Desert Wind';
      case SoundType.snowfall:
        return 'Snowfall';
      case SoundType.rainOnRoof:
        return 'Rain on Roof';
      case SoundType.trainJourney:
        return 'Train Journey';
      case SoundType.spaceDrone:
        return 'Space Drone';
      case SoundType.vintageRadio:
        return 'Vintage Radio';
      case SoundType.clockTicking:
        return 'Clock Ticking';
      case SoundType.keyboardTyping:
        return 'Keyboard Typing';
      case SoundType.vinylCrackle:
        return 'Vinyl Crackle';
    }
  }

  String get fileName {
    switch (this) {
      // Free sounds
      case SoundType.rain:
        return 'rain.mp3';
      case SoundType.forest:
        return 'forest.mp3';
      case SoundType.ocean:
        return 'ocean.mp3';
      case SoundType.whiteNoise:
        return 'white_noise.mp3';
      case SoundType.brownNoise:
        return 'brown_noise.mp3';
      
      // Premium sounds (would be actual files in production)
      case SoundType.thunderstorm:
        return 'premium/thunderstorm.mp3';
      case SoundType.campfire:
        return 'premium/campfire.mp3';
      case SoundType.cityRain:
        return 'premium/city_rain.mp3';
      case SoundType.deepForest:
        return 'premium/deep_forest.mp3';
      case SoundType.oceanStorm:
        return 'premium/ocean_storm.mp3';
      case SoundType.gentleWaves:
        return 'premium/gentle_waves.mp3';
      case SoundType.mountainStream:
        return 'premium/mountain_stream.mp3';
      case SoundType.nightCrickets:
        return 'premium/night_crickets.mp3';
      case SoundType.morningBirds:
        return 'premium/morning_birds.mp3';
      case SoundType.windChimes:
        return 'premium/wind_chimes.mp3';
      case SoundType.tibetanBowls:
        return 'premium/tibetan_bowls.mp3';
      case SoundType.pinkNoise:
        return 'premium/pink_noise.mp3';
      case SoundType.coffeeShop:
        return 'premium/coffee_shop.mp3';
      case SoundType.library:
        return 'premium/library.mp3';
      case SoundType.fireplace:
        return 'premium/fireplace.mp3';
      case SoundType.waterfall:
        return 'premium/waterfall.mp3';
      case SoundType.desertWind:
        return 'premium/desert_wind.mp3';
      case SoundType.snowfall:
        return 'premium/snowfall.mp3';
      case SoundType.rainOnRoof:
        return 'premium/rain_on_roof.mp3';
      case SoundType.trainJourney:
        return 'premium/train_journey.mp3';
      case SoundType.spaceDrone:
        return 'premium/space_drone.mp3';
      case SoundType.vintageRadio:
        return 'premium/vintage_radio.mp3';
      case SoundType.clockTicking:
        return 'premium/clock_ticking.mp3';
      case SoundType.keyboardTyping:
        return 'premium/keyboard_typing.mp3';
      case SoundType.vinylCrackle:
        return 'premium/vinyl_crackle.mp3';
    }
  }

  bool get isPremium {
    return !freeSounds.contains(this);
  }

  SoundCategory get category {
    switch (this) {
      case SoundType.rain:
      case SoundType.forest:
      case SoundType.ocean:
      case SoundType.thunderstorm:
      case SoundType.deepForest:
      case SoundType.oceanStorm:
      case SoundType.gentleWaves:
      case SoundType.mountainStream:
      case SoundType.nightCrickets:
      case SoundType.morningBirds:
      case SoundType.waterfall:
      case SoundType.desertWind:
      case SoundType.snowfall:
        return SoundCategory.nature;
      
      case SoundType.whiteNoise:
      case SoundType.brownNoise:
      case SoundType.pinkNoise:
      case SoundType.spaceDrone:
        return SoundCategory.focus;
      
      case SoundType.windChimes:
      case SoundType.tibetanBowls:
      case SoundType.fireplace:
        return SoundCategory.relaxation;
      
      case SoundType.cityRain:
      case SoundType.coffeeShop:
      case SoundType.library:
      case SoundType.trainJourney:
      case SoundType.keyboardTyping:
        return SoundCategory.urban;
      
      case SoundType.campfire:
      case SoundType.rainOnRoof:
      case SoundType.vintageRadio:
      case SoundType.clockTicking:
      case SoundType.vinylCrackle:
        return SoundCategory.ambient;
    }
  }

  static List<SoundType> get freeSounds => [
    SoundType.rain,
    SoundType.forest,
    SoundType.ocean,
    SoundType.whiteNoise,
    SoundType.brownNoise,
  ];

  static List<SoundType> get premiumSounds => SoundType.values
      .where((sound) => !freeSounds.contains(sound))
      .toList();
}

class SoundLayer {
  final SoundType soundType;
  final AudioPlayer player;
  double volume;
  bool isPlaying;

  SoundLayer({
    required this.soundType,
    required this.player,
    this.volume = 0.5,
    this.isPlaying = false,
  });
}

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();

  // For simple single-sound playback (backward compatibility)
  final AudioPlayer _audioPlayer = AudioPlayer();
  SoundType? _currentSound;
  double _volume = 0.5;
  bool _isPlaying = false;

  // For advanced sound mixing
  final Map<SoundType, SoundLayer> _activeLayers = {};
  double _masterVolume = 0.5;
  bool _mixingMode = false;

  bool get isPlaying => _mixingMode ? _activeLayers.isNotEmpty : _isPlaying;
  SoundType? get currentSound => _currentSound;
  double get volume => _mixingMode ? _masterVolume : _volume;
  bool get isMixingMode => _mixingMode;
  List<SoundType> get activeSounds => _activeLayers.keys.toList();
  
  void enableMixingMode() {
    _mixingMode = true;
    stopSound(); // Stop single sound if playing
  }
  
  void disableMixingMode() {
    _mixingMode = false;
    _stopAllLayers();
  }

  // Single sound playback (backward compatibility)
  Future<void> playSound(SoundType soundType) async {
    if (_mixingMode) {
      await addSoundLayer(soundType);
      return;
    }
    
    try {
      await _audioPlayer.stop();
      
      // Use fallback sound for premium sounds in demo
      String assetPath = soundType.isPremium 
          ? 'sounds/rain.mp3' // Fallback to rain for demo
          : 'sounds/${soundType.fileName}';
      
      await _audioPlayer.setSource(AssetSource(assetPath));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      
      _currentSound = soundType;
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // Advanced sound mixing methods
  Future<void> addSoundLayer(SoundType soundType, {double volume = 0.5}) async {
    if (!_mixingMode) return;
    if (_activeLayers.containsKey(soundType)) return;
    
    try {
      final player = AudioPlayer();
      
      // Use fallback sound for premium sounds in demo
      String assetPath = soundType.isPremium 
          ? 'sounds/rain.mp3' // Fallback to rain for demo
          : 'sounds/${soundType.fileName}';
      
      await player.setSource(AssetSource(assetPath));
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(volume * _masterVolume);
      await player.resume();
      
      _activeLayers[soundType] = SoundLayer(
        soundType: soundType,
        player: player,
        volume: volume,
        isPlaying: true,
      );
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<void> removeSoundLayer(SoundType soundType) async {
    final layer = _activeLayers[soundType];
    if (layer != null) {
      await layer.player.stop();
      await layer.player.dispose();
      _activeLayers.remove(soundType);
    }
  }

  Future<void> setSoundLayerVolume(SoundType soundType, double volume) async {
    final layer = _activeLayers[soundType];
    if (layer != null) {
      layer.volume = volume.clamp(0.0, 1.0);
      await layer.player.setVolume(layer.volume * _masterVolume);
    }
  }

  Future<void> _stopAllLayers() async {
    for (final layer in _activeLayers.values) {
      await layer.player.stop();
      await layer.player.dispose();
    }
    _activeLayers.clear();
  }

  Future<void> stopSound() async {
    if (_mixingMode) {
      await _stopAllLayers();
      return;
    }
    
    try {
      await _audioPlayer.stop();
      _currentSound = null;
      _isPlaying = false;
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<void> setVolume(double volume) async {
    if (_mixingMode) {
      await setMasterVolume(volume);
      return;
    }
    
    _volume = volume.clamp(0.0, 1.0);
    if (_isPlaying) {
      await _audioPlayer.setVolume(_volume);
    }
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    for (final layer in _activeLayers.values) {
      await layer.player.setVolume(layer.volume * _masterVolume);
    }
  }

  Future<void> pauseSound() async {
    if (_mixingMode) {
      await pauseAllLayers();
      return;
    }
    
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> resumeSound() async {
    if (_mixingMode) {
      await resumeAllLayers();
      return;
    }
    
    if (_currentSound != null && !_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  Future<void> pauseAllLayers() async {
    for (final layer in _activeLayers.values) {
      if (layer.isPlaying) {
        await layer.player.pause();
        layer.isPlaying = false;
      }
    }
  }

  Future<void> resumeAllLayers() async {
    for (final layer in _activeLayers.values) {
      if (!layer.isPlaying) {
        await layer.player.resume();
        layer.isPlaying = true;
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    for (final layer in _activeLayers.values) {
      layer.player.dispose();
    }
    _activeLayers.clear();
  }
}