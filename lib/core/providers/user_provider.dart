import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _token;
  Timer? _syncTimer;
  List<Map<String, dynamic>> _notifications = [];

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  List<Map<String, dynamic>> get notifications => _notifications;

  UserProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      await fetchProfile();
      _startSync();
    }
    notifyListeners();
  }

  void _startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_token != null) {
        _syncProfileQuietly();
      }
    });
  }

  Future<void> _syncProfileQuietly() async {
    try {
      final response = await _apiService.getProfile(_token!);
      if (response.data['success']) {
        final newUser = response.data['data']['user'];
        final oldPoints = num.tryParse(_user?['total_points']?.toString() ?? '0') ?? 0;
        final newPoints = num.tryParse(newUser['total_points']?.toString() ?? '0') ?? 0;

        if (newPoints > oldPoints) {
          _addNotification(
            'Poin Masuk!',
            'Hore! +${(newPoints - oldPoints).toInt()} poin berhasil ditambahkan ke saldo Anda.',
            Icons.stars,
            Colors.orange,
          );
        } else if (newPoints < oldPoints) {
           // Redemption handled in screen, but sync keeps data fresh
        }

        _user = newUser;
        notifyListeners();
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        logout();
      }
    }
  }

  void _addNotification(String title, String body, IconData icon, Color color) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'time': DateTime.now(),
      'icon': icon,
      'color': color,
      'isRead': false,
    });
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
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
      if (e is DioException && e.response?.statusCode == 401) {
        logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _syncTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
    _notifications.clear();
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

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
