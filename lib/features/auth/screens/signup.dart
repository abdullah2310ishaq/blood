import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String contact = '';
  String city = '';
  // Role selection with default value (can be 'donor' or 'receiver')
  String role = 'donor';

  final AuthService _authService = AuthService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }
      setState(() => isLoading = true);
      try {
        // Register the user along with the selected role.
        // Here, the role field will be saved in Firestore.
        await _authService.registerWithEmail(
          name: name,
          email: email,
          password: password,
          contact: contact,
          city: city,
          role: role, // Passing the selected role.
        );
        // After successful registration, navigate to profile completion or dashboard.
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Logo at the top.
                      Center(
                        child: Image.asset('assets/logo.jpg', width: 120),
                      ),
                      const SizedBox(height: 24),
                      // Name field.
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => name = val,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your name" : null,
                      ),
                      const SizedBox(height: 16),
                      // Contact field.
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Contact",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => contact = val,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your contact" : null,
                      ),
                      const SizedBox(height: 16),
                      // City field.
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => city = val,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your city" : null,
                      ),
                      const SizedBox(height: 16),
                      // Email field.
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your email" : null,
                      ),
                      const SizedBox(height: 16),
                      // Password field.
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => password = val,
                        validator: (val) => val!.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password field.
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (val) => confirmPassword = val,
                        validator: (val) => val!.isEmpty
                            ? "Please confirm your password"
                            : null,
                      ),
                      const SizedBox(height: 24),
                      // Role selection: Radio Buttons for Donor and Receiver.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'donor',
                            groupValue: role,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                          const Text("Donor"),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'receiver',
                            groupValue: role,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                          const Text("Receiver"),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Register button.
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _register,
                          child: const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
