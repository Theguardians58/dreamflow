import 'package:flutter/material.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/models/user.dart';
import 'package:aura_bloom/models/order.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/services/user_service.dart';
import 'package:aura_bloom/services/order_service.dart';
import 'package:aura_bloom/services/product_service.dart';
import 'package:aura_bloom/screens/auth_screen.dart';
import 'package:aura_bloom/screens/product_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  User? _user;
  List<Order> _orders = [];
  List<Product> _wishlistProducts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final user = await UserService().getCurrentUser();
    final orders = await OrderService().getOrders(user?.id ?? '');
    
    final wishlistProducts = <Product>[];
    if (user != null) {
      for (final productId in user.wishlist) {
        final product = await ProductService().getProductById(productId);
        if (product != null) wishlistProducts.add(product);
      }
    }
    
    if (mounted) {
      setState(() {
        _user = user;
        _orders = orders;
        _wishlistProducts = wishlistProducts;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AuraColors.dustyRose.withValues(alpha: 0.2),
                    child: Text(_user?.name.substring(0, 1).toUpperCase() ?? 'G', style: TextStyle(fontSize: 40, color: AuraColors.dustyRose, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(_user?.name ?? 'Guest', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(_user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                  if (_user?.phoneNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(_user!.phoneNumber!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                  ],
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AuraColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: AuraColors.dustyRose, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white,
                unselectedLabelColor: AuraColors.charcoal,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Orders'), Tab(text: 'Wishlist')],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTab(),
                  _buildWishlistTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: AuraColors.mediumGrey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No orders yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AuraColors.mediumGrey)),
            const SizedBox(height: 8),
            Text('Start shopping to see your orders here', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.id.substring(order.id.length - 6)}', style: Theme.of(context).textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status == OrderStatus.delivered ? AuraColors.success.withValues(alpha: 0.1) : order.status == OrderStatus.cancelled ? AuraColors.error.withValues(alpha: 0.1) : AuraColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order.status.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: order.status == OrderStatus.delivered ? AuraColors.success : order.status == OrderStatus.cancelled ? AuraColors.error : AuraColors.gold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${order.items.length} item(s) • ₹${order.totalAmount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
              const SizedBox(height: 4),
              Text('Ordered on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AuraColors.mediumGrey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistTab() {
    if (_wishlistProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AuraColors.mediumGrey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No items in wishlist', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AuraColors.mediumGrey)),
            const SizedBox(height: 8),
            Text('Save your favorite items here', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: _wishlistProducts.length,
      itemBuilder: (context, index) {
        final product = _wishlistProducts[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
            _loadData();
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.asset(product.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AuraColors.lightGrey, child: const Icon(Icons.image, size: 50, color: Colors.grey))),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          await UserService().toggleWishlist(product.id);
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('₹${product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AuraColors.dustyRose, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
