import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/chip_selector.dart';
import '../widgets/glass_card.dart';
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
        if (!mounted) return;
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

      if (!mounted) return;
      UiHelper.hideSnackBar(context);

      if (result != null && mounted) {
        UiHelper.showSuccess(
            context, 'Transfer created: ${result.intentId.substring(0, 8)}...');
        _recipientController.clear();
        _amountController.clear();
      }
    } catch (e) {
      if (!mounted) return;
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wallet Info
                          _buildWalletInfo(wallet),
                          const SizedBox(height: AppSpacing.lg),

                          // Recipient
                          GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recipient Address',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  controller: _recipientController,
                                  style: AppTextStyles.bodyConst.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0x... or wallet address',
                                    hintStyle: AppTextStyles.bodyConst.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    filled: false,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.sm),
                                      borderSide: BorderSide(
                                          color: AppColors.border.glass),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.sm),
                                      borderSide: BorderSide(
                                          color: AppColors.border.glass),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: AppColors.brandPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount & Asset
                          const SizedBox(height: AppSpacing.md),
                          GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _amountController,
                                        style:
                                            AppTextStyles.h2Const.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0.0',
                                          hintStyle: AppTextStyles.h2Const
                                              .copyWith(
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.glassPurple,
                                        borderRadius: BorderRadius.circular(
                                            AppBorderRadius.full),
                                        border: Border.all(
                                          color: AppColors.brandPrimary
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: 50,
                                        child: TextField(
                                          controller: _assetController,
                                          style:
                                              AppTextStyles.label.copyWith(
                                            color: AppColors.brandPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
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
                              ],
                            ),
                          ),

                          // Chain Selection
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Chain',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ChipSelector<ChainType>(
                            options: ChainType.values,
                            selectedOption: _selectedChain,
                            onSelect: (value) =>
                                setState(() => _selectedChain = value),
                            labelBuilder: (chain) => chain.displayName,
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
            top: -80,
            left: -60,
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
            bottom: 80,
            right: -80,
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
                  gradient: AppGradients.purpleToBlue,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private Transfer',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Send Tokens Privately',
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
                    Icons.send_rounded,
                    size: 48,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Private Transfer',
                  style: AppTextStyles.h2Const.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connect your wallet to make private transfers',
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

  Widget _buildSubmitButton(ApiProvider api) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.purpleToBlue,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPrimary.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: api.transferLoading ? null : _handleTransfer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Send Private Transfer',
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
