import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// A red badge that shows the blood group (e.g. "A+", "O-")
// Used on donor cards and request cards throughout the app.
class BloodGroupBadge extends StatelessWidget {
  final String bloodGroup;
  final double fontSize;

  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        bloodGroup,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
