// lib/models/token_model.dart

class CheckResult {
  final bool pass;
  final String reason;
  final Map<String, dynamic>? details;

  CheckResult({
    required this.pass,
    required this.reason,
    this.details,
  });

  factory CheckResult.fromJson(Map<String, dynamic> json) => CheckResult(
    pass: json['pass'] == true,
    reason: (json['reason'] ?? '').toString(),
    details: json['details'] is Map<String, dynamic>
        ? (json['details'] as Map<String, dynamic>)
        : null,
  );
}

/// 4/4 sıra: GoPlus, QuickIntel, TokenSniffer, Honeypot
class TokenChecks {
  final CheckResult goPlus;
  final CheckResult quickIntel;
  final CheckResult tokenSniffer;
  final CheckResult honeypot;

  // (İsteğe bağlı) extra gösterge
  final CheckResult bscScan;   // bazı backend’lerde gelebilir
  final CheckResult liquidity; // UI’de sayısal alan da var ama koruyalım

  TokenChecks({
    required this.goPlus,
    required this.quickIntel,
    required this.tokenSniffer,
    required this.honeypot,
    required this.bscScan,
    required this.liquidity,
  });

  factory TokenChecks.fromJson(Map<String, dynamic> json) => TokenChecks(
    goPlus: CheckResult.fromJson(
        (json['goPlus'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': false, 'reason': '—'}),
    quickIntel: CheckResult.fromJson(
        (json['quickIntel'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': false, 'reason': '—'}),
    tokenSniffer: CheckResult.fromJson(
        (json['tokenSniffer'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': false, 'reason': '—'}),
    honeypot: CheckResult.fromJson(
        (json['honeypot'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': false, 'reason': '—'}),
    bscScan: CheckResult.fromJson(
        (json['bscScan'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': true, 'reason': '—'}),
    liquidity: CheckResult.fromJson(
        (json['liquidity'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{'pass': true, 'reason': '—'}),
  );

  /// 4/4 yalnızca bu dört kontrol
  int get passedCount =>
      (goPlus.pass ? 1 : 0) +
          (quickIntel.pass ? 1 : 0) +
          (tokenSniffer.pass ? 1 : 0) +
          (honeypot.pass ? 1 : 0);
}

class TokenModel {
  final String address;
  final String name;
  final String symbol;

  /// backend: priceUsd
  final double priceUsd;

  /// backend: liquidityUSD (bazı sürümlerde liquidityUsd olabilir)
  final double liquidityUsd;

  final double priceChange24h;
  final String pairAddress;
  final String dexScreenerUrl;

  final TokenChecks checks;
  final bool verified;
  final int? verifiedAt;
  final int? createdAt;
  final String? status;

  TokenModel({
    required this.address,
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.liquidityUsd,
    required this.priceChange24h,
    required this.pairAddress,
    required this.dexScreenerUrl,
    required this.checks,
    required this.verified,
    required this.verifiedAt,
    required this.createdAt,
    required this.status,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final liqRaw = json.containsKey('liquidityUSD')
        ? json['liquidityUSD']
        : json['liquidityUsd'];

    return TokenModel(
      address: (json['address'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      symbol: (json['symbol'] ?? 'Unknown').toString(),
      priceUsd: _toDouble(json['priceUsd'] ?? json['price']),
      liquidityUsd: _toDouble(liqRaw ?? json['liquidity']),
      priceChange24h: _toDouble(json['priceChange24h']),
      pairAddress: (json['pairAddress'] ?? '').toString(),
      dexScreenerUrl: (json['dexScreenerUrl'] ?? '').toString(),
      checks: TokenChecks.fromJson(
          (json['checks'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{}),
      verified: json['verified'] == true,
      verifiedAt: json['verifiedAt'] is int ? json['verifiedAt'] as int : null,
      createdAt: json['createdAt'] is int ? json['createdAt'] as int : null,
      status: json['status']?.toString(),
    );
  }

  // === Geriye dönük ===
  String get price => priceUsd.toString(); // widget: double.parse(token.price)
  double get liquidity => liquidityUsd;

  String get priceChangeFormatted {
    final sign = priceChange24h >= 0 ? '+' : '';
    return '$sign${priceChange24h.toStringAsFixed(2)}%';
  }

  bool get isNew {
    if (createdAt == null) return false;
    final ageHours =
        (DateTime.now().millisecondsSinceEpoch - createdAt!) / (1000 * 60 * 60);
    return ageHours < 24;
  }

  String get liquidityFormatted {
    final v = liquidityUsd;
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(2)}';
  }

  String get priceUsdFormatted =>
      priceUsd == 0 ? '\$0.00000000' : '\$${priceUsd.toStringAsFixed(8)}';
}

class TokenStats {
  final int totalVerified;
  final int new24h;
  final String passRate;

  const TokenStats({
    required this.totalVerified,
    required this.new24h,
    required this.passRate,
  });

  factory TokenStats.fromJson(Map<String, dynamic> json) => TokenStats(
    totalVerified: (json['totalVerified'] ?? 0) as int,
    new24h: (json['new24h'] ?? 0) as int,
    passRate: (json['passRate'] ?? '0%').toString(),
  );
}
