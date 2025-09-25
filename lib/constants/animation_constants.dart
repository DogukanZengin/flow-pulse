/// Animation constants for Research Expedition Summary
class AnimationConstants {
  // Particle System Configuration
  static const int marineSnowParticleCount = 25; // Reduced from 40
  static const int planktonParticleCount = 12; // Reduced from 20
  static const int burstParticleCount = 30; // Reduced from 50
  static const int maxSparkleCount = 15; // Reduced from 30
  static const int maxAchievementSparkles = 12; // Reduced from 20
  
  // Animation Durations (optimized for responsiveness)
  static const Duration waveControllerDuration = Duration(milliseconds: 1500); // was 3s - natural water motion
  static const Duration coralGrowthDuration = Duration(seconds: 2); // keep - appropriate for growth
  static const Duration particleFloatDuration = Duration(seconds: 2); // was 8s - 4x faster, more lively
  static const Duration sparkleAnimationDuration = Duration(seconds: 2); // keep - good rhythm
  static const Duration burstEffectDuration = Duration(milliseconds: 1000); // was 1500ms - snappier bursts

  // Anticipation Delays for Enhanced Timing
  static const Duration anticipationDelayMin = Duration(milliseconds: 500);
  static const Duration anticipationDelayMax = Duration(milliseconds: 1500);
  
  // Caustic Effect Configuration
  static const int causticGridWidth = 10; // Reduced from 15
  static const int causticGridHeight = 6; // Reduced from 8
  
  // Floating Particles Configuration
  static const double maxFloatingParticleIntensity = 20.0; // Reduced from 30
  static const int fixedParticleSeed = 42;
  
  // Jellyfish Effect Configuration
  static const int jellyfishCount = 6; // Reduced from 8
  static const int tentacleCount = 4; // Reduced from 6
  
  // School of Fish Configuration
  static const int fishSchoolCount = 20; // Reduced from 30
  
  // Discovery Particles Configuration
  static const int discoveryParticleCountLegendary = 30; // Reduced from 50
  static const int discoveryParticleCountRare = 20; // Reduced from 30
  static const int discoveryParticleCountCommon = 12; // Reduced from 20
  
  // Performance Thresholds
  static const double minRenderDistance = 50.0;
  static const double particleCullingThreshold = 0.1;
  static const double lowPerformanceIntensity = 0.5;
  
  // Memory Management
  static const int maxParticlePoolSize = 100;
  static const Duration particleCleanupInterval = Duration(seconds: 5);
}