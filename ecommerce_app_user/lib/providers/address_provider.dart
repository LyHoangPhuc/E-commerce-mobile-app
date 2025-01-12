import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Address> _addresses = [];

  List<Address> get addresses => _addresses;

  // Lấy địa chỉ từ Firebase
  Future<void> fetchAddresses() async {
    try {
      final user = _auth.currentUser;
      print('Fetching addresses for user: ${user?.uid}');

      if (user == null) {
        print('No user logged in');
        return;
      }

      final userDoc = _firestore.collection('users').doc(user.uid);
      print('Checking if user document exists...');

      final userSnapshot = await userDoc.get();
      if (!userSnapshot.exists) {
        print('Creating new user document...');
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('Fetching addresses from Firestore...');
      final snapshot = await userDoc.collection('addresses').get();
      print('Found ${snapshot.docs.length} addresses');

      _addresses = snapshot.docs
          .map((doc) => Address.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      print('Addresses loaded successfully: ${_addresses.length} items');
      notifyListeners();
    } catch (error, stackTrace) {
      print('Error fetching addresses: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Thêm địa chỉ mới
  Future<void> addAddress(Address address) async {
    try {
      final user = _auth.currentUser;
      print('Adding new address for user: ${user?.uid}');

      if (user == null) {
        print('No user logged in - cannot add address');
        throw Exception('User not logged in');
      }

      // Kiểm tra và tạo document user nếu chưa tồn tại
      final userDoc = _firestore.collection('users').doc(user.uid);
      final userSnapshot = await userDoc.get();
      if (!userSnapshot.exists) {
        print('Creating new user document before adding address...');
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('Converting address to map...');
      final addressMap = address.toMap();
      print('Address data: $addressMap');

      print('Adding address to Firestore...');
      final docRef = await userDoc.collection('addresses').add(addressMap);
      print('Address added with ID: ${docRef.id}');

      final newAddress = Address.fromMap({
        ...addressMap,
        'id': docRef.id,
      });

      _addresses.add(newAddress);
      print(
          'Address added to local list. Total addresses: ${_addresses.length}');
      notifyListeners();
    } catch (error, stackTrace) {
      print('Error adding address: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Cập nhật địa chỉ
  Future<void> updateAddress(Address address) async {
    try {
      final user = _auth.currentUser;
      print('Updating address ${address.id} for user: ${user?.uid}');

      if (user == null) {
        print('No user logged in - cannot update address');
        throw Exception('User not logged in');
      }

      if (address.id == null) {
        print('Address ID is null - cannot update');
        throw Exception('Address ID is required for update');
      }

      print('Converting address to map...');
      final addressMap = address.toMap();
      print('Updated address data: $addressMap');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .update(addressMap);

      print('Address updated in Firestore');

      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        print('Address updated in local list');
        notifyListeners();
      }
    } catch (error, stackTrace) {
      print('Error updating address: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Xóa địa chỉ
  Future<void> removeAddress(String id) async {
    try {
      final user = _auth.currentUser;
      print('Removing address $id for user: ${user?.uid}');

      if (user == null) {
        print('No user logged in - cannot remove address');
        throw Exception('User not logged in');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(id)
          .delete();

      print('Address deleted from Firestore');

      _addresses.removeWhere((address) => address.id == id);
      print(
          'Address removed from local list. Remaining addresses: ${_addresses.length}');
      notifyListeners();
    } catch (error, stackTrace) {
      print('Error removing address: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
