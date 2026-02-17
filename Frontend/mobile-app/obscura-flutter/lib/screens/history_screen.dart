import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (!wallet.connected) {
      return _buildWalletConnectPrompt();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0E),
              Color(0xFF050508),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildGlassHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        _buildTransactionCard(
                          type: 'Transfer',
                          icon: Icons.send_rounded,
                          amount: '1.5 SOL',
                          status: 'Completed',
                          statusColor: AppColors.statusSuccess,
                          timestamp: DateTime.now()
                              .subtract(const Duration(hours: 2)),
                          isPrivate: true,
                          teeVerified: true,
                        ),
                        _buildTransactionCard(
                          type: 'Dark Pool Order',
                          icon: Icons.candlestick_chart_outlined,
                          amount: '10 SOL',
                          status: 'Filled',
                          statusColor: AppColors.statusSuccess,
                          timestamp: DateTime.now()
                              .subtract(const Duration(hours: 5)),
                          isPrivate: true,
                          teeVerified: true,
                        ),
                        _buildTransactionCard(
                          type: 'OTC RFQ',
                          icon: Icons.handshake_outlined,
                          amount: '50 USDC',
                          status: 'Accepted',
                          statusColor: AppColors.brandPrimary,
                          timestamp: DateTime.now()
                              .subtract(const Duration(days: 1)),
                          isPrivate: true,
                          teeVerified: true,
                        ),
                        _buildTransactionCard(
                          type: 'Swap',
                          icon: Icons.swap_horiz_rounded,
                          amount: '2.0 ETH → USDC',
                          status: 'Pending',
                          statusColor: AppColors.statusWarning,
                          timestamp: DateTime.now()
                              .subtract(const Duration(days: 2)),
                          isPrivate: true,
                          teeVerified: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandGlow,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.shadow.glow,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.glassGradient,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.glass,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.actionGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction History',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Private Activity Log',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.brandAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletConnectPrompt() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0E),
              Color(0xFF050508),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppGradients.glassPurple,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.border.glass,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Transaction History',
                  style: AppTextStyles.h2Const.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connect wallet to view history',
                  style: AppTextStyles.bodyConst.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String type,
    required IconData icon,
    required String amount,
    required String status,
    required Color statusColor,
    required DateTime timestamp,
    bool isPrivate = false,
    bool teeVerified = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppGradients.actionGradient,
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      type,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isPrivate)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            size: 14, color: AppColors.brandPrimary),
                      ),
                    if (teeVerified)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccess
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: const Icon(Icons.verified_outlined,
                            size: 14, color: AppColors.statusSuccess),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.full),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Glass divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.border.glass,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amount,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
