import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloood_donation_app/core/services/auth_service.dart';
import 'package:bloood_donation_app/core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;

  // Initialize user data
  Future<void> initUser() async {
    if (_authService.currentUser != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final userData = await _authService.getUserFromFirestore(
            _authService.currentUser!.uid);
        if (userData != null) {
          _user = userData;
        }
        _error = null;
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);
      final userData =
          await _authService.getUserFromFirestore(userCredential.user!.uid);
      if (userData != null) {
        _user = userData;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(
      String name, String email, String password, String phoneNumber, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential =
          await _authService.registerWithEmailAndPassword(email, password);
      
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );
      
      await _authService.createUserInFirestore(newUser);
      _user = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset error
  void resetError() {
    _error = null;
    notifyListeners();
  }
}

