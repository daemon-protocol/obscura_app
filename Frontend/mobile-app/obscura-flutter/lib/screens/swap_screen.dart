import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/chip_selector.dart';

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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Private Swap'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🔐',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Wallet Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connect your wallet to make private swaps',
                  style: AppTextStyles.bodyConst.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Tap the "Connect" button in the header',
                  style: AppTextStyles.labelConst.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Swap'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Private Swap',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Swap tokens with hidden amounts',
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Wallet Info
            _buildWalletInfo(wallet),

            // Token In Card
            const SizedBox(height: AppSpacing.lg),
            _buildSwapCard(
              label: 'You Pay',
              amountController: _amountInController,
              selectedToken: _tokenIn,
              onTokenSelect: (token) => setState(() => _tokenIn = token),
            ),

            // Switch Button
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _switchTokens,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppGradients.purpleToBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Token Out Card
            _buildSwapCard(
              label: 'You Receive (min)',
              amountController: _amountOutController,
              selectedToken: _tokenOut,
              onTokenSelect: (token) => setState(() => _tokenOut = token),
            ),

            // Privacy Level
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Privacy Level',
              style: AppTextStyles.labelConst,
            ),
            const SizedBox(height: AppSpacing.sm),
            ChipSelector<PrivacyLevel>(
              options: PrivacyLevel.values,
              selectedOption: _selectedPrivacy,
              onSelect: (value) => setState(() => _selectedPrivacy = value),
              labelBuilder: (level) => '${level.emoji} ${level.displayName}',
            ),

            // Submit Button
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.blueToLightBlue,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: ElevatedButton(
                  onPressed: api.swapLoading ? null : _handleSwap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
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
                      : const Text('🔄 Execute Private Swap'),
                ),
              ),
            ),

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
    );
  }

  Widget _buildWalletInfo(WalletProvider wallet) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.brandPrimary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.statusSuccess,
              shape: BoxShape.circle,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelConst,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
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
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    child: Text(
                      token,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 14,
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

  Widget _buildResultCard(IntentResponse intent) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0x1010B981), // rgba(16, 185, 129, 0.1)
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: const Color(0x3010B981), // rgba(16, 185, 129, 0.3)
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✅', style: TextStyle(fontSize: 16)),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Swap Created',
                style: TextStyle(
                  color: AppColors.statusSuccess,
                  fontSize: 16,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0x10EF4444), // rgba(239, 68, 68, 0.1)
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: const Color(0x30EF4444), // rgba(239, 68, 68, 0.3)
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text('❌', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: AppColors.statusError,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
