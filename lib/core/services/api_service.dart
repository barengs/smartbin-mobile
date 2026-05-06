import 'package:dio/dio.dart';
import '../config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  Future<Response> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
    required String passwordConfirmation,
    required String pin,
    required String ktpId,
  }) async {
    try {
      return await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'pin': pin,
        'ktp_id': ktpId,
      });
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> login(String login, String password) async {
    try {
      return await _dio.post('/auth/login', data: {
        'login': login,
        'email': login, // Send both to satisfy backend validators
        'password': password,
      });
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile(String token) async {
    try {
      return await _dio.get('/auth/me', options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> getTransactions(String token) async {
    try {
      return await _dio.get('/transactions', options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> getSmartBins({double? lat, double? lng}) async {
    try {
      Map<String, dynamic> params = {};
      if (lat != null && lng != null) {
        params['latitude'] = lat;
        params['longitude'] = lng;
        params['radius'] = 10;
      }
      return await _dio.get('/smart-bins', queryParameters: params);
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> redeemPoints(String token, int points, String ewalletType, String ewalletAccount) async {
    try {
      return await _dio.post('/redeem', 
        data: {
          'points': points,
          'ewallet_type': ewalletType,
          'ewallet_account': ewalletAccount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        )
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteAccount(String token) async {
    try {
      return await _dio.delete('/auth/delete', options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(String token, {required String name, required String phoneNumber}) async {
    try {
      return await _dio.put('/user/profile', 
        data: {
          'name': name,
          'phone_number': phoneNumber,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> changePassword(String token, {
    required String currentPassword, 
    required String newPassword, 
    required String newPasswordConfirmation
  }) async {
    try {
      return await _dio.put('/user/change-password', 
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
    } on DioException catch (e) {
      rethrow;
    }
  }
}
