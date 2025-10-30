import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    this.sizes = const [],
    this.colors = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get hasDiscount => discountPercentage > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'category': category,
    'images': images,
    'sizes': sizes,
    'colors': colors,
    'rating': rating,
    'reviewCount': reviewCount,
    'inStock': inStock,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    originalPrice: json['originalPrice']?.toDouble(),
    category: json['category'] ?? '',
    images: (json['images'] as List?)?.map((i) => i.toString()).toList() ?? [],
    sizes: (json['sizes'] as List?)?.map((s) => s.toString()).toList() ?? [],
    colors: (json['colors'] as List?)?.map((c) => c.toString()).toList() ?? [],
    rating: (json['rating'] ?? 0).toDouble(),
    reviewCount: json['reviewCount'] ?? 0,
    inStock: json['inStock'] ?? true,
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now()),
  );

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    double? rating,
    int? reviewCount,
    bool? inStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    originalPrice: originalPrice ?? this.originalPrice,
    category: category ?? this.category,
    images: images ?? this.images,
    sizes: sizes ?? this.sizes,
    colors: colors ?? this.colors,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    inStock: inStock ?? this.inStock,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
