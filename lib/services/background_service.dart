import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

enum BackgroundType {
  theme, // Use theme colors
  gradient, // Premium gradient backgrounds
  image, // Custom user image
}

class BackgroundData {
  final BackgroundType type;
  final String? imagePath;
  final List<Color>? gradientColors;
  final String? gradientName;

  BackgroundData({
    required this.type,
    this.imagePath,
    this.gradientColors,
    this.gradientName,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'imagePath': imagePath,
      'gradientColors': gradientColors?.map((c) => c.value).toList(),
      'gradientName': gradientName,
    };
  }

  static BackgroundData fromJson(Map<String, dynamic> json) {
    return BackgroundData(
      type: BackgroundType.values[json['type']],
      imagePath: json['imagePath'],
      gradientColors: (json['gradientColors'] as List<dynamic>?)
          ?.map((c) => Color(c as int))
          .toList(),
      gradientName: json['gradientName'],
    );
  }
}

class BackgroundService {
  static BackgroundService? _instance;
  static BackgroundService get instance => _instance ??= BackgroundService._();
  
  BackgroundService._();

  SharedPreferences? _prefs;
  BackgroundData _currentBackground = BackgroundData(type: BackgroundType.theme);
  final ImagePicker _picker = ImagePicker();

  static const String _backgroundKey = 'custom_background';
  
  BackgroundData get currentBackground => _currentBackground;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBackground();
  }

  Future<void> _loadBackground() async {
    final backgroundJson = _prefs?.getString(_backgroundKey);
    if (backgroundJson != null) {
      try {
        final data = json.decode(backgroundJson);
        _currentBackground = BackgroundData.fromJson(data);
      } catch (e) {
        // If loading fails, use default
        _currentBackground = BackgroundData(type: BackgroundType.theme);
      }
    }
  }

  Future<void> _saveBackground() async {
    await _prefs?.setString(_backgroundKey, json.encode(_currentBackground.toJson()));
  }

  Future<bool> setCustomImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        _currentBackground = BackgroundData(
          type: BackgroundType.image,
          imagePath: image.path,
        );
        await _saveBackground();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setPremiumGradient(String gradientName, List<Color> colors) async {
    _currentBackground = BackgroundData(
      type: BackgroundType.gradient,
      gradientColors: colors,
      gradientName: gradientName,
    );
    await _saveBackground();
  }

  Future<void> setThemeBackground() async {
    _currentBackground = BackgroundData(type: BackgroundType.theme);
    await _saveBackground();
  }

  Widget buildBackground({
    required Widget child,
    required Color primaryColor,
    required Color secondaryColor,
    required bool isDarkMode,
  }) {
    switch (_currentBackground.type) {
      case BackgroundType.theme:
        return _buildThemeBackground(
          child: child,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          isDarkMode: isDarkMode,
        );
      case BackgroundType.gradient:
        return _buildGradientBackground(
          child: child,
          colors: _currentBackground.gradientColors ?? [primaryColor, secondaryColor],
        );
      case BackgroundType.image:
        return _buildImageBackground(
          child: child,
          imagePath: _currentBackground.imagePath,
          fallbackPrimary: primaryColor,
          fallbackSecondary: secondaryColor,
          isDarkMode: isDarkMode,
        );
    }
  }

  Widget _buildThemeBackground({
    required Widget child,
    required Color primaryColor,
    required Color secondaryColor,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            secondaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildGradientBackground({
    required Widget child,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.map((c) => c.withOpacity(0.3)).toList(),
        ),
      ),
      child: child,
    );
  }

  Widget _buildImageBackground({
    required Widget child,
    required String? imagePath,
    required Color fallbackPrimary,
    required Color fallbackSecondary,
    required bool isDarkMode,
  }) {
    if (imagePath == null || !File(imagePath).existsSync()) {
      return _buildThemeBackground(
        child: child,
        primaryColor: fallbackPrimary,
        secondaryColor: fallbackSecondary,
        isDarkMode: isDarkMode,
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.black.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
        child: child,
      ),
    );
  }

  // Premium gradient presets
  static List<PremiumGradient> get premiumGradients => [
    PremiumGradient(
      name: 'Sunset Dream',
      colors: [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFE66D),
        const Color(0xFFFF8E53),
      ],
    ),
    PremiumGradient(
      name: 'Ocean Depth',
      colors: [
        const Color(0xFF667eea),
        const Color(0xFF764ba2),
        const Color(0xFF667eea),
      ],
    ),
    PremiumGradient(
      name: 'Northern Lights',
      colors: [
        const Color(0xFF00c6ff),
        const Color(0xFF0072ff),
        const Color(0xFF00c6ff),
      ],
    ),
    PremiumGradient(
      name: 'Mystic Forest',
      colors: [
        const Color(0xFF134e5e),
        const Color(0xFF71b280),
        const Color(0xFF134e5e),
      ],
    ),
    PremiumGradient(
      name: 'Cosmic Purple',
      colors: [
        const Color(0xFF8360c3),
        const Color(0xFF2ebf91),
        const Color(0xFF8360c3),
      ],
    ),
    PremiumGradient(
      name: 'Fire Glow',
      colors: [
        const Color(0xFFf093fb),
        const Color(0xFFf5576c),
        const Color(0xFFf093fb),
      ],
    ),
    PremiumGradient(
      name: 'Deep Space',
      colors: [
        const Color(0xFF2b5876),
        const Color(0xFF4e4376),
        const Color(0xFF2b5876),
      ],
    ),
    PremiumGradient(
      name: 'Golden Hour',
      colors: [
        const Color(0xFFffb347),
        const Color(0xFFffcc33),
        const Color(0xFFffb347),
      ],
    ),
  ];
}

class PremiumGradient {
  final String name;
  final List<Color> colors;

  PremiumGradient({
    required this.name,
    required this.colors,
  });
}