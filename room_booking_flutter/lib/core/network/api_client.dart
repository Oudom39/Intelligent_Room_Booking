import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  Future<String?> _getCsrfToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('csrf_token');
  }

  Future<Map<String, String>> _buildHeaders({bool withAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      final csrf = await _getCsrfToken();
      if (token != null) headers['Authorization'] = 'Token $token';
      if (csrf != null) headers['X-CSRFToken'] = csrf;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? params, bool withAuth = true}) async {
    var uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    try {
      final response = await _client.get(
        uri,
        headers: await _buildHeaders(withAuth: withAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _client.post(
        uri,
        headers: await _buildHeaders(withAuth: withAuth),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      }
      return {'success': false, ...data};
    } catch (_) {
      return {
        'success': false,
        'error': 'Invalid server response (${response.statusCode})',
      };
    }
  }

  Future<void> saveSession(String token, String csrf) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
    await prefs.setString('csrf_token', csrf);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('csrf_token');
  }
}
