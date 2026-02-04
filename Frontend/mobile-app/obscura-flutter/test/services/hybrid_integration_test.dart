import 'package:flutter_test/flutter_test.dart';
import 'package:obscura_vault/models/magic_block_models.dart';
import 'package:obscura_vault/services/defi_service.dart';

void main() {
  group('ExecutionMode Integration Tests', () {
    test('test_ExecutionMode_fastCompressed_routing_properties', () {
      final mode = ExecutionMode.fastCompressed;

      expect(mode.usesER, true);
      expect(mode.usesCompression, true);
      expect(mode.isHybrid, true);
      expect(mode.requiresDelegation, true);
      expect(mode.isPrivate, false);
    });

    test('test_ExecutionMode_privateCompressed_routing_properties', () {
      final mode = ExecutionMode.privateCompressed;

      expect(mode.usesER, true);
      expect(mode.usesCompression, true);
      expect(mode.isHybrid, true);
      expect(mode.requiresDelegation, true);
      expect(mode.isPrivate, true);
    });

    test('test_all_execution_modes_have_valid_properties', () {
      for (final mode in ExecutionMode.values) {
        // Verify all modes have valid display names
        expect(mode.displayName.isNotEmpty, true,
            reason: '${mode.name} should have a display name');

        // Verify all modes have valid emojis
        expect(mode.emoji.isNotEmpty, true,
            reason: '${mode.name} should have an emoji');

        // Verify all modes have positive latency
        expect(mode.estimatedLatencyMs > 0, true,
            reason: '${mode.name} should have positive latency');

        // Verify all modes have valid cost multiplier
        expect(mode.costMultiplier >= 0, true,
            reason: '${mode.name} should have non-negative cost multiplier');
      }
    });

    test('test_ExecutionMode_values_are_complete', () {
      final modes = ExecutionMode.values;

      expect(modes.length, 6);
      expect(modes, contains(ExecutionMode.standard));
      expect(modes, contains(ExecutionMode.fast));
      expect(modes, contains(ExecutionMode.private));
      expect(modes, contains(ExecutionMode.compressed));
      expect(modes, contains(ExecutionMode.fastCompressed));
      expect(modes, contains(ExecutionMode.privateCompressed));
    });
  });

  group('DeFiResult Hybrid Flag Tests', () {
    test('test_DeFiResult_hybrid_flags_default_values', () {
      final result = DeFiResult(
        signature: 'test_signature',
        usedER: false,
        latency: 100,
      );

      expect(result.isHybrid, false);
      expect(result.isCompressed, false);
      expect(result.isPrivate, false);
    });

    test('test_DeFiResult_hybrid_flags_set_to_true', () {
      final result = DeFiResult(
        signature: 'test_signature',
        usedER: true,
        latency: 100,
        isCompressed: true,
        isHybrid: true,
      );

      expect(result.usedER, true);
      expect(result.isCompressed, true);
      expect(result.isHybrid, true);
    });

    test('test_DeFiResult_full_hybrid_flags', () {
      final result = DeFiResult(
        signature: 'test_signature',
        usedER: true,
        latency: 100,
        isCompressed: true,
        isPrivate: true,
        isHybrid: true,
      );

      expect(result.usedER, true);
      expect(result.isCompressed, true);
      expect(result.isPrivate, true);
      expect(result.isHybrid, true);
    });

    test('test_DeFiResult_isSuccess', () {
      final success = DeFiResult(
        signature: 'valid_signature',
        usedER: true,
        latency: 50,
      );

      final failure = DeFiResult(
        signature: '',
        usedER: false,
        latency: 100,
        error: 'Transaction failed',
      );

      expect(success.isSuccess, true);
      expect(failure.isSuccess, false);
    });

    test('test_DeFiResult_modeDescription_hybrid', () {
      final hybridCompressed = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 60,
        isCompressed: true,
        isHybrid: true,
      );

      expect(hybridCompressed.modeDescription, 'Fast + Compressed');
    });

    test('test_DeFiResult_modeDescription_private_hybrid', () {
      final privateHybrid = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 85,
        isCompressed: true,
        isPrivate: true,
        isHybrid: true,
      );

      expect(privateHybrid.modeDescription, 'Private + Compressed');
    });

    test('test_DeFiResult_modeEmoji_fastCompressed', () {
      final result = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 60,
        isCompressed: true,
        isHybrid: true,
      );

      expect(result.modeEmoji, '⚡🗜️');
    });

    test('test_DeFiResult_modeEmoji_privateCompressed', () {
      final result = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 85,
        isCompressed: true,
        isPrivate: true,
        isHybrid: true,
      );

      expect(result.modeEmoji, '🔒🗜️');
    });

    test('test_DeFiResult_latencyString', () {
      final fast = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 50,
      );

      final medium = DeFiResult(
        signature: 'sig',
        usedER: false,
        latency: 300,
      );

      final slow = DeFiResult(
        signature: 'sig',
        usedER: false,
        latency: 1200,
      );

      expect(fast.latencyString, '50ms ⚡');
      expect(medium.latencyString, '300ms');
      expect(slow.latencyString, '1.2s');
    });

    test('test_DeFiResult_isHybridMode', () {
      final hybrid = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 60,
        isCompressed: true,
        isHybrid: true,
      );

      final nonHybrid = DeFiResult(
        signature: 'sig',
        usedER: true,
        latency: 50,
      );

      expect(hybrid.isHybridMode, true);
      expect(nonHybrid.isHybridMode, false);
    });
  });

  group('Cost Comparison Tests', () {
    test('test_hybrid_modes_are_cheaper', () {
      final standardCost = ExecutionMode.standard.costMultiplier;
      final fastCompressedCost = ExecutionMode.fastCompressed.costMultiplier;
      final privateCompressedCost = ExecutionMode.privateCompressed.costMultiplier;

      expect(fastCompressedCost, lessThan(standardCost));
      expect(privateCompressedCost, lessThan(standardCost));
      expect(fastCompressedCost, closeTo(0.001, 0.0001));
      expect(privateCompressedCost, closeTo(0.0012, 0.0001));
    });

    test('test_compression_dominates_cost', () {
      // Compression should dramatically reduce cost regardless of other features
      final standardCost = ExecutionMode.standard.costMultiplier;
      final compressedCost = ExecutionMode.compressed.costMultiplier;
      final fastCompressedCost = ExecutionMode.fastCompressed.costMultiplier;
      final privateCompressedCost = ExecutionMode.privateCompressed.costMultiplier;

      expect(compressedCost, lessThan(standardCost * 0.01)); // At least 100x cheaper
      expect(fastCompressedCost, lessThan(standardCost * 0.01));
      expect(privateCompressedCost, lessThan(standardCost * 0.01));
    });
  });

  group('Latency Comparison Tests', () {
    test('test_hybrid_latencies_are_reasonable', () {
      final fastLatency = ExecutionMode.fast.estimatedLatencyMs;
      final compressedLatency = ExecutionMode.compressed.estimatedLatencyMs;
      final fastCompressedLatency = ExecutionMode.fastCompressed.estimatedLatencyMs;

      // Hybrid should be close to fast (slight overhead for compression)
      expect(fastCompressedLatency, greaterThan(fastLatency));
      expect(fastCompressedLatency, lessThan(compressedLatency));

      // Fast compressed should be around 60ms (as documented)
      expect(fastCompressedLatency, 60);
    });

    test('test_privateCompressed_latency', () {
      final privateLatency = ExecutionMode.private.estimatedLatencyMs;
      final privateCompressedLatency = ExecutionMode.privateCompressed.estimatedLatencyMs;

      // Private compressed should be slightly slower than pure private
      expect(privateCompressedLatency, greaterThan(privateLatency));

      // Should be around 85ms (as documented)
      expect(privateCompressedLatency, 85);
    });
  });

  group('Mode Enumeration Tests', () {
    test('test_all_execution_modes_are_accessible', () {
      final modes = ExecutionMode.values;

      expect(modes.length, 6);
      expect(modes, contains(ExecutionMode.standard));
      expect(modes, contains(ExecutionMode.fast));
      expect(modes, contains(ExecutionMode.private));
      expect(modes, contains(ExecutionMode.compressed));
      expect(modes, contains(ExecutionMode.fastCompressed));
      expect(modes, contains(ExecutionMode.privateCompressed));
    });

    test('test_hybrid_modes_are_last', () {
      final modes = ExecutionMode.values;

      // Hybrid modes should be the last two in the enum
      expect(modes[modes.length - 2], ExecutionMode.fastCompressed);
      expect(modes[modes.length - 1], ExecutionMode.privateCompressed);
    });

    test('test_only_two_hybrid_modes_exist', () {
      int hybridCount = 0;

      for (final mode in ExecutionMode.values) {
        if (mode.isHybrid) {
          hybridCount++;
        }
      }

      expect(hybridCount, 2);
    });
  });

  group('DelegationStatus Tests', () {
    test('test_DelegationStatus_notDelegated_factory', () {
      final status = DelegationStatus.notDelegated('test_address');
      expect(status.account, 'test_address');
      expect(status.state, DelegationState.notDelegated);
      expect(status.validator, null);
    });

    test('test_DelegationStatus_equality', () {
      final status1 = DelegationStatus(
        account: 'test_address',
        state: DelegationState.delegated,
      );
      final status2 = DelegationStatus(
        account: 'test_address',
        state: DelegationState.delegated,
      );
      final status3 = DelegationStatus(
        account: 'other_address',
        state: DelegationState.delegated,
      );

      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('test_DelegationStatus_toJson_fromJson', () {
      final original = DelegationStatus(
        account: 'test_address',
        state: DelegationState.delegated,
        validator: 'validator_pubkey',
        validatorRegion: 'us',
        estimatedLatency: 50,
      );

      final json = original.toJson();
      final restored = DelegationStatus.fromJson(json);

      expect(restored.account, original.account);
      expect(restored.state, original.state);
      expect(restored.validator, original.validator);
      expect(restored.validatorRegion, original.validatorRegion);
      expect(restored.estimatedLatency, original.estimatedLatency);
    });
  });

  group('ValidatorInfo Tests', () {
    test('test_ValidatorInfo_fromJson', () {
      final json = {
        'pubkey': 'validator_pubkey',
        'region': 'us',
        'latency': 50,
        'load': 75,
        'available': true,
        'name': 'Test Validator',
      };

      final validator = ValidatorInfo.fromJson(json);

      expect(validator.pubkey, 'validator_pubkey');
      expect(validator.region, 'us');
      expect(validator.latency, 50);
      expect(validator.load, 75);
      expect(validator.available, true);
      expect(validator.name, 'Test Validator');
    });

    test('test_ValidatorInfo_regionFlags', () {
      final asia = ValidatorInfo(pubkey: 'key', region: 'asia', latency: 100, load: 0, available: true);
      final eu = ValidatorInfo(pubkey: 'key', region: 'eu', latency: 100, load: 0, available: true);
      final us = ValidatorInfo(pubkey: 'key', region: 'us', latency: 100, load: 0, available: true);

      expect(asia.regionFlag, '🌏');
      expect(eu.regionFlag, '🇪🇺');
      expect(us.regionFlag, '🇺🇸');
    });
  });

  group('MagicBlockConfig Tests', () {
    test('test_MagicBlockConfig_devnet_factory', () {
      final config = MagicBlockConfig.devnet(programId: 'test_program');

      expect(config.network, MagicBlockNetwork.devnet);
      expect(config.rpcUrl, 'https://devnet-rpc.magicblock.app');
      expect(config.wsUrl, 'wss://devnet-rpc.magicblock.app');
      expect(config.programId, 'test_program');
    });

    test('test_MagicBlockConfig_mainnet_factory', () {
      final config = MagicBlockConfig.mainnet(programId: 'test_program');

      expect(config.network, MagicBlockNetwork.mainnet);
      expect(config.rpcUrl, 'https://rpc.magicblock.app');
      expect(config.wsUrl, 'wss://rpc.magicblock.app');
      expect(config.programId, 'test_program');
    });

    test('test_MagicBlockConfig_getDevnetValidator', () {
      expect(MagicBlockConfig.getDevnetValidator('asia'), 'MAS1Dt9qreoRMQ14YQuhg8UTZMMzDdKhmkZMECCzk57');
      expect(MagicBlockConfig.getDevnetValidator('eu'), 'MEUEuQfpPYQFvpZYMmwvbJeYpNUYDVbqLNcGJPc5ZwK');
      expect(MagicBlockConfig.getDevnetValidator('us'), 'MFVa7oPEvPZxmVeLgyqhYQJt2PkjfVdvZ3hNKVRWP3Z');
      expect(MagicBlockConfig.getDevnetValidator('unknown'), null);
    });
  });

  group('MagicTransactionResult Tests', () {
    test('test_MagicTransactionResult_isSuccess', () {
      final success = MagicTransactionResult(
        signature: 'sig123',
        routedToER: true,
        timestamp: DateTime.now(),
      );

      final failure = MagicTransactionResult(
        signature: 'sig123',
        routedToER: false,
        timestamp: DateTime.now(),
        error: 'Transaction failed',
      );

      expect(success.isSuccess, true);
      expect(failure.isSuccess, false);
    });

    test('test_MagicTransactionResult_toJson_fromJson', () {
      final original = MagicTransactionResult(
        signature: 'signature123',
        routedToER: true,
        validator: 'validator_key',
        slot: 12345,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        confirmationTimeMs: 50,
      );

      final json = original.toJson();
      final restored = MagicTransactionResult.fromJson(json);

      expect(restored.signature, original.signature);
      expect(restored.routedToER, original.routedToER);
      expect(restored.validator, original.validator);
      expect(restored.slot, original.slot);
      expect(restored.confirmationTimeMs, original.confirmationTimeMs);
    });
  });

  group('VrfResult Tests', () {
    test('test_VrfResult_randomnessHex', () {
      final vrf = VrfResult(
        randomness: [0x12, 0x34, 0xAB, 0xCD],
        proof: [0xFF, 0xEE],
        slot: 100,
      );

      expect(vrf.randomnessHex, '1234abcd');
    });
  });

  group('DeFiQuote Tests', () {
    test('test_DeFiQuote_properties', () {
      final quote = DeFiQuote(
        fromToken: 'SOL',
        toToken: 'USDC',
        inputAmount: 1000000,
        outputAmount: 990000,
        priceImpact: 0.01,
        dex: 'Jupiter',
        estimatedLatencyMs: 50,
      );

      expect(quote.fromToken, 'SOL');
      expect(quote.toToken, 'USDC');
      expect(quote.rate, closeTo(0.99, 0.001));
      expect(quote.minOutputAmount, 980100);
    });
  });

  group('TransferInstruction Tests', () {
    test('test_TransferInstruction_properties', () {
      final instruction = TransferInstruction(
        from: 'address1',
        to: 'address2',
        amount: 1000,
      );

      expect(instruction.from, 'address1');
      expect(instruction.to, 'address2');
      expect(instruction.amount, 1000);
    });
  });
}
