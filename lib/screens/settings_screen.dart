import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/timer_provider.dart';

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
              Color(0xFF1B4D72), // Deep Ocean Research
              Color(0xFF2E86AB), // Research Station Blue
              Color(0xFF48A38A), // Equipment Teal
              Color(0xFF81C7D4), // Laboratory Light Blue
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Research Station Configuration',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤿 Diving Equipment Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
            const SizedBox(height: 16),
            _TimerSlider(
              title: 'Dive Duration',
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
              title: 'Surface Rest',
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
              title: 'Lab Analysis',
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
              title: 'Dives Until Lab Analysis',
              subtitle: '${timerProvider.sessionsUntilLongBreak} expeditions',
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
              title: const Text('Auto-start Surface Rest', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically start surface rest timer', style: TextStyle(color: Colors.white70)),
              value: timerProvider.autoStartBreaks,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartBreaks(value);
              },
            ),
            SwitchListTile(
              title: const Text('Auto-start Research', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically start research dives after surface rest', style: TextStyle(color: Colors.white70)),
              value: timerProvider.autoStartSessions,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartSessions(value);
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
              title: 'Shallow Water Dive',
              subtitle: '25 min dive • 5 min surface',
              onTap: () async {
                await context.read<TimerProvider>().setShallowWaterDive();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shallow Water Dive preset applied! 🤿')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Deep Sea Expedition',
              subtitle: '45 min dive • 10 min surface',
              onTap: () async {
                await context.read<TimerProvider>().setDeepSeaExpedition();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deep Sea Expedition preset applied! 🌊')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Surface Exploration',
              subtitle: '15 min explore • 3 min surface',
              onTap: () async {
                await context.read<TimerProvider>().setSurfaceExploration();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Surface Exploration preset applied! 🏊')),
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
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                      Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Free Plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Premium functionality removed
                  },
                  icon: const Icon(Icons.science),
                  label: Text('Enable Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
              'Enhanced achievements',
            ]),
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

