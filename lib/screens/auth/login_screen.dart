import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import 'signup_screen.dart';

// LoginScreen is now a StatefulWidget because it holds:
//   1. TextEditingControllers (to read what the user typed)
//   2. A GlobalKey<FormState> (to trigger validation on all fields at once)
//   3. A _obscurePassword bool (to toggle show/hide password)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate all fields. If any validator returns an error string, stop here.
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (!success && mounted) {
      // Show the error from AuthProvider as a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // On success, main.dart's Consumer<AuthProvider> will automatically
    // navigate to HomeScreen because isLoggedIn becomes true.
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this widget whenever AuthProvider notifies
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bloodtype, size: 90, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    "Blood Donor Connect",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Connecting donors with lives",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // Email field — now uses CustomTextField with validator
                  CustomTextField(
                    hintText: "Email",
                    icon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),

                  // Password field with show/hide toggle
                  CustomTextField(
                    hintText: "Password",
                    icon: Icons.lock,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login button — shows spinner while loading
                  CustomButton(
                    text: "Login",
                    onPressed: _handleLogin,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 15),

                  // Go to signup
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text("Create Account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
