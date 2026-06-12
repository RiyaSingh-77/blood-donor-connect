import 'package:flutter/material.dart';
import '../models/blood_request_model.dart';
import '../constants/app_colors.dart';
import 'blood_group_badge.dart';

// RequestCard displays one blood request in the HomeScreen feed.
// Shows blood group, hospital, city, urgency level, and contact button.
class RequestCard extends StatelessWidget {
  final BloodRequestModel request;
  final VoidCallback? onContact;   // called when "Contact" button is tapped

  const RequestCard({
    super.key,
    required this.request,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: blood group badge + urgency chip
            Row(
              children: [
                BloodGroupBadge(bloodGroup: request.bloodGroup),
                const SizedBox(width: 10),
                _UrgencyChip(urgency: request.urgency),
                const Spacer(),
                Text(
                  _timeAgo(request.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hospital and city
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.hospital,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(request.city, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.water_drop, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${request.unitsNeeded} unit(s) needed',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // Contact button — calls whoever posted this request
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.phone, size: 16),
                label: Text('Contact ${request.requesterName}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show "2h ago", "1d ago" etc. instead of raw timestamps
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// Small colored chip showing urgency level
class _UrgencyChip extends StatelessWidget {
  final String urgency;
  const _UrgencyChip({required this.urgency});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (urgency) {
      case Urgency.critical: color = Colors.red.shade700; break;
      case Urgency.urgent:   color = AppColors.warning;   break;
      default:               color = AppColors.success;   break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        urgency,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
