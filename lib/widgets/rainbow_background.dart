import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/user_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class RainbowBackground extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double blurSigma;

  const RainbowBackground({
    super.key,
    required this.child,
    this.animate = true,
    this.blurSigma = 30.0,
  });

  @override
  State<RainbowBackground> createState() => _RainbowBackgroundState();
}

class _RainbowBackgroundState extends State<RainbowBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const List<Color> _defaultColors = [
    AppColors.myntraPink,
    AppColors.myntraOrange,
    AppColors.myntraRed,
  ];

  final List<Color> _femaleColors = [
    AppColors.myntraPink,
    AppColors.myntraOrange,
    AppColors.myntraRed,
    const Color(0xFF800080), // Deep Purple for a sophisticated mix
    AppColors.myntraPink,
  ];

  final List<Color> _maleColors = [
    AppColors.malePrimary,
    AppColors.maleSecondary,
    const Color(0xFFF16FB8), // Deep Blue
    const Color(0xFFD86BA1), // Royal Blue
    AppColors.malePrimary,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isMale = userState.gender == Gender.male;
    final activeColors = isMale ? _maleColors : _femaleColors;

    return Stack(
      children: [
        // Static Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                activeColors[0],
                activeColors[1],
                activeColors[2],
              ],
            ),
          ),
        ),
        
        // Subtle Texture Overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        
        // The Glass Blur Effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
            ),
            child: Container(
              color: Colors.white.withOpacity(isMale ? 0.4 : 0.6), // Light glass for light theme
            ),
          ),
        ),
        
        // The Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}
