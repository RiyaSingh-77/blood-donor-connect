import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/blood_request_model.dart';

// FirestoreService is the ONLY place in the app that talks to Firestore.
// All providers call this service. This keeps database logic separate from UI logic.
//
// Firestore structure:
//   /users/{uid}                    → user profile
//   /blood_requests/{requestId}     → blood requests posted by users
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // USER operations
  // ─────────────────────────────────────────────

  // Save a new user profile to Firestore after signup
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Read a single user's profile by their uid
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // Update specific fields in a user document (e.g., toggling availability)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Get all donors matching a blood group in a city
  // This is what the "Find Donors" screen uses
  Future<List<UserModel>> getDonorsByBloodGroupAndCity({
    required String bloodGroup,
    required String city,
  }) async {
    final snap = await _db
        .collection('users')
        .where('isAvailable', isEqualTo: true)
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('city', isEqualTo: city)
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  // Search donors by multiple compatible blood groups + city
  Future<List<UserModel>> getCompatibleDonors({
    required List<String> bloodGroups,
    required String city,
  }) async {
    final snap = await _db
        .collection('users')
        .where('isAvailable', isEqualTo: true)
        .where('bloodGroup', whereIn: bloodGroups)
        .where('city', isEqualTo: city)
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  // ─────────────────────────────────────────────
  // BLOOD REQUEST operations
  // ─────────────────────────────────────────────

  // Post a new blood request
  Future<void> createRequest(BloodRequestModel request) async {
    await _db.collection('blood_requests').add(request.toMap());
  }

  // Real-time stream of all OPEN requests — HomeScreen listens to this
  // Every time a new request is added, the HomeScreen rebuilds automatically
  Stream<List<BloodRequestModel>> getOpenRequestsStream() {
    return _db
        .collection('blood_requests')
        .where('status', isEqualTo: RequestStatus.open)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BloodRequestModel.fromMap(d.id, d.data()))
            .toList());
  }

  // Get requests posted by a specific user (for "My Requests" section on profile)
  Stream<List<BloodRequestModel>> getMyRequestsStream(String uid) {
    return _db
        .collection('blood_requests')
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BloodRequestModel.fromMap(d.id, d.data()))
            .toList());
  }

  // Mark a request as fulfilled (when donor is found)
  Future<void> markRequestFulfilled(String requestId) async {
    await _db.collection('blood_requests').doc(requestId).update({
      'status': RequestStatus.fulfilled,
    });
  }

  // Delete a request (only the owner should be able to do this — enforced by Firestore rules)
  Future<void> deleteRequest(String requestId) async {
    await _db.collection('blood_requests').doc(requestId).delete();
  }
}
