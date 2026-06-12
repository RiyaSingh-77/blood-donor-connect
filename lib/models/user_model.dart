import 'package:cloud_firestore/cloud_firestore.dart';

// This class represents a user in our app.
// Every donor IS a user. Every user CAN be a donor.
// When we save to Firestore, we call toMap().
// When we read from Firestore, we call fromMap().
class UserModel {
  final String uid;           // Firebase Auth UID — unique forever
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;    // e.g. "A+", "O-", "AB+"
  final String city;
  final GeoPoint? location;   // GPS coordinates (latitude, longitude)
  final bool isAvailable;     // true = willing to donate right now
  final DateTime? lastDonated;
  final String photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.city,
    this.location,
    this.isAvailable = true,
    this.lastDonated,
    this.photoUrl = '',
    required this.createdAt,
  });

  // Convert UserModel → Map so Firestore can store it
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'city': city,
      'location': location,
      'isAvailable': isAvailable,
      'lastDonated': lastDonated != null ? Timestamp.fromDate(lastDonated!) : null,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert Firestore document snapshot → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      city: map['city'] ?? '',
      location: map['location'],
      isAvailable: map['isAvailable'] ?? true,
      lastDonated: map['lastDonated'] != null
          ? (map['lastDonated'] as Timestamp).toDate()
          : null,
      photoUrl: map['photoUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Create a copy with some fields changed (useful in Provider when updating profile)
  UserModel copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    String? city,
    GeoPoint? location,
    bool? isAvailable,
    DateTime? lastDonated,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      city: city ?? this.city,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonated: lastDonated ?? this.lastDonated,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
