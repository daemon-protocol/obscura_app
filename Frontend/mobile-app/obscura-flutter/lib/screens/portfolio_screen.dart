import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../services/helius_service.dart';
import '../services/light_protocol_service.dart';
import '../theme/theme.dart';
import '../widgets/ui_helper.dart';
import '../widgets/glass_card.dart';

/// Portfolio Screen - Neo-Noir Edition
///
/// Premium portfolio overview with glassmorphism,
/// elegant balance display, and compression ratio visualization.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  double _standardBalance = 0.0;
  double _compressedBalance = 0.0;
  bool _loading = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: AppAnimations.pulse,
      vsync: this,
    )..repeat(reverse: true);
    _fetchBalances();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _fetchBalances() async {
    final wallet = context.read<WalletProvider>();
    if (!wallet.connected || wallet.address == null) return;

    setState(() => _loading = true);

    try {
      // Fetch standard balance
      if (HeliusService.isInitialized) {
        _standardBalance =
            await HeliusService.instance.getBalance(wallet.address!);
      }

      // Fetch compressed balance
      if (LightProtocolService.isInitialized &&
          wallet.state.solanaPublicKey != null) {
        final compressedLamports = await LightProtocolService.instance
            .getTotalBalance(wallet.state.solanaPublicKey!);
        _compressedBalance = compressedLamports.toDouble() / 1e9;
      }
    } catch (e) {
      if (mounted) {
        UiHelper.showError(context, 'Failed to fetch balances: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleCompress() async {
    final wallet = context.read<WalletProvider>();
    if (!wallet.connected || wallet.state.solanaPublicKey == null) return;

    if (_standardBalance <= 0.1) {
      UiHelper.showError(context, 'Insufficient balance to compress');
      return;
    }

    UiHelper.showLoading(context, 'Compressing SOL...');

    try {
      if (LightProtocolService.isInitialized) {
        // Note: In production, you need the actual keypair to sign transactions
        // For now, this is a placeholder showing the intended flow
        UiHelper.hideSnackBar(context);
        UiHelper.showError(
            context, 'KeyPair required for compression (not implemented)');
      }
    } catch (e) {
      UiHelper.hideSnackBar(context);
      UiHelper.showError(context, 'Compression failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (!wallet.connected) {
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
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Portfolio',
                    style: AppTextStyles.h2Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Connect your wallet to view your portfolio',
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

    final totalBalance = _standardBalance + _compressedBalance;
    final compressionRatio = totalBalance > 0
        ? (_compressedBalance / totalBalance * 100)
        : 0.0;

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
          child: Column(
            children: [
              // Glass Header
              _buildGlassHeader(),
              // Content
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchBalances,
                        backgroundColor: AppColors.backgroundSecondary,
                        color: AppColors.brandPrimary,
                        child: ListView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          children: [
                            // Total Balance Card
                            _buildTotalBalanceCard(totalBalance),
                            const SizedBox(height: AppSpacing.lg),

                            // Compression Ratio Indicator
                            _buildCompressionRatio(compressionRatio),
                            const SizedBox(height: AppSpacing.lg),

                            // Balance Breakdown
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPrimary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text(
                                  'Balance Breakdown',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            _buildBalanceCard(
                              title: 'Standard Balance',
                              amount: _standardBalance,
                              icon: Icons.account_balance_wallet_outlined,
                              color: AppColors.brandPrimary,
                              subtitle: 'Regular Solana tokens',
                            ),

                            _buildBalanceCard(
                              title: 'Compressed Balance',
                              amount: _compressedBalance,
                              icon: Icons.compress_outlined,
                              color: AppColors.statusSuccess,
                              subtitle: '1000x cheaper storage',
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Compress Button
                            _buildCompressButton(),

                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Compressing SOL reduces storage costs by 1000x using ZK Compression',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.noirPrimary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: const Icon(
                      Icons.pie_chart_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Portfolio',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                color: AppColors.brandPrimary,
                onPressed: _fetchBalances,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          glowEnabled: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: AppColors.brandAccent.withValues(
                        alpha: 0.5 + (0.5 * _glowController.value),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Total Balance',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.brandAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${totalBalance.toStringAsFixed(4)} SOL',
                  style: AppTextStyles.h1Const.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandAccent.withValues(alpha: 0.2),
                        AppColors.brandAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    border: Border.all(
                      color: AppColors.brandAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '\$${(totalBalance * 100).toStringAsFixed(2)} USD',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.brandAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompressionRatio(double ratio) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Compression Ratio',
                style: AppTextStyles.labelConst,
              ),
              Text(
                '${ratio.toStringAsFixed(1)}%',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.statusSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: AppGradients.privateCompressed,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Standard',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccess,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Compressed',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount.toStringAsFixed(4)} SOL',
                style: AppTextStyles.bodyConst.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${(amount * 100).toStringAsFixed(2)}',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompressButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.privateCompressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.statusSuccess.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleCompress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.compress_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Compress 50% of SOL',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
