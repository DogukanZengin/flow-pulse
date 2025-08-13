import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/gamification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSelectorWidget extends StatefulWidget {
  const ThemeSelectorWidget({Key? key}) : super(key: key);

  @override
  State<ThemeSelectorWidget> createState() => _ThemeSelectorWidgetState();
}

class _ThemeSelectorWidgetState extends State<ThemeSelectorWidget> 
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  String _selectedTheme = 'default';
  bool _isExpanded = false;
  
  final Map<String, ThemeData> _themes = {
    'default': ThemeData(
      name: 'Classic',
      primaryGradient: [Color(0xFF6B5B95), Color(0xFF88B0D3)],
      secondaryGradient: [Color(0xFFFF6B6B), Color(0xFFFECA57)],
      icon: Icons.palette,
      unlockLevel: 0,
    ),
    'sunset': ThemeData(
      name: 'Sunset',
      primaryGradient: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
      secondaryGradient: [Color(0xFF6B5B95), Color(0xFF355C7D)],
      icon: Icons.wb_twilight,
      unlockLevel: 5,
    ),
    'ocean': ThemeData(
      name: 'Ocean',
      primaryGradient: [Color(0xFF006BA6), Color(0xFF0496FF)],
      secondaryGradient: [Color(0xFF38B6FF), Color(0xFF7FCDFF)],
      icon: Icons.waves,
      unlockLevel: 10,
    ),
    'forest': ThemeData(
      name: 'Forest',
      primaryGradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
      secondaryGradient: [Color(0xFF81C784), Color(0xFFA5D6A7)],
      icon: Icons.forest,
      unlockLevel: 15,
    ),
    'cosmos': ThemeData(
      name: 'Cosmos',
      primaryGradient: [Color(0xFF311B92), Color(0xFF512DA8)],
      secondaryGradient: [Color(0xFF7E57C2), Color(0xFF9575CD)],
      icon: Icons.nightlight,
      unlockLevel: 20,
    ),
    'aurora': ThemeData(
      name: 'Aurora',
      primaryGradient: [Color(0xFF00BFA5), Color(0xFF00E5FF)],
      secondaryGradient: [Color(0xFF18FFFF), Color(0xFF64FFDA)],
      icon: Icons.auto_awesome,
      unlockLevel: 25,
    ),
    'cyberpunk': ThemeData(
      name: 'Cyberpunk',
      primaryGradient: [Color(0xFFE91E63), Color(0xFFFF00FF)],
      secondaryGradient: [Color(0xFF00FFFF), Color(0xFF00FF00)],
      icon: Icons.computer,
      unlockLevel: 30,
    ),
  };
  
  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));
    
    _loadSelectedTheme();
  }
  
  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('selected_theme') ?? 'default';
    });
  }
  
  Future<void> _selectTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', themeId);
    
    setState(() {
      _selectedTheme = themeId;
    });
    
    // Notify the app to update colors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to ${_themes[themeId]!.name}'),
          backgroundColor: _themes[themeId]!.primaryGradient[0],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final unlockedThemes = GamificationService.instance.unlockedThemes;
    final currentLevel = GamificationService.instance.currentLevel;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _expandController.forward();
                      } else {
                        _expandController.reverse();
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.color_lens,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Themes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _themes[_selectedTheme]!.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _themes[_selectedTheme]!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _themes.length,
                          itemBuilder: (context, index) {
                            final themeId = _themes.keys.elementAt(index);
                            final theme = _themes[themeId]!;
                            final isUnlocked = theme.unlockLevel == 0 || 
                                             (unlockedThemes.contains(themeId) || 
                                              currentLevel >= theme.unlockLevel);
                            final isSelected = _selectedTheme == themeId;
                            
                            return _buildThemeCard(
                              themeId: themeId,
                              theme: theme,
                              isUnlocked: isUnlocked,
                              isSelected: isSelected,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeCard({
    required String themeId,
    required ThemeData theme,
    required bool isUnlocked,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () => _selectTheme(themeId) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.primaryGradient,
                )
              : null,
          color: !isUnlocked ? Colors.white.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryGradient[0].withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  theme.icon,
                  color: isUnlocked ? Colors.white : Colors.white30,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  theme.name,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white30,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isUnlocked)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.white30,
                    size: 14,
                  ),
                ),
              ),
            if (!isUnlocked)
              Positioned(
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lv.${theme.unlockLevel}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ThemeData {
  final String name;
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
  final IconData icon;
  final int unlockLevel;
  
  ThemeData({
    required this.name,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.icon,
    required this.unlockLevel,
  });
}