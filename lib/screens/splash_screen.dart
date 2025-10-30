import 'package:flutter/material.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/screens/onboarding_screen.dart';
import 'package:aura_bloom/screens/main_screen.dart';
import 'package:aura_bloom/services/storage_service.dart';
import 'package:aura_bloom/services/product_service.dart';
import 'package:aura_bloom/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn))
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack))
    );
    
    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await StorageService.init();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    final hasSeenOnboarding = StorageService.getString('has_seen_onboarding') == 'true';
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
          hasSeenOnboarding ? const MainScreen() : const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.offWhite,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AuraColors.dustyRose,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.spa, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('Aura', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AuraColors.dustyRose)),
                  const SizedBox(height: 8),
                  Text('Your Style Companion', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
