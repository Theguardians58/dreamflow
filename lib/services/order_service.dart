import 'package:aura_bloom/models/order.dart' as model;
import 'package:aura_bloom/models/address.dart';
import 'package:aura_bloom/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<model.Order>> getOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => model.Order.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  Future<model.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return null;
      
      return model.Order.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  Future<model.Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required Address shippingAddress,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress.toJson(),
        'status': model.OrderStatus.pending.name,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('orders').add(orderData);
      
      final order = model.Order(
        id: docRef.id,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        status: model.OrderStatus.pending,
      );

      return order;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, model.OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, model.OrderStatus.cancelled);
  }

  Stream<List<model.Order>> getOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.Order.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<List<model.Order>> getOrdersByStatus(String userId, model.OrderStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => model.Order.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting orders by status: $e');
      return [];
    }
  }
}
