import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/blood_request_model.dart';
import '../../widgets/blood_group_badge.dart';
import '../../constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

// DonorListScreen lets users search for blood donors by blood group + city.
// It pre-fills the city from the logged-in user's profile.
class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  String? _selectedBloodGroup;
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill city from current user's profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        _cityController.text = user.city;
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _search() {
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city')),
      );
      return;
    }
    context.read<DonorProvider>().searchDonors(
          bloodGroup: _selectedBloodGroup!,
          city: _cityController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Find Donors')),
      body: Column(
        children: [
          // Search filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodGroup,
                  decoration: InputDecoration(
                    hintText: 'Select Blood Group Needed',
                    prefixIcon: const Icon(Icons.water_drop),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: BloodGroups.all
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'City',
                    prefixIcon: const Icon(Icons.location_city),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: donorProvider.isLoading ? null : _search,
                    icon: donorProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.search),
                    label: Text(
                        donorProvider.isLoading ? 'Searching...' : 'Search'),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: donorProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !donorProvider.hasSearched
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Search for donors above',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : donorProvider.donors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off,
                                    size: 60, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No donors found in ${donorProvider.selectedCity}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const Text(
                                  'Try a nearby city',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: donorProvider.donors.length,
                            itemBuilder: (context, i) =>
                                _DonorCard(donor: donorProvider.donors[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  final UserModel donor;
  const _DonorCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with first letter of name
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                donor.name.isNotEmpty ? donor.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donor.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(donor.city,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  if (donor.isAvailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: AppColors.success),
                          SizedBox(width: 4),
                          Text('Available',
                              style: TextStyle(
                                  color: AppColors.success, fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                BloodGroupBadge(bloodGroup: donor.bloodGroup),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => _callPhone(donor.phone),
                  icon: const Icon(Icons.phone),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
