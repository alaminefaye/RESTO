import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'] as String?;
        _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
        
        // Sauvegarder le token
        if (_token != null) {
          await _saveToken(_token!);
          _apiService.setToken(_token);
        }

        notifyListeners();
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'message': 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.post(ApiConfig.logout);
      }
    } catch (e) {
      // Ignorer les erreurs de logout
    } finally {
      _token = null;
      _currentUser = null;
      await _clearToken();
      _apiService.setToken(null);
      notifyListeners();
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      _token = token;
      _apiService.setToken(token);
      
      // Récupérer les infos utilisateur
      try {
        final response = await _apiService.get(ApiConfig.me);
        if (response.statusCode == 200) {
          _currentUser = User.fromJson(response.data['data'] as Map<String, dynamic>);
          notifyListeners();
          return true;
        }
      } catch (e) {
        await _clearToken();
        return false;
      }
    }
    
    return false;
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Supprimer le token
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

