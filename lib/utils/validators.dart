// All form validation logic in one place.
// These functions are passed directly to TextFormField's validator parameter.
// They return null if valid, or an error string if invalid.
class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (value.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? units(String? value) {
    if (value == null || value.trim().isEmpty) return 'Units required';
    final n = int.tryParse(value.trim());
    if (n == null || n < 1) return 'Enter a valid number of units';
    return null;
  }
}
