import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/token_model.dart';
import '../theme/app_theme.dart';

class TokenCard extends StatelessWidget {
  final TokenModel token;
  final VoidCallback onTap;

  const TokenCard({
    super.key,
    required this.token,
    required this.onTap,
  });

  Future<void> _copyAddress(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: token.address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  Future<void> _openDexScreener(BuildContext context) async {
    String url = token.dexScreenerUrl;
    if (url.isEmpty && token.pairAddress.isNotEmpty) {
      url = 'https://dexscreener.com/bsc/${token.pairAddress}';
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DexScreener linki bulunamadı'),
          backgroundColor: AppTheme.redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const verifiedText = 'SAFE / 4/4 Verified';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${token.name} (BSC)',
                        style: const TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (token.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.verified, color: AppTheme.accentColor, size: 16),
                    SizedBox(width: 4),
                    Text(
                      verifiedText,
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.attach_money,
                        'Price',
                        '\$${double.parse(token.price).toStringAsFixed(8)}',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.water_drop,
                        'Liquidity',
                        token.liquidityFormatted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.trending_up,
                  '24h',
                  token.priceChangeFormatted,
                  valueColor: token.priceChange24h >= 0 ? AppTheme.accentColor : AppTheme.redColor,
                ),
                const SizedBox(height: 12),

                // 4/4: GoPlus, QuickIntel, TokenSniffer, Honeypot
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.settings, color: AppTheme.accentColor, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Checks:',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCheckRow('GoPlus', token.checks.goPlus.pass),
                      _buildCheckRow('QuickIntel', token.checks.quickIntel.pass),
                      _buildCheckRow('TokenSniffer', token.checks.tokenSniffer.pass),
                      _buildCheckRow('Honeypot', token.checks.honeypot.pass),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyAddress(context),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Address'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentColor,
                          side: const BorderSide(color: AppTheme.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openDexScreener(context),
                        icon: const Icon(Icons.bar_chart, size: 16),
                        label: const Text('DexScreener'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentColor,
                          side: const BorderSide(color: AppTheme.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor.withOpacity(0.7), size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget _buildCheckRow(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? AppTheme.accentColor : AppTheme.redColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
