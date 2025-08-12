import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../services/subscription_service.dart';
import '../services/background_service.dart';
import '../widgets/premium_audio_controls.dart';
import '../widgets/breathing_exercise.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B5B95), // Deep Purple
              Color(0xFF88B0D3), // Sky Blue
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 120), // Space for floating nav
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
          // Premium status and upgrade
          const _PremiumSection(),
          const SizedBox(height: 24),
          
          // Core timer settings
          const _TimerSection(),
          const SizedBox(height: 24),
          
          // Theme and background settings (premium features)
          const _ThemeSection(),
          const SizedBox(height: 24),
          
          // Audio settings (premium mixing)
          const PremiumAudioControls(),
          const SizedBox(height: 24),
          
          // Breathing exercises (premium)
                    const _BreathingSection(),
                    const SizedBox(height: 24),
                    
                    // Original settings
                    const _AutoStartSection(),
                    const SizedBox(height: 24),
                    const _PresetSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = context.watch<TimerProvider>();
    
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
                Text(
                  'Timer Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
            const SizedBox(height: 16),
            _TimerSlider(
              title: 'Focus Duration',
              subtitle: '${timerProvider.focusDuration} minutes',
              value: timerProvider.focusDuration.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              onChanged: (value) {
                context.read<TimerProvider>().setFocusDuration(value.round());
              },
            ),
            const SizedBox(height: 16),
            _TimerSlider(
              title: 'Short Break',
              subtitle: '${timerProvider.breakDuration} minutes',
              value: timerProvider.breakDuration.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (value) {
                context.read<TimerProvider>().setBreakDuration(value.round());
              },
            ),
            const SizedBox(height: 16),
            _TimerSlider(
              title: 'Long Break',
              subtitle: '${timerProvider.longBreakDuration} minutes',
              value: timerProvider.longBreakDuration.toDouble(),
              min: 5,
              max: 60,
              divisions: 55,
              onChanged: (value) {
                context.read<TimerProvider>().setLongBreakDuration(value.round());
              },
            ),
            const SizedBox(height: 16),
            _TimerSlider(
              title: 'Sessions Until Long Break',
              subtitle: '${timerProvider.sessionsUntilLongBreak} sessions',
              value: timerProvider.sessionsUntilLongBreak.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                context.read<TimerProvider>().setSessionsUntilLongBreak(value.round());
              },
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerSlider extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _TimerSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    
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
            Text(
              'Appearance',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Use dark theme', style: TextStyle(color: Colors.white70)),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                context.read<ThemeProvider>().toggleDarkMode();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Theme Color',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: AppTheme.values.map((appTheme) {
                final isSelected = themeProvider.currentTheme == appTheme;
                return GestureDetector(
                  onTap: () {
                    context.read<ThemeProvider>().setTheme(appTheme);
                  },
                  child: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getThemeColor(appTheme),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              themeProvider.getThemeName(themeProvider.currentTheme),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.indigo:
        return const Color(0xFF3F51B5);
      case AppTheme.ocean:
        return const Color(0xFF0277BD);
      case AppTheme.forest:
        return const Color(0xFF2E7D32);
      case AppTheme.sunset:
        return const Color(0xFFD84315);
      case AppTheme.lavender:
        return const Color(0xFF7B1FA2);
      case AppTheme.charcoal:
        return const Color(0xFF455A64);
      case AppTheme.midnight:
        return const Color(0xFF1A237E);
      case AppTheme.cosmicPulse:
        return const Color(0xFF6A1B9A);
      case AppTheme.auroralBloom:
        return const Color(0xFF00BCD4);
      case AppTheme.liquidGold:
        return const Color(0xFFFF8F00);
      case AppTheme.neonNights:
        return const Color(0xFF00E676);
      case AppTheme.crystalCave:
        return const Color(0xFF9C27B0);
      case AppTheme.volcanoFire:
        return const Color(0xFFD32F2F);
      case AppTheme.deepSpace:
        return const Color(0xFF1A237E);
      case AppTheme.sakuraBloom:
        return const Color(0xFFE91E63);
      case AppTheme.electroMist:
        return const Color(0xFF00BCD4);
      case AppTheme.prismShift:
        return const Color(0xFF9C27B0);
      case AppTheme.galaxySwirl:
        return const Color(0xFF3F51B5);
      case AppTheme.emeraldFlow:
        return const Color(0xFF2E7D32);
      case AppTheme.rubyGlow:
        return const Color(0xFFD32F2F);
      case AppTheme.sapphireWave:
        return const Color(0xFF0277BD);
      case AppTheme.opalShimmer:
        return const Color(0xFF9C27B0);
      case AppTheme.diamondDust:
        return const Color(0xFF78909C);
      case AppTheme.copperFlame:
        return const Color(0xFFD84315);
      case AppTheme.steelStorm:
        return const Color(0xFF455A64);
      case AppTheme.goldRush:
        return const Color(0xFFFF8F00);
      case AppTheme.silverMoon:
        return const Color(0xFF78909C);
    }
  }
}

class _AutoStartSection extends StatelessWidget {
  const _AutoStartSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = context.watch<TimerProvider>();
    
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
            Text(
              'Automation',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Auto-start Breaks', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically start break timer', style: TextStyle(color: Colors.white70)),
              value: timerProvider.autoStartBreaks,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartBreaks(value);
              },
            ),
            SwitchListTile(
              title: const Text('Auto-start Focus', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically start focus timer after breaks', style: TextStyle(color: Colors.white70)),
              value: timerProvider.autoStartPomodoros,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartPomodoros(value);
              },
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetSection extends StatelessWidget {
  const _PresetSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text(
              'Timer Presets',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _PresetButton(
              title: 'Classic Pomodoro',
              subtitle: '25 min focus • 5 min break',
              onTap: () async {
                await context.read<TimerProvider>().setClassicPomodoro();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classic Pomodoro preset applied! ⏱️')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Extended Focus',
              subtitle: '45 min focus • 10 min break',
              onTap: () async {
                await context.read<TimerProvider>().setExtendedFocus();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Extended Focus preset applied! 🎯')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Quick Sprints',
              subtitle: '15 min focus • 3 min break',
              onTap: () async {
                await context.read<TimerProvider>().setQuickSprints();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quick Sprints preset applied! ⚡')),
                  );
                }
              },
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Trigger haptic feedback
    HapticFeedback.lightImpact();
    
    // Play scale animation
    await _animationController.forward();
    await _animationController.reverse();
    
    // Execute the original onTap callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PremiumSection extends StatelessWidget {
  const _PremiumSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionService = SubscriptionService.instance;
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      subscriptionService.isPremium ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      subscriptionService.isPremium ? 'Premium Active' : 'Free Plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: subscriptionService.isPremium ? Colors.amber : Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await subscriptionService.togglePremiumForDemo();
                  },
                  icon: const Icon(Icons.science),
                  label: Text(subscriptionService.isPremium ? 'Disable Premium' : 'Enable Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!subscriptionService.isPremium) ...[
              Text(
                'Unlock Premium Features:',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildFeatureList([
                '25+ premium ambient sounds',
                'Advanced sound mixing & layering',
                'Premium animated themes',
                'Custom backgrounds',
                'Breathing exercises',
                'Enhanced achievements',
              ]),
            ] else ...[
              Text(
                'Thank you for supporting FlowPulse Premium!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy unlimited access to all premium features.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureList(List<String> features) {
    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const Icon(Icons.check, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(feature),
          ],
        ),
      )).toList(),
    );
  }
}

class _BreathingSection extends StatelessWidget {
  const _BreathingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionService = SubscriptionService.instance;
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Breathing Exercises',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (!subscriptionService.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!subscriptionService.isPremium) ...[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.air,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guided Breathing Exercises',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Premium feature',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              BreathingExercise(
                primaryColor: theme.colorScheme.primary,
                secondaryColor: theme.colorScheme.secondary,
                inhaleSeconds: 4,
                holdSeconds: 4,
                exhaleSeconds: 4,
                pauseSeconds: 4,
              ),
            ],
          ],
            ),
          ),
        ),
      ),
    );
  }
}