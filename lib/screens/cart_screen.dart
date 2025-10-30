import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/models/cart_item.dart';
import 'package:aura_bloom/services/cart_service.dart';
import 'package:aura_bloom/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    final items = await _cartService.getCartItems();
    if (mounted) setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    await _cartService.updateQuantity(itemId, quantity);
    await _loadCart();
  }

  Future<void> _removeItem(String itemId) async {
    await _cartService.removeFromCart(itemId);
    await _loadCart();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Item removed from cart'), backgroundColor: AuraColors.mediumGrey, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
    }
  }

  Future<double> _getTotal() async => await _cartService.getCartTotal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart'), actions: [
        if (_cartItems.isNotEmpty)
          TextButton(onPressed: () async {
            await _cartService.clearCart();
            _loadCart();
          }, child: const Text('Clear All')),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _cartItems.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: AuraColors.mediumGrey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AuraColors.mediumGrey)),
            const SizedBox(height: 8),
            Text('Add items to get started', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
          ],
        ),
      ) : Column(
        children: [
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cartItems.length,
                itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Dismissible(
                        key: Key(_cartItems[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: AuraColors.error, borderRadius: BorderRadius.circular(16)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeItem(_cartItems[index].id),
                        child: _CartItemCard(
                          item: _cartItems[index],
                          onQuantityChanged: (quantity) => _updateQuantity(_cartItems[index].id, quantity),
                          onRemove: () => _removeItem(_cartItems[index].id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleLarge),
                      FutureBuilder<double>(
                        future: _getTotal(),
                        builder: (context, snapshot) => Text('₹${snapshot.data?.toStringAsFixed(0) ?? '0'}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AuraColors.dustyRose)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())),
                      style: ElevatedButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({required this.item, required this.onQuantityChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(item.product.images.first, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AuraColors.lightGrey, child: const Icon(Icons.image))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (item.selectedSize != null || item.selectedColor != null)
                  Text('${item.selectedSize ?? ''} ${item.selectedColor ?? ''}'.trim(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AuraColors.mediumGrey)),
                const SizedBox(height: 8),
                Text('₹${item.product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AuraColors.dustyRose, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(color: AuraColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(onPressed: () => onQuantityChanged(item.quantity - 1), icon: const Icon(Icons.remove, size: 18), constraints: const BoxConstraints(minWidth: 32, minHeight: 32), padding: EdgeInsets.zero),
                    Text('${item.quantity}', style: Theme.of(context).textTheme.titleSmall),
                    IconButton(onPressed: () => onQuantityChanged(item.quantity + 1), icon: const Icon(Icons.add, size: 18), constraints: const BoxConstraints(minWidth: 32, minHeight: 32), padding: EdgeInsets.zero),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IconButton(onPressed: onRemove, icon: Icon(Icons.delete_outline, color: AuraColors.error, size: 20), constraints: const BoxConstraints(minWidth: 32, minHeight: 32), padding: EdgeInsets.zero),
            ],
          ),
        ],
      ),
    );
  }
}
