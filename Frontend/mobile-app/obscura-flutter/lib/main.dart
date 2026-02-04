import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/env.dart';
import 'models/magic_block_models.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/swap_screen.dart';
import 'providers/wallet_provider.dart';
import 'providers/api_provider.dart';
import 'providers/magic_block_provider.dart';
import 'providers/rpc_provider.dart';
import 'services/helius_service.dart';
import 'services/magic_block_service.dart';
import 'services/light_protocol_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Services
  await _initializeServices();

  runApp(const ObscuraApp());
}

/// Initialize all services
Future<void> _initializeServices() async {
  // Initialize Helius Service with network awareness
  HeliusService.init(
    Env.heliusApiKey,
    isDevnet: Env.isDevnet,
  );

  // Initialize MagicBlock Service with devnet/mainnet config
  final magicBlockConfig = Env.isDevnet
      ? MagicBlockConfig.devnet(
          programId: Env.obscuraProgramId,
          vrfProgramId: Env.vrfProgramId,
        )
      : MagicBlockConfig.mainnet(
          programId: Env.obscuraProgramId,
          vrfProgramId: Env.vrfProgramId,
        );

  MagicBlockService.init(magicBlockConfig);

  // Initialize Light Protocol Service for ZK Compression
  // Uses Helius RPC with compression API support
  if (Env.enableCompression) {
    LightProtocolService.init(Env.heliusCompressionRpcUrl);
  }
}

class ObscuraApp extends StatelessWidget {
  const ObscuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Providers
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),

        // MagicBlock Provider
        ChangeNotifierProvider(
          create: (_) => MagicBlockProvider()..init(
            initialNetwork: Env.isDevnet ? MagicBlockNetwork.devnet : MagicBlockNetwork.mainnet,
            programId: Env.obscuraProgramId,
          ),
        ),

        // RPC Provider (initialized after MagicBlock)
        ChangeNotifierProxy2<MagicBlockProvider, WalletProvider, RpcProvider>(
          create: (context) {
            final magicBlock = MagicBlockService.instance;
            final helius = HeliusService.instance;

            // Initialize RpcProvider with all services
            RpcProvider.init(
              helius: helius,
              magicBlock: magicBlock,
            );

            return RpcProvider.instance;
          },
          update: (_, magicBlockProvider, walletProvider, rpcProvider) {
            // RPC provider doesn't need updates, it uses singleton services
            return rpcProvider ?? RpcProvider.instance;
          },
        ),
      ],
      child: MaterialApp(
        title: Env.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        routes: {
          '/transfer': (context) => const TransferScreen(),
          '/swap': (context) => const SwapScreen(),
        },
      ),
    );
  }
}
