import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';

class WalletModal extends StatefulWidget {
  const WalletModal({super.key});

  @override
  State<WalletModal> createState() => _WalletModalState();
}

class _WalletModalState extends State<WalletModal> {
  bool _connecting = false;
  String? _connectingWalletId;
  String? _error;

  final List<WalletOption> _solanaWallets = const [
    WalletOption(
      id: 'phantom',
      name: 'Phantom',
      chain: ChainType.solana,
      icon: '👻',
      deepLink: 'phantom://',
      installUrl: 'https://phantom.app/download',
    ),
    WalletOption(
      id: 'solflare',
      name: 'Solflare',
      chain: ChainType.solana,
      icon: '🔥',
      deepLink: 'solflare://',
      installUrl: 'https://solflare.com/download',
    ),
    WalletOption(
      id: 'backpack',
      name: 'Backpack',
      chain: ChainType.solana,
      icon: '🎒',
      deepLink: 'backpack://',
      installUrl: 'https://backpack.app/download',
    ),
  ];

  final List<WalletOption> _evmWallets = const [
    WalletOption(
      id: 'metamask',
      name: 'MetaMask',
      chain: ChainType.ethereum,
      icon: '🦊',
      deepLink: 'metamask://',
      installUrl: 'https://metamask.io/download',
    ),
    WalletOption(
      id: 'rainbow',
      name: 'Rainbow',
      chain: ChainType.ethereum,
      icon: '🌈',
      deepLink: 'rainbow://',
      installUrl: 'https://rainbow.me',
    ),
    WalletOption(
      id: 'trust',
      name: 'Trust Wallet',
      chain: ChainType.ethereum,
      icon: '🛡️',
      deepLink: 'trust://',
      installUrl: 'https://trustwallet.com/download',
    ),
  ];

  Future<void> _handleConnect(WalletOption option) async {
    setState(() {
      _connecting = true;
      _connectingWalletId = option.id;
      _error = null;
    });

    try {
      final wallet = context.read<WalletProvider>();

      // Check if wallet is installed (for mobile)
      // In a real implementation, check deep link availability
      final canOpen = await _canOpenUrl(option.deepLink);

      if (!canOpen) {
        setState(() {
          _error = '${option.name} not installed. Please install it first.';
          _connecting = false;
          _connectingWalletId = null;
        });

        _showInstallDialog(option);
        return;
      }

      await wallet.connect(option.chain);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _connecting = false;
        _connectingWalletId = null;
      });
    }
  }

  Future<bool> _canOpenUrl(String? url) async {
    if (url == null) return false;
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      return true; // Assume can open for demo
    }
  }

  Future<void> _showInstallDialog(WalletOption option) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        title: const Text(
          'Wallet Not Found',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${option.name} is not installed. Would you like to install it?',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In real implementation, launch app store
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _handleDisconnect() {
    context.read<WalletProvider>().disconnect();
    Navigator.of(context).pop();
  }

  void _handleRefreshBalance() {
    context.read<WalletProvider>().refreshBalance();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(wallet.connected),
                const SizedBox(height: AppSpacing.lg),

                if (_error != null) ...[
                  _buildErrorBanner(_error!),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (wallet.connected) ...[
                  _buildConnectedInfo(wallet),
                ] else ...[
                  _buildWalletList(),
                ],

                const SizedBox(height: AppSpacing.lg),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool connected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          connected ? 'Wallet Connected' : 'Connect Wallet',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: const Text(
              '✕',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0x10EF4444),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: const Color(0x30EF4444),
          width: 1,
        ),
      ),
      child: Text(
        error,
        style: const TextStyle(
          color: AppColors.statusError,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildConnectedInfo(WalletProvider wallet) {
    return Column(
      children: [
        // Chain badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandPrimary,
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Text(
            wallet.chain.displayName.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Balance
        Text(
          wallet.balance ?? '0.00',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Full address
        Text(
          wallet.address ?? '',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontFamily: 'Courier',
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleRefreshBalance,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.borderDefault,
                    width: 1,
                  ),
                ),
                child: const Text('🔄 Refresh'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x10EF4444),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(
                    color: const Color(0x30EF4444),
                    width: 1,
                  ),
                ),
                child: TextButton(
                  onPressed: _handleDisconnect,
                  child: const Text(
                    'Disconnect',
                    style: TextStyle(color: AppColors.statusError),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Solana Wallets', 'Connect with Mobile Wallet Adapter'),
        const SizedBox(height: AppSpacing.md),
        ..._solanaWallets.map((wallet) => _buildWalletOption(wallet)),

        const SizedBox(height: AppSpacing.lg),

        _buildSectionLabel('EVM Wallets', 'Ethereum, Polygon, Arbitrum'),
        const SizedBox(height: AppSpacing.md),
        ..._evmWallets.map((wallet) => _buildWalletOption(wallet)),
      ],
    );
  }

  Widget _buildSectionLabel(String title, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletOption(WalletOption option) {
    final isConnecting = _connectingWalletId == option.id;

    return GestureDetector(
      onTap: _connecting ? null : () => _handleConnect(option),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isConnecting ? AppColors.brandPrimary : AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              option.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    option.chain == ChainType.solana ? 'Solana' : 'EVM',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Use spread operator for if-else pattern in children list
            ...[
              if (isConnecting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                  ),
                )
              else
                const Text(
                  '→',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Text('🔐'),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Your keys stay in your wallet. We never have access to your funds.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletOption {
  final String id;
  final String name;
  final ChainType chain;
  final String icon;
  final String? deepLink;
  final String? installUrl;

  const WalletOption({
    required this.id,
    required this.name,
    required this.chain,
    required this.icon,
    this.deepLink,
    this.installUrl,
  });
}
