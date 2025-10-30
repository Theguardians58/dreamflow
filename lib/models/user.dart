import 'package:aura_bloom/models/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<Address> addresses;
  final List<String> wishlist;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.addresses = const [],
    this.wishlist = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'addresses': addresses.map((a) => a.toJson()).toList(),
    'wishlist': wishlist,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'],
    addresses: (json['addresses'] as List?)?.map((a) => Address.fromJson(a)).toList() ?? [],
    wishlist: (json['wishlist'] as List?)?.map((w) => w.toString()).toList() ?? [],
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now()),
  );

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    List<Address>? addresses,
    List<String>? wishlist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    addresses: addresses ?? this.addresses,
    wishlist: wishlist ?? this.wishlist,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
