// All user-facing strings in one place.
// If you ever want to add Hindi/regional language support,
// you only need to change this file.
class AppStrings {
  static const String appName = 'Blood Donor Connect';
  static const String tagline = 'Connecting donors with lives';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Create Account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phone = 'Phone Number';
  static const String bloodGroup = 'Blood Group';
  static const String city = 'City';
  static const String forgotPassword = 'Forgot Password?';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = "Don't have an account? Sign Up";

  // Home
  static const String home = 'Home';
  static const String findDonors = 'Find Donors';
  static const String requestBlood = 'Request Blood';
  static const String myProfile = 'My Profile';
  static const String recentRequests = 'Recent Requests';
  static const String nearbyDonors = 'Nearby Donors';

  // Request
  static const String hospital = 'Hospital Name';
  static const String unitsNeeded = 'Units Needed';
  static const String urgency = 'Urgency Level';
  static const String submitRequest = 'Submit Request';

  // Urgency levels
  static const String critical = 'Critical';
  static const String urgent = 'Urgent';
  static const String normal = 'Normal';

  // Profile
  static const String availableNow = 'Available to Donate';
  static const String lastDonated = 'Last Donated';
  static const String logout = 'Logout';

  // Errors
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String loginFailed = 'Login failed. Please check your credentials.';
  static const String signupFailed = 'Signup failed. Please try again.';
  static const String genericError = 'Something went wrong. Please try again.';
}
