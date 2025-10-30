import 'package:aura_bloom/models/cart_item.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/services/storage_service.dart';

class CartService {
  static const String _cartKey = 'cart';

  Future<List<CartItem>> getCartItems() async {
    final data = StorageService.getList(_cartKey);
    return data.map((json) => CartItem.fromJson(json)).toList();
  }

  Future<void> addToCart(Product product, {String? size, String? color}) async {
    final items = await getCartItems();
    
    final existingIndex = items.indexWhere((item) =>
      item.product.id == product.id &&
      item.selectedSize == size &&
      item.selectedColor == color
    );

    if (existingIndex != -1) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + 1,
      );
    } else {
      final newItem = CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: 1,
        selectedSize: size,
        selectedColor: color,
      );
      items.add(newItem);
    }

    await _saveCart(items);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.id == cartItemId);
    
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      await _saveCart(items);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.id == cartItemId);
    await _saveCart(items);
  }

  Future<void> clearCart() async {
    await StorageService.saveList(_cartKey, []);
  }

  Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _saveCart(List<CartItem> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await StorageService.saveList(_cartKey, jsonList);
  }
}
