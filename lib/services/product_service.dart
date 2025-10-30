import 'package:aura_bloom/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('inStock', isEqualTo: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (!doc.exists) return null;
      
      return Product.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .where('inStock', isEqualTo: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('inStock', isEqualTo: true)
          .limit(100)
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .where((p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.description.toLowerCase().contains(lowerQuery) ||
              p.category.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<List<Product>> filterProducts({
    List<String>? categories,
    List<String>? sizes,
    List<String>? colors,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      Query query = _firestore.collection('products');

      if (categories != null && categories.isNotEmpty) {
        query = query.where('category', whereIn: categories);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      query = query.limit(100);

      final snapshot = await query.get();
      var products = snapshot.docs
          .map((doc) => Product.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      if (sizes != null && sizes.isNotEmpty) {
        products = products.where((p) => p.sizes.any((s) => sizes.contains(s))).toList();
      }

      if (colors != null && colors.isNotEmpty) {
        products = products.where((p) => p.colors.any((c) => colors.contains(c))).toList();
      }

      return products;
    } catch (e) {
      print('Error filtering products: $e');
      return [];
    }
  }

  Future<List<Product>> sortProducts(List<Product> products, String sortBy) async {
    switch (sortBy) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Newest First':
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }
    return products;
  }

  Future<List<Product>> getTrendingProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('inStock', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(6)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting trending products: $e');
      return [];
    }
  }

  Future<List<Product>> getNewArrivals() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('inStock', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting new arrivals: $e');
      return [];
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .where('inStock', isEqualTo: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
