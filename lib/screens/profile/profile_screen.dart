import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/blood_request_model.dart';
import '../../widgets/blood_group_badge.dart';
import '../../widgets/request_card.dart';
import '../../constants/app_colors.dart';

// ProfileScreen shows:
//   - The user's blood group, name, city
//   - A toggle to mark themselves as "Available to donate"
//   - Their posted blood requests
//   - Logout button
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmLogout(context, authProvider),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BloodGroupBadge(bloodGroup: user.bloodGroup),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            Text(user.city,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user.phone,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Availability toggle — this is the #1 most important feature for a donor
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                value: user.isAvailable,
                onChanged: (val) =>
                    authProvider.updateAvailability(val),
                activeThumbColor: AppColors.success,
                title: const Text('Available to Donate',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  user.isAvailable
                      ? 'You appear in donor searches'
                      : 'You are hidden from donor searches',
                  style: TextStyle(
                    color: user.isAvailable
                        ? AppColors.success
                        : Colors.grey,
                  ),
                ),
                secondary: Icon(
                  user.isAvailable
                      ? Icons.volunteer_activism
                      : Icons.do_not_disturb,
                  color: user.isAvailable
                      ? AppColors.success
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // My posted requests
            const Text('My Requests',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<List<BloodRequestModel>>(
              stream: context
                  .read<RequestProvider>()
                  .getMyRequestsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text("You haven't posted any requests yet.",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return ListView.builder(
                  // Disable inner scroll since we're inside SingleChildScrollView
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, i) => RequestCard(
                    request: requests[i],
                    onContact: null, // it's your own request
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authProvider.signOut();
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
