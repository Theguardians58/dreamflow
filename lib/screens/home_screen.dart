import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/constants/app_constants.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/services/product_service.dart';
import 'package:aura_bloom/widgets/product_card.dart';
import 'package:aura_bloom/screens/product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<Product> _trendingProducts = [];
  List<Product> _newArrivals = [];
  bool _isLoading = true;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startBannerAnimation();
  }

  Future<void> _loadData() async {
    final trending = await _productService.getTrendingProducts();
    final newArrivals = await _productService.getNewArrivals();
    if (mounted) {
      setState(() {
        _trendingProducts = trending;
        _newArrivals = newArrivals;
        _isLoading = false;
      });
    }
  }

  void _startBannerAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _bannerIndex = (_bannerIndex + 1) % 3);
        _startBannerAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
          onRefresh: _loadData,
          color: AuraColors.dustyRose,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildBanner(),
                const SizedBox(height: 24),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildSection('Trending Now', _trendingProducts),
                const SizedBox(height: 24),
                _buildSection('New Arrivals', _newArrivals),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello,', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AuraColors.mediumGrey)),
              Text('Welcome to Aura', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(backgroundColor: AuraColors.lightGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final banners = [
      {'title': 'New Collection', 'subtitle': 'Discover the latest trends', 'color': AuraColors.dustyRose},
      {'title': 'Sale Up to 50%', 'subtitle': 'Limited time offer', 'color': AuraColors.gold},
      {'title': 'Ethnic Wear', 'subtitle': 'Traditional with a twist', 'color': const Color(0xFFB8A7D4)},
    ];
    
    final currentBanner = banners[_bannerIndex];
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: ValueKey(_bannerIndex),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        height: 160,
        decoration: BoxDecoration(
          color: currentBanner['color'] as Color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentBanner['title'] as String, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(currentBanner['subtitle'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: currentBanner['color'] as Color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Shop Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Shop by Category', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(category: AppConstants.categories[index]))),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(color: AuraColors.dustyRose.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon([Icons.checkroom, Icons.style, Icons.shopping_bag, Icons.diamond, Icons.style_outlined, Icons.checkroom_outlined][index % 6], color: AuraColors.dustyRose, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(AppConstants.categories[index], style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen())),
                child: Text('See All', style: TextStyle(color: AuraColors.dustyRose)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(product: products[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
