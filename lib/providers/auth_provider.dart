import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  String? _error;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get firebaseUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> loadUserData() async {
    if (_authService.currentUser != null) {
      try {
        _currentUser = await _authService
            .getUserData(_authService.currentUser!.uid)
            .timeout(const Duration(seconds: 10));
        if (_currentUser == null) {
          final user = _authService.currentUser; 
          final uid = user!.uid;
          final email = user.email ?? '';
          final name = user.displayName ?? '';
          final phone = '';
          final userType = '';
          try {
            await _authService.createUserDocument(
              uid: uid,
              email: email,
              name: name,
              phone: phone,
              userType: userType,
            ).timeout(const Duration(seconds: 8));

            _currentUser = UserModel(
              uid: uid,
              email: email,
              name: name,
              phone: phone,
              userType: userType,
              createdAt: DateTime.now(),
            );
          } catch (e) {
            _error = 'Failed to create user profile: $e';
          }
        }
      } catch (e) {
        _error = 'Failed to load user data: $e';
      }
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      _authService.createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        userType: userType,
      ).catchError((e) {
        _error = 'Failed to write user data: $e';
      });
      loadUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        _error = 'Request timed out. Check your network or Firebase configuration.';
      } else {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      await _authService
          .signInWithEmail(
        email: email,
        password: password,
      )
          .timeout(const Duration(seconds: 15));

      await loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        _error = 'Request timed out. Check your network or Firebase configuration.';
      } else {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

}
