import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/chip_selector.dart';
import '../widgets/glass_card.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _amountInController = TextEditingController();
  final _amountOutController = TextEditingController();

  String _tokenIn = 'ETH';
  String _tokenOut = 'USDC';
  PrivacyLevel _selectedPrivacy = PrivacyLevel.shielded;

  static const List<String> _tokens = ['ETH', 'USDC', 'USDT', 'SOL', 'WBTC'];

  @override
  void dispose() {
    _amountInController.dispose();
    _amountOutController.dispose();
    super.dispose();
  }

  void _switchTokens() {
    setState(() {
      final temp = _tokenIn;
      _tokenIn = _tokenOut;
      _tokenOut = temp;
    });
  }

  Future<void> _handleSwap() async {
    final wallet = context.read<WalletProvider>();
    final api = context.read<ApiProvider>();

    if (!wallet.connected) {
      _showErrorDialog('Wallet Required', 'Please connect your wallet first');
      return;
    }

    if (_amountInController.text.isEmpty || _amountOutController.text.isEmpty) {
      _showErrorDialog('Error', 'Please fill all fields');
      return;
    }

    try {
      // Sign the transaction
      final signature = await wallet.signTransaction({
        'type': 'swap',
        'tokenIn': _tokenIn,
        'tokenOut': _tokenOut,
        'amountIn': _amountInController.text,
        'minAmountOut': _amountOutController.text,
        'privacyLevel': _selectedPrivacy.name,
      });

      if (signature == null) {
        _showErrorDialog('Error', 'Transaction signing failed');
        return;
      }

      // Create swap
      final result = await api.swap(SwapRequest(
        tokenIn: _tokenIn,
        tokenOut: _tokenOut,
        amountIn: _amountInController.text,
        minAmountOut: _amountOutController.text,
        privacyLevel: _selectedPrivacy,
      ));

      if (result != null && mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', e.toString());
      }
    }
  }

  void _showSuccessDialog(IntentResponse intent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        title: const Text(
          'Swap Created',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your swap is being processed privately.',
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Intent ID: ${intent.intentId}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyConst.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final api = context.watch<ApiProvider>();

    // Show connect prompt if not connected
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
            // Atmospheric glow effects
            _buildBackground(),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildGlassHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wallet Info
                          _buildWalletInfo(wallet),
                          const SizedBox(height: AppSpacing.lg),

                          // Token In Card
                          _buildSwapCard(
                            label: 'You Pay',
                            amountController: _amountInController,
                            selectedToken: _tokenIn,
                            onTokenSelect: (token) =>
                                setState(() => _tokenIn = token),
                          ),

                          // Switch Button
                          const SizedBox(height: AppSpacing.sm),
                          _buildSwitchButton(),
                          const SizedBox(height: AppSpacing.sm),

                          // Token Out Card
                          _buildSwapCard(
                            label: 'You Receive (min)',
                            amountController: _amountOutController,
                            selectedToken: _tokenOut,
                            onTokenSelect: (token) =>
                                setState(() => _tokenOut = token),
                          ),

                          // Privacy Level
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Privacy Level',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ChipSelector<PrivacyLevel>(
                            options: PrivacyLevel.values,
                            selectedOption: _selectedPrivacy,
                            onSelect: (value) =>
                                setState(() => _selectedPrivacy = value),
                            labelBuilder: (level) =>
                                '${level.emoji} ${level.displayName}',
                          ),

                          // Submit Button
                          const SizedBox(height: AppSpacing.xl),
                          _buildSubmitButton(api),

                          // Result
                          if (api.swapIntent != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildResultCard(api.swapIntent!),
                          ],

                          // Error
                          if (api.swapError != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildErrorCard(api.swapError!),
                          ],
                        ],
                      ),
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
            top: -50,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
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
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
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
                  gradient: AppGradients.blueToLightBlue,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private Swap',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Hidden Amounts • Zero-Knowledge',
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
                    Icons.swap_horiz_rounded,
                    size: 48,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Private Swap',
                  style: AppTextStyles.h2Const.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connect your wallet to make private swaps',
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

  Widget _buildWalletInfo(WalletProvider wallet) {
    return GlassCardCompact(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.statusSuccess,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.statusSuccess.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${wallet.formatWalletAddress} • ${wallet.balance ?? "0.00"}',
            style: AppTextStyles.bodyConst.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapCard({
    required String label,
    required TextEditingController amountController,
    required String selectedToken,
    required void Function(String) onTokenSelect,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  style: AppTextStyles.h2Const.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.0',
                    hintStyle: AppTextStyles.h2Const.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tokens.map((token) {
                final isSelected = token == selectedToken;
                return GestureDetector(
                  onTap: () => onTokenSelect(token),
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppGradients.purpleToBlue
                          : AppGradients.glassGradient,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandPrimary
                            : AppColors.border.glass,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      token,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _switchTokens,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppGradients.purpleToBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPrimary.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
            border: Border.all(
              color: AppColors.border.glass,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.swap_vert,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ApiProvider api) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.blueToLightBlue,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: api.swapLoading ? null : _handleSwap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          ),
          child: api.swapLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Execute Private Swap',
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

  Widget _buildResultCard(IntentResponse intent) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: AppColors.statusSuccess.withValues(alpha: 0.3),
      gradient: LinearGradient(
        colors: [
          AppColors.statusSuccess.withValues(alpha: 0.1),
          AppColors.statusSuccess.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.statusSuccess,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Swap Created',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.statusSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Intent ID: ${intent.intentId}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Commitment: ${intent.commitment.substring(0, 20)}...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: AppColors.statusError.withValues(alpha: 0.3),
      gradient: LinearGradient(
        colors: [
          AppColors.statusError.withValues(alpha: 0.1),
          AppColors.statusError.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: AppColors.statusError,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.statusError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
