import 'package:aura_bloom/models/address.dart';
import 'package:aura_bloom/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final Address shippingAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'totalAmount': totalAmount,
    'shippingAddress': shippingAddress.toJson(),
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    items: (json['items'] as List?)?.map((i) => CartItem.fromJson(i)).toList() ?? [],
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    shippingAddress: Address.fromJson(json['shippingAddress']),
    status: OrderStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => OrderStatus.pending,
    ),
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now()),
  );

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    Address? shippingAddress,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Order(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    items: items ?? this.items,
    totalAmount: totalAmount ?? this.totalAmount,
    shippingAddress: shippingAddress ?? this.shippingAddress,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
