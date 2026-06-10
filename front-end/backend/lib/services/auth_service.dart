import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:backend/screens/api_service.dart';

class SocialAuthAccount {
  const SocialAuthAccount({
    required this.provider,
    required this.email,
    required this.username,
  });

  final String provider;
  final String email;
  final String username;
}

abstract class AuthService {
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> login({required String email, required String password});

  Future<void> signInWithGoogle({bool createAccount = false});

  Future<void> signInWithFacebook({
    bool createAccount = false,
    Future<bool> Function(SocialAuthAccount account)? confirmAccount,
  });
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiAuthService implements AuthService {
  const ApiAuthService();

  /// ⚠️ QUAN TRỌNG: Đây phải là WEB CLIENT ID (không phải Android Client ID)
  /// Lấy tại: Google Cloud Console → APIs & Services → Credentials
  ///           → OAuth 2.0 Client IDs → loại "Web application"
  static const _googleWebClientId =
      '674711674566-kemn1hqtchf4vg7dg3m7uc4hkgm9knal.apps.googleusercontent.com';

  static String get _baseUrl => ApiService.baseUrl;

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) {
    return _authenticate(
      path: '/api/auth/register',
      body: {'name': username, 'email': email, 'password': password},
    );
  }

  @override
  Future<void> login({required String email, required String password}) {
    return _authenticate(
      path: '/api/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  @override
  Future<void> signInWithGoogle({bool createAccount = false}) async {
    try {
      final googleSignIn = GoogleSignIn(serverClientId: _googleWebClientId);

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      debugLog('Google: bắt đầu signIn...');

      final GoogleSignInAccount? googleUser = await googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugLog('Google: TIMEOUT chọn tài khoản');
              throw const AuthException(
                'Google sign-in timeout. Vui lòng thử lại.',
              );
            },
          );

      if (googleUser == null) {
        debugLog('Google: người dùng huỷ');
        throw const AuthException('Google sign-in cancelled');
      }

      debugLog('Google: đã chọn tài khoản ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugLog('Google: TIMEOUT lấy authentication');
              throw const AuthException(
                'Google authentication timeout. Vui lòng thử lại.',
              );
            },
          );

      if (googleAuth.idToken == null) {
        debugLog(
          'Google: idToken = null → sai serverClientId hoặc thiếu SHA-1',
        );
        throw const AuthException(
          'Không lấy được idToken.\n'
          '→ Kiểm tra serverClientId phải là Web Client ID\n'
          '→ Kiểm tra SHA-1 fingerprint trong Firebase Console',
        );
      }

      debugLog('Google: có idToken, đăng nhập Firebase...');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugLog('Google: TIMEOUT Firebase signInWithCredential');
              throw const AuthException(
                'Firebase auth timeout. Vui lòng thử lại.',
              );
            },
          );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugLog('Google: Firebase trả về user null');
        throw const AuthException('Google login failed');
      }

      debugLog('Google: Firebase OK → gọi backend /api/auth/google...');

      await _authenticate(
        path: '/api/auth/google',
        body: {
          'idToken': googleAuth.idToken ?? '',
          'action': createAccount ? 'signup' : 'login',
        },
      );

      debugLog('Google: đăng nhập thành công!');
    } on AuthException {
      rethrow;
    } catch (e) {
      debugLog('Google: lỗi không xác định → $e');
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signInWithFacebook({
    bool createAccount = false,
    Future<bool> Function(SocialAuthAccount account)? confirmAccount,
  }) async {
    try {
      // logOut trước để xóa session cũ, tránh bị treo
      await FacebookAuth.instance.logOut().catchError((_) {});

      debugLog('Facebook: bắt đầu login...');

      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        debugLog('Facebook: người dùng huỷ');
        throw const AuthException('Facebook sign-in cancelled');
      }

      final accessToken = result.accessToken;
      if (result.status != LoginStatus.success || accessToken == null) {
        debugLog('Facebook: login thất bại → ${result.message}');
        throw AuthException(result.message ?? 'Facebook login failed');
      }

      debugLog('Facebook: có accessToken, lấy user data...');

      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,id',
      );

      final String facebookId = userData['id']?.toString() ?? '';
      final String rawEmail =
          userData['email']?.toString().trim().toLowerCase() ?? '';
      final String username = userData['name']?.toString().trim() ?? '';

      final String email = rawEmail.isNotEmpty
          ? rawEmail
          : 'fb_$facebookId@noemail.placeholder';

      debugLog('Facebook: email=$email, username=$username');

      final account = SocialAuthAccount(
        provider: 'Facebook',
        email: email,
        username: username.isEmpty ? email : username,
      );

      if (createAccount && confirmAccount != null) {
        final confirmed = await confirmAccount(account);
        if (!confirmed) {
          throw const AuthException('Facebook sign-up cancelled');
        }
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        debugLog('Facebook: Firebase trả về user null');
        throw const AuthException('Facebook login failed');
      }

      debugLog('Facebook: Firebase OK → gọi backend /api/auth/facebook...');

      await _authenticate(
        path: '/api/auth/facebook',
        body: {
          'accessToken': accessToken.tokenString,
          'action': createAccount ? 'signup' : 'login',
        },
      );

      debugLog('Facebook: đăng nhập thành công!');
    } on AuthException {
      rethrow;
    } catch (e) {
      debugLog('Facebook: lỗi không xác định → $e');
      throw AuthException(e.toString());
    }
  }

  Future<void> _authenticate({
    required String path,
    required Map<String, String> body,
  }) async {
    debugLog('API: POST $_baseUrl$path');
    debugLog('API: body = $body');

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugLog('API: TIMEOUT $_baseUrl$path');
              throw const AuthException(
                'Kết nối đến server quá chậm. Vui lòng kiểm tra lại mạng hoặc IP server.',
              );
            },
          );
    } on AuthException {
      rethrow;
    } catch (e) {
      debugLog('API: lỗi kết nối → $e');
      throw AuthException('Không thể kết nối server: $e');
    }

    debugLog('API: response ${response.statusCode} → ${response.body}');

    final data = _decodeResponse(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (path.endsWith('/login') && response.statusCode == 401) {
        throw const AuthException('Email or password is incorrect');
      }
      throw AuthException(_extractErrorMessage(data, 'Authentication failed'));
    }

    final token = (data['accessToken'] ?? data['access_token'] ?? data['token'])
        ?.toString();
    if (token == null || token.isEmpty) {
      debugLog('API: backend không trả token!');
      throw const AuthException('Backend did not return a token');
    }

    debugLog('API: lưu token thành công');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    final refreshToken =
        (data['refreshToken'] ?? data['refresh_token'])?.toString();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }

  String _extractErrorMessage(Map<String, dynamic> data, String fallback) {
    final message = data['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    if (data.isNotEmpty) {
      final first = data.values.firstWhere(
        (value) => value != null && value.toString().isNotEmpty,
        orElse: () => null,
      );
      if (first != null) return first.toString();
    }

    return fallback;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (e) {
      debugLog('API: không parse được JSON response → $e');
    }
    return {};
  }

  /// Debug log — chỉ in khi chạy debug mode, tự tắt khi release
  void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print('[AuthService] $message');
      return true;
    }());
  }
}
