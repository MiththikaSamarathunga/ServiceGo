import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String serviceCategory;
  final double latitude;
  final double longitude;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;
  final String? description;

  ServiceProviderModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceCategory,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.isAvailable,
    required this.createdAt,
    this.description,
  });

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map, String uid) {
    return ServiceProviderModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      serviceCategory: map['serviceCategory'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'serviceCategory': serviceCategory,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
    };
  }

  ServiceProviderModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? serviceCategory,
    double? latitude,
    double? longitude,
    String? location,
    bool? isAvailable,
    DateTime? createdAt,
    String? description,
  }) {
    return ServiceProviderModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}
