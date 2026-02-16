import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    if (!wallet.connected) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: Text('Connect wallet to view history')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildTransactionCard(
            type: 'Transfer',
            amount: '1.5 SOL',
            status: 'Completed',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isPrivate: true,
            teeVerified: true,
          ),
          _buildTransactionCard(
            type: 'Dark Pool Order',
            amount: '10 SOL',
            status: 'Filled',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            isPrivate: true,
            teeVerified: true,
          ),
          _buildTransactionCard(
            type: 'OTC RFQ',
            amount: '50 USDC',
            status: 'Accepted',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isPrivate: true,
            teeVerified: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required String type,
    required String amount,
    required String status,
    required DateTime timestamp,
    bool isPrivate = false,
    bool teeVerified = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (isPrivate) const Icon(Icons.shield, size: 16, color: AppColors.brandPrimary),
                  if (teeVerified) const Icon(Icons.verified, size: 16, color: AppColors.statusSuccess),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Text(status, style: const TextStyle(fontSize: 12, color: AppColors.statusSuccess)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(amount, style: AppTextStyles.body),
          Text(
            _formatTimestamp(timestamp),
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
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
