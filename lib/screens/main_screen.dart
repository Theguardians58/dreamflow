import 'package:flutter/material.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/screens/home_screen.dart';
import 'package:aura_bloom/screens/product_list_screen.dart';
import 'package:aura_bloom/screens/cart_screen.dart';
import 'package:aura_bloom/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _controllers;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductListScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => AnimationController(duration: const Duration(milliseconds: 200), vsync: this));
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _controllers[_currentIndex].reverse();
      _currentIndex = index;
      _controllers[_currentIndex].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Shop'),
                _buildNavItem(2, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Cart'),
                _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          final scale = 1.0 + (_controllers[index].value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AuraColors.dustyRose.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isSelected ? filledIcon : outlinedIcon, color: isSelected ? AuraColors.dustyRose : AuraColors.mediumGrey, size: 24),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AuraColors.dustyRose : AuraColors.mediumGrey, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
