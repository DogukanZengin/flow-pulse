import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/timer_provider.dart';
import '../widgets/fast_forward_control_widget.dart';
import '../theme/ocean_theme_colors.dart';

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
              OceanThemeColors.deepOceanBlue,
              OceanThemeColors.deepOceanAccent,
              OceanThemeColors.shallowWatersAccent,
              OceanThemeColors.celebrationAccent,
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
          // Timer Presets
          const _PresetSection(),
          const SizedBox(height: 24),
          
          // Automation settings
          const _AutoStartSection(),
          const SizedBox(height: 24),
          
          // Fast forward controls for testing
          const FastForwardControlWidget(),
                  ],
                ),
              ),
          ],
        ),
      ),
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


