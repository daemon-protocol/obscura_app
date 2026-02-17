import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dark_pool_models.dart';
import '../models/magic_block_models.dart';
import '../providers/dark_pool_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/theme.dart';
import '../widgets/ui_helper.dart';
import '../widgets/glass_card.dart';

/// Dark Pool Screen - Neo-Noir Edition
///
/// Premium dark pool trading interface with glassmorphism,
/// elegant typography, and atmospheric depth.
class DarkPoolScreen extends StatefulWidget {
  const DarkPoolScreen({super.key});

  @override
  State<DarkPoolScreen> createState() => _DarkPoolScreenState();
}

class _DarkPoolScreenState extends State<DarkPoolScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();

  TradingPair _selectedPair = TradingPair.solUsdc;
  OrderSide _selectedSide = OrderSide.buy;
  OrderType _selectedType = OrderType.limit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final darkPool = context.read<DarkPoolProvider>();
      final wallet = context.read<WalletProvider>();

      darkPool.fetchOrderBook(_selectedPair);
      if (wallet.connected && wallet.address != null) {
        darkPool.fetchMyOrders(wallet.address!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    final wallet = context.read<WalletProvider>();
    final darkPool = context.read<DarkPoolProvider>();

    if (!wallet.connected || wallet.address == null) {
      UiHelper.showError(context, 'Please connect your wallet first');
      return;
    }

    if (_amountController.text.isEmpty) {
      UiHelper.showError(context, 'Please enter amount');
      return;
    }

    if (_selectedType == OrderType.limit && _priceController.text.isEmpty) {
      UiHelper.showError(context, 'Please enter price for limit order');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final price =
        _selectedType == OrderType.limit ? double.tryParse(_priceController.text) : null;

    if (amount == null || amount <= 0) {
      UiHelper.showError(context, 'Invalid amount');
      return;
    }

    if (_selectedType == OrderType.limit && (price == null || price <= 0)) {
      UiHelper.showError(context, 'Invalid price');
      return;
    }

    UiHelper.showLoading(context, 'Placing order...');

    final order = await darkPool.placeOrder(
      pair: _selectedPair,
      side: _selectedSide,
      type: _selectedType,
      amount: amount,
      price: price,
      userAddress: wallet.address!,
      usePrivateMode: wallet.executionMode == ExecutionMode.private,
    );

    if (!mounted) return;
    UiHelper.hideSnackBar(context);

    if (order != null && mounted) {
      UiHelper.showSuccess(
        context,
        'Order placed${order.teeVerified ? ' (TEE Verified ✓)' : ''}',
      );
      _amountController.clear();
      _priceController.clear();
      _tabController.animateTo(2); // Switch to My Orders tab
    } else if (darkPool.error != null && mounted) {
      UiHelper.showError(context, darkPool.error!);
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
                      Icons.lock_outlined,
                      size: 48,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Dark Pool Trading',
                    style: AppTextStyles.h2Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Connect your wallet to access private trading',
                    style: AppTextStyles.bodyConst.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
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
                    _buildPlaceOrderTab(),
                    _buildOrderBookTab(),
                    _buildMyOrdersTab(),
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
                  gradient: AppGradients.darkPool,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Pool',
                    style: AppTextStyles.h3Const.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Private Trading',
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
              _buildTab('Place Order', 0),
              _buildTab('Order Book', 1),
              _buildTab('My Orders', 2),
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
            gradient: isSelected
                ? AppGradients.glassPurple
                : null,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.brandPrimary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderTab() {
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
                DropdownButtonFormField<TradingPair>(
                  initialValue: _selectedPair,
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
                    DropdownMenuItem(
                      value: TradingPair.solUsdc,
                      child: Text('SOL / USDC'),
                    ),
                    DropdownMenuItem(
                      value: TradingPair.solUsdt,
                      child: Text('SOL / USDT'),
                    ),
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
                    Expanded(child: _buildSideButton(OrderSide.buy)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _buildSideButton(OrderSide.sell)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Order Type
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Type', style: AppTextStyles.labelConst),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _buildTypeButton(OrderType.market)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _buildTypeButton(OrderType.limit)),
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
                    suffixText: _selectedPair.base,
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

          // Price Input (for limit orders)
          if (_selectedType == OrderType.limit) ...[
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price', style: AppTextStyles.labelConst),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _priceController,
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
                      suffixText: _selectedPair.quote,
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
          ],

          const SizedBox(height: AppSpacing.xl),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: _selectedSide == OrderSide.buy
                    ? AppGradients.darkPool
                    : AppGradients.darkOtc,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: (_selectedSide == OrderSide.buy
                            ? AppColors.statusSuccess
                            : AppColors.statusError)
                        .withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handlePlaceOrder,
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
                    Icon(
                      _selectedSide == OrderSide.buy
                          ? Icons.trending_up_outlined
                          : Icons.trending_down_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_selectedSide.displayName} ${_selectedPair.base}',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildSideButton(OrderSide side) {
    final isSelected = _selectedSide == side;
    final isBuy = side == OrderSide.buy;

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
              isBuy ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined,
              size: 16,
              color: isSelected
                  ? (isBuy ? AppColors.statusSuccess : AppColors.statusError)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              side.displayName,
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

  Widget _buildTypeButton(OrderType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppGradients.glassPurple
              : AppGradients.glassGradient,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border.glass,
          ),
        ),
        child: Text(
          type.displayName,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOrderBookTab() {
    final darkPool = context.watch<DarkPoolProvider>();
    final orderBook = darkPool.orderBook;

    if (orderBook == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => darkPool.fetchOrderBook(_selectedPair),
      backgroundColor: AppColors.backgroundSecondary,
      color: AppColors.brandPrimary,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Spread info
          if (orderBook.spread != null)
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spread', style: AppTextStyles.labelConst),
                  Text(
                    orderBook.spread!.toStringAsFixed(2),
                    style: AppTextStyles.bodyConst.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Asks
          Row(
            children: [
              Container(
                width: 4,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.statusError,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'ASKS',
                style: TextStyle(
                  color: AppColors.statusError,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...orderBook.asks.reversed.map((level) => _buildPriceLevel(level, OrderSide.sell)),

          const SizedBox(height: AppSpacing.lg),

          // Bids
          Row(
            children: [
              Container(
                width: 4,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.statusSuccess,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'BIDS',
                style: TextStyle(
                  color: AppColors.statusSuccess,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...orderBook.bids.map((level) => _buildPriceLevel(level, OrderSide.buy)),
        ],
      ),
    );
  }

  Widget _buildPriceLevel(PriceLevel level, OrderSide side) {
    final isBuy = side == OrderSide.buy;
    final color = isBuy ? AppColors.statusSuccess : AppColors.statusError;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            level.price.toStringAsFixed(2),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            level.amount.toStringAsFixed(2),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${level.orderCount} orders',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersTab() {
    final darkPool = context.watch<DarkPoolProvider>();
    final wallet = context.watch<WalletProvider>();

    if (darkPool.myOrders.isEmpty) {
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
                Icons.list_alt_outlined,
                size: 48,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Orders Yet',
              style: AppTextStyles.h3Const.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Place your first order to get started',
              style: AppTextStyles.bodyConst.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => darkPool.fetchMyOrders(wallet.address!),
      backgroundColor: AppColors.backgroundSecondary,
      color: AppColors.brandPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: darkPool.myOrders.length,
        itemBuilder: (context, index) {
          final order = darkPool.myOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isBuy = order.side == OrderSide.buy;
    final statusColor = _getStatusColor(order.status);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowEnabled: order.teeVerified,
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
                      gradient: LinearGradient(
                        colors: [
                          isBuy
                              ? AppColors.statusSuccess.withValues(alpha: 0.2)
                              : AppColors.statusError.withValues(alpha: 0.2),
                          isBuy
                              ? AppColors.statusSuccess.withValues(alpha: 0.1)
                              : AppColors.statusError.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(
                        color: isBuy ? AppColors.statusSuccess : AppColors.statusError,
                      ),
                    ),
                    child: Text(
                      order.side.displayName,
                      style: AppTextStyles.label.copyWith(
                        color: isBuy ? AppColors.statusSuccess : AppColors.statusError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    order.pair.symbol,
                    style: AppTextStyles.bodyConst.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (order.isPrivate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 12,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  if (order.teeVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.statusSuccess,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      order.status.displayName,
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
          const SizedBox(height: AppSpacing.sm),
          _buildOrderDetailRow('Amount', '${order.amount.toStringAsFixed(4)} ${order.pair.base}'),
          if (order.price != null)
            _buildOrderDetailRow('Price', '${order.price!.toStringAsFixed(2)} ${order.pair.quote}'),
          if (order.filled > 0)
            _buildOrderDetailRow('Filled', '${order.filledPercentage.toStringAsFixed(1)}%'),
          if (order.status == OrderStatus.open) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleCancelOrder(order.id),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.statusError.withValues(alpha: 0.5)),
                  foregroundColor: AppColors.statusError,
                ),
                child: const Text('Cancel Order'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.open:
        return AppColors.brandPrimary;
      case OrderStatus.filled:
        return AppColors.statusSuccess;
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        return AppColors.statusError;
      case OrderStatus.partiallyFilled:
        return AppColors.statusWarning;
    }
  }

  Future<void> _handleCancelOrder(String orderId) async {
    final darkPool = context.read<DarkPoolProvider>();

    UiHelper.showLoading(context, 'Cancelling order...');
    final success = await darkPool.cancelOrder(orderId);
    if (!mounted) return;
    UiHelper.hideSnackBar(context);

    if (success && mounted) {
      UiHelper.showSuccess(context, 'Order cancelled');
    } else if (darkPool.error != null && mounted) {
      UiHelper.showError(context, darkPool.error!);
    }
  }
}
