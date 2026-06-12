import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/blood_request_model.dart';
import '../../widgets/request_card.dart';
import '../../constants/app_colors.dart';
import '../donor/donor_list_screen.dart';
import '../request/request_blood_screen.dart';
import '../profile/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// HomeScreen is the main screen after login.
// It has a BottomNavigationBar with 4 tabs:
//   0. Home  — live feed of open blood requests
//   1. Find  — search for donors by blood group + city
//   2. Request — post a new blood request
//   3. Profile — view/edit your profile
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Pages correspond to each bottom tab
  final List<Widget> _pages = const [
    _HomePage(),
    DonorListScreen(),
    RequestBloodScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // IndexedStack keeps all pages alive (doesn't rebuild on tab switch)
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Request'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Home tab: live Firestore stream of open requests ──────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final requestProvider = context.read<RequestProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donor Connect'),
        actions: [
          // Blood group badge in app bar
          if (user != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.bloodGroup,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          if (user != null)
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Hello, ${user.name.split(' ').first} 👋',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
            ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // StreamBuilder listens to Firestore in real-time.
          // When a new request is added, this list updates immediately.
          Expanded(
            child: StreamBuilder<List<BloodRequestModel>>(
              stream: requestProvider.getOpenRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load requests.'));
                }
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No open requests right now.',
                            style: TextStyle(color: Colors.grey)),
                        Text('Tap "Request" below to post one.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return RequestCard(
                      request: req,
                      onContact: () => _callPhone(req.requesterPhone),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Open the phone dialer with the requester's number
  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
