import 'package:cloud_firestore/cloud_firestore.dart';

// Urgency levels — we use a class instead of plain strings
// so there are no typos and autocomplete works everywhere.
class Urgency {
  static const String critical = 'Critical'; // life-threatening, needs blood today
  static const String urgent   = 'Urgent';   // needs within 1-2 days
  static const String normal   = 'Normal';   // scheduled surgery, has time

  static List<String> get all => [critical, urgent, normal];
}

// Status of a request
class RequestStatus {
  static const String open      = 'Open';       // still looking for donors
  static const String fulfilled = 'Fulfilled';  // donor found
  static const String expired   = 'Expired';    // no longer needed
}

// All 8 blood groups
class BloodGroups {
  static const List<String> all = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Blood group compatibility chart (who can receive from whom)
  // Key = recipient, Value = list of donors who can give to them
  static const Map<String, List<String>> compatibleDonors = {
    'A+':  ['A+', 'A-', 'O+', 'O-'],
    'A-':  ['A-', 'O-'],
    'B+':  ['B+', 'B-', 'O+', 'O-'],
    'B-':  ['B-', 'O-'],
    'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // universal recipient
    'AB-': ['A-', 'B-', 'AB-', 'O-'],
    'O+':  ['O+', 'O-'],
    'O-':  ['O-'], // universal donor — can give to anyone
  };
}

class BloodRequestModel {
  final String id;              // Firestore document ID
  final String requesterId;     // uid of the person who posted this
  final String requesterName;
  final String requesterPhone;
  final String bloodGroup;      // which blood group is needed
  final String hospital;
  final String city;
  final GeoPoint? location;
  final int unitsNeeded;
  final String urgency;         // Critical / Urgent / Normal
  final String status;          // Open / Fulfilled / Expired
  final DateTime createdAt;

  BloodRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.bloodGroup,
    required this.hospital,
    required this.city,
    this.location,
    required this.unitsNeeded,
    required this.urgency,
    this.status = RequestStatus.open,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'bloodGroup': bloodGroup,
      'hospital': hospital,
      'city': city,
      'location': location,
      'unitsNeeded': unitsNeeded,
      'urgency': urgency,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BloodRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return BloodRequestModel(
      id: id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      hospital: map['hospital'] ?? '',
      city: map['city'] ?? '',
      location: map['location'],
      unitsNeeded: map['unitsNeeded'] ?? 1,
      urgency: map['urgency'] ?? Urgency.normal,
      status: map['status'] ?? RequestStatus.open,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
