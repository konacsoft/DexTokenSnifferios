import 'package:flutter/material.dart';
import '../models/token_model.dart';
import '../theme/app_theme.dart';

class TokenDetailModal extends StatelessWidget {
  final TokenModel token;

  const TokenDetailModal({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accentColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Why this token is SAFE',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Token Information',
                    [
                      _buildDetailRow('Name', token.name),
                      _buildDetailRow('Symbol', token.symbol),
                      _buildDetailRow('Address', token.address, monospace: true),
                      _buildDetailRow('Price', '\$${double.parse(token.price).toStringAsFixed(8)}'),
                      _buildDetailRow('Liquidity', token.liquidityFormatted),
                      _buildDetailRow('24h Change', token.priceChangeFormatted),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Security Checks (4/4)',
                    [
                      _buildCheckDetail('GoPlus Security', token.checks.goPlus),
                      _buildCheckDetail('Honeypot Check', token.checks.honeypot),
                      _buildCheckDetail('BscScan Analysis', token.checks.bscScan),
                      _buildCheckDetail('Liquidity & LP Lock', token.checks.liquidity),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Heuristic detection only – not financial advice. Always DYOR.',
                            style: TextStyle(
                              color: AppTheme.textColor.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool monospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckDetail(String label, CheckResult check) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: check.pass ? AppTheme.accentColor.withOpacity(0.3) : AppTheme.redColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                check.pass ? Icons.check_circle : Icons.cancel,
                color: check.pass ? AppTheme.accentColor : AppTheme.redColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            check.reason,
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          if (check.details != null && check.details!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...check.details!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• ${entry.key}: ${entry.value}',
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
