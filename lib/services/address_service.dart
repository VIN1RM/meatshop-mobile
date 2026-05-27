import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class AddressService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  Future<List<AddressModel>> fetchAddresses(String uid) async {
    final snap = await _col(uid).get();
    return snap.docs
        .map((d) => AddressModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  Future<AddressModel> addAddress(String uid, AddressModel address) async {
    if (address.isDefault) {
      await _clearDefault(uid);
    }
    final ref = await _col(uid).add(address.toFirestore());
    return address.copyWith(id: ref.id);
  }

  Future<void> updateAddress(String uid, AddressModel address) async {
    if (address.isDefault) {
      await _clearDefault(uid, exceptId: address.id);
    }
    await _col(uid).doc(address.id).update(address.toFirestore());
  }

  Future<void> setDefault(String uid, String addressId) async {
    await _clearDefault(uid, exceptId: addressId);
    await _col(uid).doc(addressId).update({'is_default': true});
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _col(uid).doc(addressId).delete();
  }

  Future<void> _clearDefault(String uid, {String? exceptId}) async {
    final snap = await _col(uid).where('is_default', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id != exceptId) {
        batch.update(doc.reference, {'is_default': false});
      }
    }
    await batch.commit();
  }
}