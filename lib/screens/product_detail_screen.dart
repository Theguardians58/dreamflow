import 'package:flutter/material.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/services/cart_service.dart';
import 'package:aura_bloom/services/user_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  String? _selectedSize;
  String? _selectedColor;
  bool _isInWishlist = false;
  bool _isAddingToCart = false;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _checkWishlist();
    if (widget.product.sizes.isNotEmpty) _selectedSize = widget.product.sizes.first;
    if (widget.product.colors.isNotEmpty) _selectedColor = widget.product.colors.first;
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _checkWishlist() async {
    final inWishlist = await UserService().isInWishlist(widget.product.id);
    if (mounted) setState(() => _isInWishlist = inWishlist);
  }

  Future<void> _toggleWishlist() async {
    await UserService().toggleWishlist(widget.product.id);
    if (mounted) setState(() => _isInWishlist = !_isInWishlist);
  }

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    _buttonController.forward();
    
    await CartService().addToCart(widget.product, size: _selectedSize, color: _selectedColor);
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isAddingToCart = false);
      _buttonController.reverse();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Added to cart!'), backgroundColor: AuraColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AuraColors.offWhite,
            actions: [
              IconButton(
                onPressed: _toggleWishlist,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border, key: ValueKey(_isInWishlist), color: _isInWishlist ? Colors.red : AuraColors.charcoal),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product.id}',
                child: Image.asset(widget.product.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AuraColors.lightGrey, child: const Icon(Icons.image, size: 100, color: Colors.grey))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.dustyRose)),
                    const SizedBox(height: 8),
                    Text(widget.product.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${widget.product.rating}', style: Theme.of(context).textTheme.titleMedium),
                        Text(' (${widget.product.reviewCount} reviews)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('₹${widget.product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AuraColors.dustyRose)),
                        if (widget.product.hasDiscount) ...[
                          const SizedBox(width: 12),
                          Text('₹${widget.product.originalPrice!.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough, color: AuraColors.mediumGrey)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AuraColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('${widget.product.discountPercentage.toInt()}% OFF', style: TextStyle(color: AuraColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    if (widget.product.sizes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Select Size', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: widget.product.sizes.map((size) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ChoiceChip(
                            label: Text(size),
                            selected: _selectedSize == size,
                            onSelected: (selected) => setState(() => _selectedSize = size),
                            selectedColor: AuraColors.dustyRose,
                            labelStyle: TextStyle(color: _selectedSize == size ? Colors.white : AuraColors.charcoal),
                          ),
                        )).toList(),
                      ),
                    ],
                    if (widget.product.colors.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Select Color', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: widget.product.colors.map((color) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ChoiceChip(
                            label: Text(color),
                            selected: _selectedColor == color,
                            onSelected: (selected) => setState(() => _selectedColor = color),
                            selectedColor: AuraColors.dustyRose,
                            labelStyle: TextStyle(color: _selectedColor == color ? Colors.white : AuraColors.charcoal),
                          ),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Description', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(widget.product.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AuraColors.mediumGrey, height: 1.5)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _buttonController,
            builder: (context, child) {
              final scale = 1.0 - (_buttonController.value * 0.05);
              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAddingToCart ? null : _addToCart,
                    style: ElevatedButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    child: _isAddingToCart ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined),
                        const SizedBox(width: 8),
                        const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
