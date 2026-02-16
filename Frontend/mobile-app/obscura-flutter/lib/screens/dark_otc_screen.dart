import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dark_otc_models.dart';
import '../models/magic_block_models.dart';
import '../providers/otc_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/theme.dart';
import '../widgets/ui_helper.dart';
import '../widgets/glass_card.dart';

/// Dark OTC Screen - Neo-Noir Edition
///
/// Premium over-the-counter trading interface with glassmorphism,
/// RFQ management, and private mode support.
class DarkOTCScreen extends StatefulWidget {
  const DarkOTCScreen({super.key});

  @override
  State<DarkOTCScreen> createState() => _DarkOTCScreenState();
}

class _DarkOTCScreenState extends State<DarkOTCScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  String _selectedPair = 'SOL/USDC';
  String _selectedSide = 'buy';
  int _expiryMinutes = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRFQ() async {
    final wallet = context.read<WalletProvider>();
    final otc = context.read<OTCProvider>();

    if (!wallet.connected || wallet.address == null) {
      UiHelper.showError(context, 'Please connect your wallet first');
      return;
    }

    if (_amountController.text.isEmpty) {
      UiHelper.showError(context, 'Please enter amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      UiHelper.showError(context, 'Invalid amount');
      return;
    }

    UiHelper.showLoading(context, 'Creating RFQ...');

    final rfq = await otc.createRFQ(
      pair: _selectedPair,
      amount: amount,
      side: _selectedSide,
      expiryDuration: Duration(minutes: _expiryMinutes),
      requesterAddress: wallet.address!,
      usePrivateMode: wallet.executionMode == ExecutionMode.private,
    );

    UiHelper.hideSnackBar(context);

    if (rfq != null && mounted) {
      UiHelper.showSuccess(context, 'RFQ created successfully');
      _amountController.clear();
      _tabController.animateTo(1);
    } else if (otc.error != null && mounted) {
      UiHelper.showError(context, otc.error!);
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
                      Icons.handshake_outlined,
                      size: 48,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Dark OTC',
                    style: AppTextStyles.h2Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Connect your wallet to access OTC trading',
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
              // Glass Tab Bar
              _buildGlassTabBar(),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCreateRFQTab(),
                    _buildMyRFQsTab(),
                  ],
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.darkOtc,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark OTC',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Over-the-Counter Trading',
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

  Widget _buildGlassTabBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
              _buildTab('Create RFQ', 0),
              _buildTab('My RFQs', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.animateTo(index)),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.glassPurple : null,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateRFQTab() {
    final wallet = context.watch<WalletProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Private Mode Indicator
          if (wallet.executionMode == ExecutionMode.private)
            _buildPrivateModeIndicator(),
          const SizedBox(height: AppSpacing.lg),

          // Trading Pair Card
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trading Pair', style: AppTextStyles.labelConst),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _selectedPair,
                  decoration: InputDecoration(
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  dropdownColor: AppColors.backgroundSecondary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SOL/USDC', child: Text('SOL / USDC')),
                    DropdownMenuItem(value: 'SOL/USDT', child: Text('SOL / USDT')),
                  ],
                  onChanged: (value) => setState(() => _selectedPair = value!),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Side Selection
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Side', style: AppTextStyles.labelConst),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _buildSideButton('buy')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _buildSideButton('sell')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Amount Input
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount', style: AppTextStyles.labelConst),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    suffixText: _selectedPair.split('/')[0],
                    suffixStyle: AppTextStyles.label.copyWith(
                      color: AppColors.brandPrimary,
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Expiry Selection
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RFQ Expiry', style: AppTextStyles.labelConst),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<int>(
                  value: _expiryMinutes,
                  decoration: InputDecoration(
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      borderSide: BorderSide(color: AppColors.border.glass),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  dropdownColor: AppColors.backgroundSecondary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                  ],
                  onChanged: (value) => setState(() => _expiryMinutes = value!),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Create RFQ Button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.darkOtc,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.statusWarning.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleCreateRFQ,
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
                    const Icon(Icons.description_outlined, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Create RFQ',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Text(
            'RFQs are private requests for quotes from market makers',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateModeIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.statusSuccess.withValues(alpha: 0.15),
            AppColors.statusSuccess.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.statusSuccess.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.statusSuccess, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private Mode Active',
                  style: TextStyle(
                    color: AppColors.statusSuccess,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'TEE Protected Execution',
                  style: TextStyle(
                    color: AppColors.statusSuccess,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified, color: AppColors.statusSuccess, size: 16),
        ],
      ),
    );
  }

  Widget _buildSideButton(String side) {
    final isSelected = _selectedSide == side;
    final isBuy = side == 'buy';

    return GestureDetector(
      onTap: () => setState(() => _selectedSide = side),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                        .withValues(alpha: 0.2),
                    (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                        .withValues(alpha: 0.1),
                  ],
                )
              : AppGradients.glassGradient,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isSelected
                ? (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                : AppColors.border.glass,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBuy ? Icons.trending_up_outlined : Icons.trending_down_outlined,
              size: 16,
              color: isSelected
                  ? (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              side.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: isSelected
                    ? (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRFQsTab() {
    final otc = context.watch<OTCProvider>();

    if (otc.myRFQs.isEmpty) {
      return Center(
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
                Icons.description_outlined,
                size: 48,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No RFQs Yet',
              style: AppTextStyles.h3Const.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first RFQ to get started',
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: otc.myRFQs.length,
      itemBuilder: (context, index) {
        final rfq = otc.myRFQs[index];
        return _buildRFQCard(rfq);
      },
    );
  }

  Widget _buildRFQCard(RFQ rfq) {
    final otc = context.watch<OTCProvider>();
    final quotes = otc.getQuotesForRFQ(rfq.id);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowEnabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.darkOtc,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(
                      rfq.pair,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (false) ...[ // rfq.teeVerified
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.statusSuccess,
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(rfq.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(
                    color: _getStatusColor(rfq.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  rfq.status.displayName,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: _getStatusColor(rfq.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: rfq.side == 'buy'
                      ? AppColors.statusSuccess
                      : AppColors.statusError,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${rfq.side.toUpperCase()} ${rfq.amount} ${rfq.pair.split('/')[0]}',
                style: AppTextStyles.bodyConst.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (quotes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
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
              children: [
                Container(
                  width: 4,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Quotes Received',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...quotes.map((quote) => _buildQuoteItem(quote, rfq)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteItem(Quote quote, RFQ rfq) {
    final isBuy = rfq.side == 'buy';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.glassGradient,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: AppColors.border.glass,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.brandAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Price: ${quote.price.toStringAsFixed(2)}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  quote.formattedMaker,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (quote.teeVerified) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 12,
                        color: AppColors.statusSuccess,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TEE Verified',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.statusSuccess,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (quote.status == QuoteStatus.active && rfq.status == RFQStatus.quoted)
            Container(
              decoration: BoxDecoration(
                gradient: isBuy ? AppGradients.darkOtc : AppGradients.darkPool,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: ElevatedButton(
                onPressed: () => _handleAcceptQuote(quote, rfq),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(RFQStatus status) {
    switch (status) {
      case RFQStatus.pending:
        return AppColors.statusWarning;
      case RFQStatus.quoted:
        return AppColors.brandPrimary;
      case RFQStatus.accepted:
        return AppColors.statusSuccess;
      case RFQStatus.expired:
      case RFQStatus.cancelled:
        return AppColors.statusError;
    }
  }

  Future<void> _handleAcceptQuote(Quote quote, RFQ rfq) async {
    final wallet = context.read<WalletProvider>();
    final otc = context.read<OTCProvider>();

    UiHelper.showLoading(context, 'Accepting quote...');

    final success = await otc.acceptQuote(
      quoteId: quote.id,
      rfqId: rfq.id,
      userAddress: wallet.address!,
      usePrivateMode: wallet.executionMode == ExecutionMode.private,
    );

    UiHelper.hideSnackBar(context);

    if (success && mounted) {
      UiHelper.showSuccess(
          context, 'Quote accepted${quote.teeVerified ? ' (TEE Verified ✓)' : ''}');
    } else if (otc.error != null && mounted) {
      UiHelper.showError(context, otc.error!);
    }
  }
}
