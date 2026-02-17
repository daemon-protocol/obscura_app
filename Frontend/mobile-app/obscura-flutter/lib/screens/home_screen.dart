import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../utils/asset_mapper.dart';
import '../widgets/wallet_button.dart';
import '../widgets/action_card.dart';
import '../widgets/privacy_level_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_glow.dart';

/// Home Screen - Neo-Noir Edition
///
/// Redesigned with glass top bar, serif headline, glass balance card,
/// action grid with proper icons, and partner logo images.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiProvider>().checkHealth();
      context.read<WalletProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Atmospheric background with subtle glows
          _buildBackground(),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildWalletCard(context),
                      const SizedBox(height: AppSpacing.lg),
                      _buildNetworkStatusCard(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActions(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPrivacySection(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPartnerLogos(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Base background
          Container(color: AppColors.background.primary),
          // Subtle glow at top right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
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
          // Subtle glow at bottom left
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.shadowGlow,
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

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _buildLogo(),
        ),
        const SizedBox(width: AppSpacing.sm),
        const WalletButton(),
      ],
    );
  }

  Widget _buildLogo() {
    return GlassCardCompact(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.noirPrimary,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.logoWhite,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'O',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          // OBSCURA text - hidden on very small screens
          if (MediaQuery.of(context).size.width > 320)
            const Text(
              'OBSCURA',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSCURA',
          style: AppTextStyles.h1.copyWith(
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Private Transactions',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (!wallet.connected || wallet.address == null) {
      return const SizedBox.shrink();
    }

    return GlassCardBrand(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const StatusGlow(
                      isActive: true,
                      type: StatusGlowType.success,
                      size: 8,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        wallet.chain.displayName,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.brandAccent,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                wallet.balance ?? '0.00 SOL',
                style: AppTextStyles.amount.copyWith(
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.card,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    border: Border.all(
                      color: AppColors.border.subtle,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    wallet.formatWalletAddress,
                    style: AppTextStyles.monospaceSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard(BuildContext context) {
    final api = context.watch<ApiProvider>();

    return GlassCardCompact(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              StatusGlow(
                isActive: api.isHealthy,
                type: api.isHealthy
                    ? StatusGlowType.success
                    : StatusGlowType.error,
                size: 6,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Network Status',
                style: AppTextStyles.label,
              ),
            ],
          ),
          if (api.healthLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.brandPrimary,
                ),
              ),
            )
          else if (api.isHealthy)
            Text(
              'Connected',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.statusSuccess,
              ),
            )
          else
            Text(
              'Offline',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.statusError,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.subtitleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                icon: ActionIcons.transfer,
                title: 'Transfer',
                description: 'Private transfers',
                gradient: AppGradients.noirPrimary,
                onTap: () => Navigator.pushNamed(context, '/transfer'),
                locked: !wallet.connected,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ActionCard(
                icon: ActionIcons.swap,
                title: 'Swap',
                description: 'Private swaps',
                gradient: AppGradients.purpleToBlue,
                onTap: () => Navigator.pushNamed(context, '/swap'),
                locked: !wallet.connected,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                icon: ActionIcons.darkPool,
                title: 'Dark Pool',
                description: 'Private trading',
                gradient: AppGradients.darkPool,
                onTap: () => Navigator.pushNamed(context, '/dark-pool'),
                locked: !wallet.connected,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ActionCard(
                icon: ActionIcons.darkOtc,
                title: 'Dark OTC',
                description: 'RFQ trading',
                gradient: AppGradients.darkOtc,
                onTap: () => Navigator.pushNamed(context, '/dark-otc'),
                locked: !wallet.connected,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Levels',
          style: AppTextStyles.subtitleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: PrivacyLevelCard(
                  icon: '🛡️',
                  name: 'Shielded',
                  description: 'Maximum privacy',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: PrivacyLevelCard(
                  icon: '📋',
                  name: 'Compliant',
                  description: 'With viewing keys',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: PrivacyLevelCard(
                  icon: '🔓',
                  name: 'Transparent',
                  description: 'Debug mode',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerLogos() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.border.subtle,
                AppColors.border.subtle,
                Colors.transparent,
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'POWERED BY',
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: [
            _buildPartnerLogo(AppAssets.partnerDaemon, 'Daemon Protocol'),
            _buildPartnerLogo(AppAssets.partnerArcium, 'Arcium'),
            _buildPartnerLogo(AppAssets.partnerHelius, 'Helius'),
            _buildPartnerLogo(AppAssets.partnerLightProtocol, 'Light Protocol'),
          ],
        ),
      ],
    );
  }

  Widget _buildPartnerLogo(String assetPath, String name) {
    return GlassCardCompact(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Image.asset(
            assetPath,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
