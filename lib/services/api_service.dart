// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/token_model.dart';

class ApiService {
  /* ------------ Base URL & (optional) Basic Auth ------------ */
  static String get baseUrl => dotenv.env['API_URL'] ?? 'https://dextokensniffer-backend.onrender.com';

  static String get _username => dotenv.env['API_USERNAME'] ?? 'user';
  static String get _password => dotenv.env['API_PASSWORD'] ?? '';
  static Map<String, String> get _headers {
    if (_password.isNotEmpty) {
      final credentials = base64Encode(utf8.encode('$_username:$_password'));
      return {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  /* ------------ GET /tokens  (verified + candidates) ------------ */
  static Future<Map<String, dynamic>> getTokens({int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/tokens?limit=$limit');
      final res = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 12),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        // Verified tokens
        final List<TokenModel> verified = (data['tokens'] as List? ?? [])
            .map((e) => TokenModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Candidates (awaiting audits) — may not exist
        final List<TokenModel> candidates = (data['candidates'] as List? ?? [])
            .map((e) => TokenModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Merge into single list and order by (verifiedAt ?? createdAt) DESC
        final List<TokenModel> all = [...verified, ...candidates]
          ..sort((a, b) {
            final av = (a.verifiedAt ?? a.createdAt ?? 0);
            final bv = (b.verifiedAt ?? b.createdAt ?? 0);
            return bv.compareTo(av); // newest first
          });

        // Stats (fallback defaults)
        final TokenStats stats = data['stats'] != null
            ? TokenStats.fromJson(data['stats'] as Map<String, dynamic>)
            : const TokenStats(totalVerified: 0, new24h: 0, passRate: '0%');

        return {'success': true, 'tokens': all, 'stats': stats};
      }

      return {
        'success': false,
        'error': (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Unknown error'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /* ------------ GET /token/:address ------------ */
  static Future<Map<String, dynamic>> getToken(String address) async {
    try {
      final uri = Uri.parse('$baseUrl/token/$address');
      final res = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': TokenModel.fromJson(data['token'] as Map<String, dynamic>)
        };
      }

      return {
        'success': false,
        'error': (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Token not found'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /* ------------ GET /scan  (trigger backend scan) ------------ */
  static Future<Map<String, dynamic>> triggerScan() async {
    try {
      final uri = Uri.parse('$baseUrl/scan');
      final res = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 30),
      );

      final data = jsonDecode(res.body);
      return {
        'success': data is Map && data['success'] == true,
        'message': (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Scan completed'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
