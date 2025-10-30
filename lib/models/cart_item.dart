import 'package:aura_bloom/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'quantity': quantity,
    'selectedSize': selectedSize,
    'selectedColor': selectedColor,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] ?? '',
    product: Product.fromJson(json['product']),
    quantity: json['quantity'] ?? 1,
    selectedSize: json['selectedSize'],
    selectedColor: json['selectedColor'],
  );

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) => CartItem(
    id: id ?? this.id,
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    selectedSize: selectedSize ?? this.selectedSize,
    selectedColor: selectedColor ?? this.selectedColor,
  );
}
