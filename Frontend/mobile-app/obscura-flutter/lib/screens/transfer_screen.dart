import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/chip_selector.dart';
import '../widgets/ui_helper.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _assetController = TextEditingController(text: 'SOL');

  ChainType _selectedChain = ChainType.solana;
  PrivacyLevel _selectedPrivacy = PrivacyLevel.shielded;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _assetController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    final wallet = context.read<WalletProvider>();
    final api = context.read<ApiProvider>();

    if (!wallet.connected) {
      UiHelper.showError(context, 'Please connect your wallet first');
      return;
    }

    if (_recipientController.text.isEmpty || _amountController.text.isEmpty) {
      UiHelper.showError(context, 'Please fill all fields');
      return;
    }

    try {
      UiHelper.showLoading(context, 'Processing transfer...');

      final signature = await wallet.signTransaction({
        'type': 'transfer',
        'recipient': _recipientController.text,
        'amount': _amountController.text,
        'asset': _assetController.text,
        'chain': _selectedChain.name,
        'privacyLevel': _selectedPrivacy.name,
      });

      if (signature == null) {
        UiHelper.hideSnackBar(context);
        UiHelper.showError(context, 'Transaction signing failed');
        return;
      }

      final result = await api.transfer(TransferRequest(
        recipient: _recipientController.text,
        asset: _assetController.text,
        amount: _amountController.text,
        sourceChain: _selectedChain,
        privacyLevel: _selectedPrivacy,
      ));

      UiHelper.hideSnackBar(context);

      if (result != null && mounted) {
        UiHelper.showSuccess(context, 'Transfer created: ${result.intentId.substring(0, 8)}...');
        _recipientController.clear();
        _amountController.clear();
      }
    } catch (e) {
      UiHelper.hideSnackBar(context);
      if (mounted) {
        UiHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final api = context.watch<ApiProvider>();

    // Show connect prompt if not connected
    if (!wallet.connected) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Private Transfer'),
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
                  'Connect your wallet to make private transfers',
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
        title: const Text('Private Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Private Transfer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Send tokens with hidden amounts',
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Wallet Info
            _buildWalletInfo(wallet),

            // Recipient
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Recipient Address',
              style: AppTextStyles.labelConst,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _recipientController,
              style: AppTextStyles.bodyConst,
              decoration: const InputDecoration(
                hintText: '0x... or wallet address',
              ),
            ),

            // Amount & Asset
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Amount',
              style: AppTextStyles.labelConst,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    style: AppTextStyles.bodyConst,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.0',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _assetController,
                    style: AppTextStyles.bodyConst,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'ETH',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Available: ${wallet.balance ?? "0.00"}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),

            // Chain Selection
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Chain',
              style: AppTextStyles.labelConst,
            ),
            const SizedBox(height: AppSpacing.sm),
            ChipSelector<ChainType>(
              options: ChainType.values,
              selectedOption: _selectedChain,
              onSelect: (value) => setState(() => _selectedChain = value),
              labelBuilder: (chain) => chain.displayName,
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
                  gradient: AppGradients.purpleToBlue,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: ElevatedButton(
                  onPressed: api.transferLoading ? null : _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child: api.transferLoading
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
                      : const Text('🔒 Send Private Transfer'),
                ),
              ),
            ),
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
            'From: ${wallet.formatWalletAddress}',
            style: AppTextStyles.bodyConst.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}
