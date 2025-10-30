import 'package:flutter/material.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/screens/product_detail_screen.dart';
import 'package:aura_bloom/services/user_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onWishlistToggle;

  const ProductCard({super.key, required this.product, this.onWishlistToggle});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final inWishlist = await UserService().isInWishlist(widget.product.id);
    if (mounted) setState(() => _isInWishlist = inWishlist);
  }

  Future<void> _toggleWishlist() async {
    await UserService().toggleWishlist(widget.product.id);
    if (mounted) setState(() => _isInWishlist = !_isInWishlist);
    widget.onWishlistToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: widget.product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product_${widget.product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 0.75,
                      child: Image.asset(widget.product.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AuraColors.lightGrey, child: const Icon(Icons.image, size: 50, color: Colors.grey))),
                    ),
                  ),
                ),
                if (widget.product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AuraColors.error, borderRadius: BorderRadius.circular(8)),
                      child: Text('${widget.product.discountPercentage.toInt()}% OFF', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border, key: ValueKey(_isInWishlist), color: _isInWishlist ? Colors.red : AuraColors.mediumGrey, size: 20),
                      ),
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
                  Text(widget.product.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.product.category, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AuraColors.mediumGrey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₹${widget.product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AuraColors.dustyRose, fontWeight: FontWeight.bold)),
                      if (widget.product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text('₹${widget.product.originalPrice!.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: AuraColors.mediumGrey)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${widget.product.rating} (${widget.product.reviewCount})', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
