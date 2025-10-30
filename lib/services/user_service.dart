import 'package:aura_bloom/models/user.dart';
import 'package:aura_bloom/models/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!doc.exists) return null;

      return User.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> isGuest() async {
    return _auth.currentUser?.isAnonymous ?? true;
  }

  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user document exists, create if not
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        final user = User(
          id: credential.user!.uid,
          name: email.split('@')[0],
          email: email,
          addresses: [],
          wishlist: [],
        );
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        addresses: [],
        wishlist: [],
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
      await credential.user!.updateDisplayName(name);
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      final user = User(
        id: credential.user!.uid,
        name: 'Guest User',
        email: 'guest@aura.com',
        phoneNumber: null,
        addresses: [],
        wishlist: [],
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error continuing as guest: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore.collection('users').doc(user.id).update(updatedUser.toJson());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;
      
      final addresses = [...user.addresses, address];
      await updateUser(user.copyWith(addresses: addresses));
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;
      
      final addresses = user.addresses.map((a) => a.id == address.id ? address : a).toList();
      await updateUser(user.copyWith(addresses: addresses));
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;
      
      final addresses = user.addresses.where((a) => a.id != addressId).toList();
      await updateUser(user.copyWith(addresses: addresses));
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;
      
      final wishlist = [...user.wishlist];
      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
      } else {
        wishlist.add(productId);
      }
      await updateUser(user.copyWith(wishlist: wishlist));
    } catch (e) {
      print('Error toggling wishlist: $e');
      rethrow;
    }
  }

  Future<bool> isInWishlist(String productId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;
      return user.wishlist.contains(productId);
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  Stream<User?> getCurrentUserStream() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      
      return User.fromJson(doc.data()!);
    });
  }
}
