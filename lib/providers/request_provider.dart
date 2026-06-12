import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/blood_request_model.dart';
import '../models/user_model.dart';

// RequestProvider manages everything about blood requests:
//   - The live feed of open requests (HomeScreen)
//   - Posting a new request (RequestBloodScreen)
//   - Marking a request as fulfilled (DonorDetailScreen)
class RequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Returns a real-time stream — HomeScreen passes this to StreamBuilder
  // Every time Firestore changes, StreamBuilder rebuilds automatically
  Stream<List<BloodRequestModel>> getOpenRequestsStream() {
    return _firestoreService.getOpenRequestsStream();
  }

  // Returns stream of only this user's requests (for Profile screen)
  Stream<List<BloodRequestModel>> getMyRequestsStream(String uid) {
    return _firestoreService.getMyRequestsStream(uid);
  }

  // Post a new blood request
  Future<bool> postRequest({
    required UserModel poster,      // the person posting (from AuthProvider)
    required String bloodGroup,
    required String hospital,
    required String city,
    required int unitsNeeded,
    required String urgency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = BloodRequestModel(
        id: '',                       // Firestore will assign a real ID
        requesterId: poster.uid,
        requesterName: poster.name,
        requesterPhone: poster.phone,
        bloodGroup: bloodGroup,
        hospital: hospital,
        city: city,
        unitsNeeded: unitsNeeded,
        urgency: urgency,
        status: RequestStatus.open,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createRequest(request);
      _successMessage = 'Request posted successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to post request. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markFulfilled(String requestId) async {
    await _firestoreService.markRequestFulfilled(requestId);
  }

  Future<void> deleteRequest(String requestId) async {
    await _firestoreService.deleteRequest(requestId);
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
