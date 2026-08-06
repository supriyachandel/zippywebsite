import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../models/cart_state.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final userState = Provider.of<UserState>(context, listen: false);
    final cartState = Provider.of<CartState>(context, listen: false);
    await ApiService.loadToken();
    await userState.loadFromPrefs();
    await cartState.init();

    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    if (userState.isLoggedIn && userState.token != null && userState.token!.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120)
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                .shimmer(duration: 1000.ms),
            const SizedBox(height: 10),
            Text(
              "FASHION AT LIGHTNING SPEED",
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
