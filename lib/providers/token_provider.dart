import 'package:flutter/material.dart';
import '../models/token_model.dart';
import '../services/api_service.dart';

class TokenProvider with ChangeNotifier {
  List<TokenModel> _tokens = [];
  TokenStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<TokenModel> get tokens => _tokens;
  TokenStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTokens({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.getTokens(limit: limit);

    if (result['success']) {
      _tokens = result['tokens'];
      _stats = result['stats'];
      _error = null;
    } else {
      _error = result['error'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> triggerScan() async {
    final result = await ApiService.triggerScan();

    if (result['success']) {
      await Future.delayed(const Duration(seconds: 2));
      await loadTokens();
    } else {
      _error = result['error'];
      notifyListeners();
    }
  }

  /// Search bar için: tek address analizi
  Future<TokenModel?> getTokenDetails(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    final result = await ApiService.getToken(trimmed);

    if (result['success']) {
      final TokenModel token = result['token'];

      // Listede yoksa başa ekle, varsa güncelle
      final idx = _tokens.indexWhere(
            (t) => t.address.toLowerCase() == token.address.toLowerCase(),
      );

      if (idx == -1) {
        _tokens = [token, ..._tokens];
      } else {
        _tokens[idx] = token;
      }

      notifyListeners();
      return token;
    } else {
      _error = result['error'];
      notifyListeners();
      return null;
    }
  }
}
