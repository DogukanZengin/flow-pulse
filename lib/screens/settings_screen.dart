import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _TimerSection(),
          const SizedBox(height: 24),
          const _ThemeSection(),
          const SizedBox(height: 24),
          const _AutoStartSection(),
          const SizedBox(height: 24),
          const _PresetSection(),
        ],
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
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timer Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
              style: theme.textTheme.titleMedium,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
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
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                context.read<ThemeProvider>().toggleDarkMode();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Theme Color',
              style: theme.textTheme.titleMedium,
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
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
    }
  }
}

class _AutoStartSection extends StatelessWidget {
  const _AutoStartSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerProvider = context.watch<TimerProvider>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automation',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Auto-start Breaks'),
              subtitle: const Text('Automatically start break timer'),
              value: timerProvider.autoStartBreaks,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartBreaks(value);
              },
            ),
            SwitchListTile(
              title: const Text('Auto-start Focus'),
              subtitle: const Text('Automatically start focus timer after breaks'),
              value: timerProvider.autoStartPomodoros,
              onChanged: (value) {
                context.read<TimerProvider>().setAutoStartPomodoros(value);
              },
            ),
          ],
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
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timer Presets',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _PresetButton(
              title: 'Classic Pomodoro',
              subtitle: '25 min focus • 5 min break',
              onTap: () {
                context.read<TimerProvider>().setClassicPomodoro();
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Extended Focus',
              subtitle: '45 min focus • 10 min break',
              onTap: () {
                context.read<TimerProvider>().setExtendedFocus();
              },
            ),
            const SizedBox(height: 8),
            _PresetButton(
              title: 'Quick Sprints',
              subtitle: '15 min focus • 3 min break',
              onTap: () {
                context.read<TimerProvider>().setQuickSprints();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}