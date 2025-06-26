// screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Care_Plus/services/auth_service.dart';
import 'package:Care_Plus/utils/validators.dart';
import 'package:Care_Plus/utils/dialog_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!isValidEmail(email)) {
      showInfoDialog(context, "Error", "Please enter a valid email address.");
      return;
    }
    if (password.length < 6) {
      showInfoDialog(context, "Error", "Password must be at least 6 characters.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.login(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      showInfoDialog(context, "Login Failed", e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Password", style: TextStyle(fontSize: 22)),
        content: TextFormField(
          controller: resetEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            labelText: "Enter your email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (isValidEmail(email)) {
                Navigator.pop(context);
                try {
                  await AuthService.sendPasswordResetEmail(email);
                  showInfoDialog(context, "Success", "Reset link sent to $email.");
                } catch (e) {
                  showInfoDialog(context, "Error", e.toString());
                }
              } else {
                showInfoDialog(context, "Error", "Invalid email address.");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/profile_avatar.png', width: 100, height: 100),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600 ? 26 : 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(fontSize: 18),
                        prefixIcon: const Icon(Icons.email, color: Colors.green),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(fontSize: 18),
                        prefixIcon: const Icon(Icons.lock, color: Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.green,
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("Login", style: TextStyle(fontSize: 22, color: Colors.white)),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _showResetPasswordDialog,
                      child: Text("Forgot password?", style: TextStyle(fontSize: 18, color: Colors.green.shade800)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: Text("Don't have an account? Register", style: TextStyle(fontSize: 18, color: Colors.green.shade800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
