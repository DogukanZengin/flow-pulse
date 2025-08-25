import 'package:flutter/material.dart';
import '../services/ui_sound_service.dart';
import '../themes/ocean_theme.dart';
import '../utils/responsive_helper.dart';

class OceanNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const OceanNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveHelper.getNavigationHeight(context),
      decoration: BoxDecoration(
        // Ocean depth gradient - darker blue to lighter ocean blue
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OceanTheme.deepOceanBlue, // Deep ocean blue
            OceanTheme.midOcean, // Mid ocean blue
            OceanTheme.oceanSurface, // Lighter ocean blue
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: const Border(
          top: BorderSide(
            color: OceanTheme.selectedTab, // Ocean surface cyan
            width: 2.0,
          ),
          left: BorderSide(
            color: OceanTheme.selectedTab,
            width: 0.5,
          ),
          right: BorderSide(
            color: OceanTheme.selectedTab,
            width: 0.5,
          ),
        ),
        boxShadow: [
          // Ocean depth shadow
          BoxShadow(
            color: const Color(0xFF1B4D72).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
          // Inner ocean glow
          BoxShadow(
            color: const Color(0xFF5DADE2).withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle wave pattern overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _OceanWavePainter(),
              ),
            ),
          ),
          // Navigation items
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = ResponsiveHelper.isCompactScreen(context);
              final spacing = ResponsiveHelper.getResponsiveSpacing(context, 'navigation');
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing,
                  vertical: spacing / 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.scuba_diving,
                        label: 'Dive',
                        index: 0,
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                        isCompact: isCompact,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.analytics,
                        label: isCompact ? 'Data' : 'Data Log',
                        index: 1,
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                        isCompact: isCompact,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.military_tech,
                        label: 'Career',
                        index: 2,
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                        isCompact: isCompact,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.groups,
                        label: isCompact ? 'Social' : 'Community',
                        index: 3,
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                        isCompact: isCompact,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.settings,
                        label: 'Station',
                        index: 4,
                        isSelected: currentIndex == 4,
                        onTap: () => onTap(4),
                        isCompact: isCompact,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Ocean wave painter for subtle wave pattern overlay on tab bar
class _OceanWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5DADE2).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create subtle wave pattern
    final waveHeight = size.height * 0.15;
    final waveLength = size.width / 3;
    
    path.moveTo(0, size.height);
    
    // Create 3 gentle waves across the width
    for (int i = 0; i <= 3; i++) {
      final x = i * waveLength;
      final y = size.height - waveHeight + (waveHeight * 0.3) * (i % 2 == 0 ? 1 : -1);
      
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = (i - 1) * waveLength;
        final controlX1 = prevX + waveLength * 0.3;
        final controlY1 = size.height - waveHeight;
        final controlX2 = x - waveLength * 0.3;
        final controlY2 = size.height - waveHeight;
        
        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add a second, more subtle wave layer
    final paint2 = Paint()
      ..color = const Color(0xFF87CEEB).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    path2.moveTo(0, size.height);
    
    for (int i = 0; i <= 4; i++) {
      final x = i * (size.width / 4);
      final y = size.height - (waveHeight * 0.6) + (waveHeight * 0.2) * (i % 2 == 0 ? -1 : 1);
      
      if (i == 0) {
        path2.lineTo(x, y);
      } else {
        final prevX = (i - 1) * (size.width / 4);
        final controlX1 = prevX + (size.width / 4) * 0.4;
        final controlY1 = size.height - (waveHeight * 0.4);
        final controlX2 = x - (size.width / 4) * 0.4;
        final controlY2 = size.height - (waveHeight * 0.4);
        
        path2.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }
    
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Create elastic animation: 1.0 -> 0.95 -> 1.05 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Execute the original onTap callback first for immediate screen change
    widget.onTap();
    
    // Play UI sound and haptic feedback
    UISoundService.instance.navigationSwitch();
    
    // Play elastic animation (non-blocking)
    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) {
            if (!widget.isSelected) {
              setState(() {});
            }
          },
          onExit: (_) {
            if (!widget.isSelected) {
              setState(() {});
            }
          },
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 'navigation') / 2,
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 'navigation'),
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected 
                      ? const Color(0xFF5DADE2).withValues(alpha: 0.25) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12), // Less rounded to match ocean theme
                  border: widget.isSelected ? Border.all(
                    color: const Color(0xFF87CEEB).withValues(alpha: 0.4),
                    width: 1.5,
                  ) : null,
                  boxShadow: widget.isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF5DADE2).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.icon,
                        color: Colors.white.withValues(alpha: widget.isSelected ? 1.0 : 0.7),
                        size: ResponsiveHelper.getIconSize(context, 'medium') * 
                              (widget.isSelected ? 1.0 : 0.9)
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 'navigation') / 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: widget.isSelected ? 1.0 : 0.7),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 'navigation') * 
                                  (widget.isSelected ? 1.1 : 1.0),
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}