import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _token;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  UserProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      await fetchProfile();
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    if (_token == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getProfile(_token!);
      if (response.data['success']) {
        _user = response.data['data']['user'];
      }
    } catch (e) {
      // If token expired, logout
      if (e is DioException && e.response?.statusCode == 401) {
        logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    if (_token == null) return false;
    try {
      final response = await _apiService.deleteAccount(_token!);
      if (response.data['success']) {
        await logout();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Account Error: $e');
    }
    return false;
  }
}
