import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/blood_request_model.dart';

// DonorProvider manages the "Find Donors" screen.
// It handles searching Firestore for donors by blood group + city.
class DonorProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _donors = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedBloodGroup = '';
  String _selectedCity = '';

  List<UserModel> get donors => _donors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedBloodGroup => _selectedBloodGroup;
  String get selectedCity => _selectedCity;
  bool get hasSearched => _selectedBloodGroup.isNotEmpty;

  // Search for compatible donors
  // Automatically expands to compatible blood groups (e.g., O- can donate to A+)
  Future<void> searchDonors({
    required String bloodGroup,
    required String city,
  }) async {
    _selectedBloodGroup = bloodGroup;
    _selectedCity = city;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get all blood groups that are compatible donors for this blood group
      final compatible = BloodGroups.compatibleDonors[bloodGroup] ?? [bloodGroup];

      final results = await _firestoreService.getCompatibleDonors(
        bloodGroups: compatible,
        city: city,
      );

      // Sort: exact blood group match first, then others
      results.sort((a, b) {
        if (a.bloodGroup == bloodGroup && b.bloodGroup != bloodGroup) return -1;
        if (b.bloodGroup == bloodGroup && a.bloodGroup != bloodGroup) return 1;
        return a.name.compareTo(b.name);
      });

      _donors = results;
    } catch (e) {
      _errorMessage = 'Search failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _donors = [];
    _selectedBloodGroup = '';
    _selectedCity = '';
    _errorMessage = null;
    notifyListeners();
  }
}
