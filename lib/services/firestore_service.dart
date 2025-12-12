import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_provider_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createServiceProvider(ServiceProviderModel provider) async {
    try {
      await _firestore.collection('service_providers').doc(provider.uid).set(provider.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateServiceProvider(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('service_providers').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAvailability(String uid, bool isAvailable) async {
    try {
      await _firestore.collection('service_providers').doc(uid).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<ServiceProviderModel?> getServiceProvider(String uid) {
    return _firestore
        .collection('service_providers')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ServiceProviderModel.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }

  Stream<List<ServiceProviderModel>> getAllServiceProviders() {
    return _firestore
        .collection('service_providers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceProviderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ServiceProviderModel>> getProvidersByCategory(String category) {
    return _firestore
        .collection('service_providers')
        .where('serviceCategory', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceProviderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
