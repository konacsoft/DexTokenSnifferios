import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/token_provider.dart';
import '../models/token_model.dart';
import '../theme/app_theme.dart';
import '../widgets/token_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/token_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showDisclaimer = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TokenProvider>(context, listen: false).loadTokens();
      _showDisclaimerDialog();
    });
  }

  void _showDisclaimerDialog() {
    if (_showDisclaimer) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.accentColor.withOpacity(0.3),
              ),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Disclaimer',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              ],
            ),
            content: const Text(
              'This app performs heuristic safety scans. Not investment advice. Always do your own research before investing in any token.',
              style: TextStyle(color: AppTheme.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showDisclaimer = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'I Understand',
                  style: TextStyle(color: AppTheme.accentColor),
                ),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> _searchToken() async {
    final address = _searchController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a token address'),
          backgroundColor: AppTheme.redColor,
        ),
      );
      return;
    }

    final provider = Provider.of<TokenProvider>(context, listen: false);
    final token = await provider.getTokenDetails(address);

    if (token != null) {
      _showTokenDetail(token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token not found or not verified as safe'),
          backgroundColor: AppTheme.redColor,
        ),
      );
    }
  }

  void _showTokenDetail(TokenModel token) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TokenDetailModal(token: token),
    );
  }

  Future<void> _triggerScan() async {
    final provider = Provider.of<TokenProvider>(context, listen: false);
    await provider.triggerScan();

    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan completed successfully'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Scan failed'),
          backgroundColor: AppTheme.redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<TokenProvider>(context, listen: false)
                .loadTokens();
          },
          color: AppTheme.accentColor,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DexTokenSniffer Pro',
                        style: Theme.of(context).textTheme.displayMedium,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        'KONACSOFT 4/4 Token Scanner',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppTheme.accentColor,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentColor.withOpacity(0),
                              AppTheme.accentColor,
                              AppTheme.accentColor.withOpacity(0),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 300.ms),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppTheme.textColor,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                'Enter BSC token address or press Scan',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppTheme.accentColor,
                                ),
                                // extra: ikonla da arama
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: AppTheme.accentColor,
                                  ),
                                  onPressed: _searchToken,
                                ),
                              ),
                              onSubmitted: (_) => _searchToken(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor,
                                  AppTheme.accentColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                // 🔥 Kutu doluysa adres tara, boşsa genel scan
                                onTap: () {
                                  if (_searchController.text
                                      .trim()
                                      .isNotEmpty) {
                                    _searchToken();
                                  } else {
                                    _triggerScan();
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(
                                    Icons.radar,
                                    color: AppTheme.backgroundColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate(
                              onPlay: (controller) =>
                                  controller.repeat())
                              .shimmer(
                            duration: 2000.ms,
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 300.ms),
                      const SizedBox(height: 24),
                      Consumer<TokenProvider>(
                        builder: (context, provider, child) {
                          if (provider.stats != null) {
                            return Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.verified,
                                    label: 'Verified',
                                    value: provider.stats!.totalVerified
                                        .toString(),
                                    color: AppTheme.accentColor,
                                  )
                                      .animate()
                                      .fadeIn(delay: 400.ms)
                                      .scale(
                                      begin: const Offset(0.8, 0.8)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.access_time,
                                    label: '24h New',
                                    value: provider.stats!.new24h.toString(),
                                    color: Colors.orange,
                                  )
                                      .animate()
                                      .fadeIn(delay: 500.ms)
                                      .scale(
                                      begin: const Offset(0.8, 0.8)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    icon: Icons.bar_chart,
                                    label: 'Pass Rate',
                                    value: provider.stats!.passRate,
                                    color: AppTheme.accentColor,
                                  )
                                      .animate()
                                      .fadeIn(delay: 600.ms)
                                      .scale(
                                      begin: const Offset(0.8, 0.8)),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Safe Tokens (4/4)',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(fontSize: 20),
                          ),
                          Consumer<TokenProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      AppTheme.accentColor,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 700.ms),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Consumer<TokenProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.tokens.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.accentColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading safe tokens...',
                              style:
                              Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.error != null && provider.tokens.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.redColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.error!,
                              style:
                              Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.loadTokens(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.tokens.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.accentColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No safe tokens found yet',
                              style:
                              Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Press the scan button to search for new tokens',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textColor
                                    .withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final token = provider.tokens[index];
                          return TokenCard(
                            token: token,
                            onTap: () => _showTokenDetail(token),
                          )
                              .animate()
                              .fadeIn(
                              delay: (800 + index * 100).ms)
                              .slideY(begin: 0.2, end: 0);
                        },
                        childCount: provider.tokens.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
