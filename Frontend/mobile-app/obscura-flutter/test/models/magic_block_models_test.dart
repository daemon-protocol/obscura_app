import 'package:flutter_test/flutter_test.dart';
import 'package:obscura_vault/models/magic_block_models.dart';

void main() {
  group('ExecutionMode Enum Tests', () {
    test('test_ExecutionMode_has_6_values', () {
      // Verify enum has exactly 6 values
      expect(ExecutionMode.values.length, 6);
    });

    test('test_ExecutionMode_has_all_expected_values', () {
      // Verify all expected modes exist
      expect(ExecutionMode.values, contains(ExecutionMode.standard));
      expect(ExecutionMode.values, contains(ExecutionMode.fast));
      expect(ExecutionMode.values, contains(ExecutionMode.private));
      expect(ExecutionMode.values, contains(ExecutionMode.compressed));
      expect(ExecutionMode.values, contains(ExecutionMode.fastCompressed));
      expect(ExecutionMode.values, contains(ExecutionMode.privateCompressed));
    });

    test('test_fastCompressed_isHybrid', () {
      // Verify fastCompressed is identified as hybrid
      expect(ExecutionMode.fastCompressed.isHybrid, true);
    });

    test('test_privateCompressed_isHybrid', () {
      // Verify privateCompressed is identified as hybrid
      expect(ExecutionMode.privateCompressed.isHybrid, true);
    });

    test('test_standard_isNotHybrid', () {
      // Verify base modes are not identified as hybrid
      expect(ExecutionMode.standard.isHybrid, false);
      expect(ExecutionMode.fast.isHybrid, false);
      expect(ExecutionMode.private.isHybrid, false);
      expect(ExecutionMode.compressed.isHybrid, false);
    });

    test('test_fastCompressed_usesER', () {
      // Verify fastCompressed uses ER
      expect(ExecutionMode.fastCompressed.usesER, true);
    });

    test('test_fastCompressed_usesCompression', () {
      // Verify fastCompressed uses compression
      expect(ExecutionMode.fastCompressed.usesCompression, true);
    });

    test('test_privateCompressed_usesAll', () {
      // Verify privateCompressed uses ER, compression, and privacy
      expect(ExecutionMode.privateCompressed.usesER, true);
      expect(ExecutionMode.privateCompressed.usesCompression, true);
      expect(ExecutionMode.privateCompressed.isPrivate, true);
    });

    test('test_standard_usesNothing', () {
      // Verify standard mode uses no special features
      expect(ExecutionMode.standard.usesER, false);
      expect(ExecutionMode.standard.usesCompression, false);
      expect(ExecutionMode.standard.isPrivate, false);
      expect(ExecutionMode.standard.isHybrid, false);
    });

    test('test_fastCompressed_emoji', () {
      // Verify fastCompressed emoji is correct
      expect(ExecutionMode.fastCompressed.emoji, '⚡🗜️');
    });

    test('test_privateCompressed_emoji', () {
      // Verify privateCompressed emoji is correct
      expect(ExecutionMode.privateCompressed.emoji, '🔒🗜️');
    });

    test('test_all_emojis_are_correct', () {
      // Verify all mode emojis
      expect(ExecutionMode.standard.emoji, '⏱️');
      expect(ExecutionMode.fast.emoji, '⚡');
      expect(ExecutionMode.private.emoji, '🔒');
      expect(ExecutionMode.compressed.emoji, '🗜️');
      expect(ExecutionMode.fastCompressed.emoji, '⚡🗜️');
      expect(ExecutionMode.privateCompressed.emoji, '🔒🗜️');
    });

    test('test_fastCompressed_latency', () {
      // Verify fastCompressed estimated latency is ~60ms
      expect(ExecutionMode.fastCompressed.estimatedLatencyMs, 60);
    });

    test('test_privateCompressed_latency', () {
      // Verify privateCompressed estimated latency is ~85ms
      expect(ExecutionMode.privateCompressed.estimatedLatencyMs, 85);
    });

    test('test_all_latency_values', () {
      // Verify all latency estimates
      expect(ExecutionMode.standard.estimatedLatencyMs, 400);
      expect(ExecutionMode.fast.estimatedLatencyMs, 50);
      expect(ExecutionMode.private.estimatedLatencyMs, 75);
      expect(ExecutionMode.compressed.estimatedLatencyMs, 100);
      expect(ExecutionMode.fastCompressed.estimatedLatencyMs, 60);
      expect(ExecutionMode.privateCompressed.estimatedLatencyMs, 85);
    });

    test('test_displayName_values', () {
      // Verify all display names
      expect(ExecutionMode.standard.displayName, 'Standard');
      expect(ExecutionMode.fast.displayName, 'Fast (ER)');
      expect(ExecutionMode.private.displayName, 'Private (PER)');
      expect(ExecutionMode.compressed.displayName, 'Compressed');
      expect(ExecutionMode.fastCompressed.displayName, 'Fast + Compressed');
      expect(ExecutionMode.privateCompressed.displayName, 'Private + Compressed');
    });

    test('test_shortName_values', () {
      // Verify all short names
      expect(ExecutionMode.standard.shortName, 'Standard');
      expect(ExecutionMode.fast.shortName, 'Fast');
      expect(ExecutionMode.private.shortName, 'Private');
      expect(ExecutionMode.compressed.shortName, 'Compressed');
      expect(ExecutionMode.fastCompressed.shortName, 'Fast+Comp');
      expect(ExecutionMode.privateCompressed.shortName, 'Priv+Comp');
    });

    test('test_description_values', () {
      // Verify descriptions contain expected keywords
      expect(ExecutionMode.standard.description, contains('Normal Solana'));
      expect(ExecutionMode.fast.description, contains('Ephemeral Rollup'));
      expect(ExecutionMode.private.description, contains('Private'));
      expect(ExecutionMode.compressed.description, contains('ZK compressed'));
      expect(ExecutionMode.fastCompressed.description, contains('ER speed'));
      expect(ExecutionMode.privateCompressed.description, contains('PER privacy'));
    });

    test('test_costMultiplier_values', () {
      // Verify cost multipliers
      expect(ExecutionMode.standard.costMultiplier, 1.0);
      expect(ExecutionMode.fast.costMultiplier, 1.0);
      expect(ExecutionMode.private.costMultiplier, 1.2);
      expect(ExecutionMode.compressed.costMultiplier, 0.001);
      expect(ExecutionMode.fastCompressed.costMultiplier, 0.001);
      expect(ExecutionMode.privateCompressed.costMultiplier, 0.0012);
    });

    test('test_requiresDelegation', () {
      // Verify which modes require delegation
      expect(ExecutionMode.standard.requiresDelegation, false);
      expect(ExecutionMode.fast.requiresDelegation, true);
      expect(ExecutionMode.private.requiresDelegation, true);
      expect(ExecutionMode.compressed.requiresDelegation, false);
      expect(ExecutionMode.fastCompressed.requiresDelegation, true);
      expect(ExecutionMode.privateCompressed.requiresDelegation, true);
    });

    test('test_usesER_for_all_ER_modes', () {
      // Verify usesER returns true for all ER-based modes
      expect(ExecutionMode.fast.usesER, true);
      expect(ExecutionMode.private.usesER, true);
      expect(ExecutionMode.fastCompressed.usesER, true);
      expect(ExecutionMode.privateCompressed.usesER, true);
    });

    test('test_usesCompression_for_all_compression_modes', () {
      // Verify usesCompression returns true for all compression modes
      expect(ExecutionMode.compressed.usesCompression, true);
      expect(ExecutionMode.fastCompressed.usesCompression, true);
      expect(ExecutionMode.privateCompressed.usesCompression, true);
    });

    test('test_isPrivate_for_private_modes', () {
      // Verify isPrivate returns true for private modes
      expect(ExecutionMode.private.isPrivate, true);
      expect(ExecutionMode.privateCompressed.isPrivate, true);
      // Verify non-private modes return false
      expect(ExecutionMode.standard.isPrivate, false);
      expect(ExecutionMode.fast.isPrivate, false);
      expect(ExecutionMode.compressed.isPrivate, false);
      expect(ExecutionMode.fastCompressed.isPrivate, false);
    });
  });

  group('DelegationState Enum Tests', () {
    test('test_DelegationState_has_4_values', () {
      expect(DelegationState.values.length, 4);
    });

    test('test_DelegationState_emojis', () {
      expect(DelegationState.notDelegated.emoji, '⚪');
      expect(DelegationState.delegated.emoji, '🟢');
      expect(DelegationState.pendingCommit.emoji, '🟡');
      expect(DelegationState.pendingUndelegation.emoji, '🟠');
    });

    test('test_DelegationState_displayNames', () {
      expect(DelegationState.notDelegated.displayName, 'Not Delegated');
      expect(DelegationState.delegated.displayName, 'Delegated');
      expect(DelegationState.pendingCommit.displayName, 'Pending Commit');
      expect(DelegationState.pendingUndelegation.displayName, 'Pending Undelegation');
    });

    test('test_DelegationState_isDelegated', () {
      expect(DelegationState.notDelegated.isDelegated, false);
      expect(DelegationState.delegated.isDelegated, true);
      expect(DelegationState.pendingCommit.isDelegated, true);
      expect(DelegationState.pendingUndelegation.isDelegated, true);
    });

    test('test_DelegationState_canExecuteTransactions', () {
      expect(DelegationState.notDelegated.canExecuteTransactions, false);
      expect(DelegationState.delegated.canExecuteTransactions, true);
      expect(DelegationState.pendingCommit.canExecuteTransactions, false);
      expect(DelegationState.pendingUndelegation.canExecuteTransactions, false);
    });
  });

  group('MagicBlockNetwork Enum Tests', () {
    test('test_MagicBlockNetwork_has_2_values', () {
      expect(MagicBlockNetwork.values.length, 2);
    });

    test('test_MagicBlockNetwork_emojis', () {
      expect(MagicBlockNetwork.devnet.emoji, '🧪');
      expect(MagicBlockNetwork.mainnet.emoji, '🚀');
    });

    test('test_MagicBlockNetwork_displayNames', () {
      expect(MagicBlockNetwork.devnet.displayName, 'Devnet');
      expect(MagicBlockNetwork.mainnet.displayName, 'Mainnet');
    });

    test('test_MagicBlockNetwork_isDevnet', () {
      expect(MagicBlockNetwork.devnet.isDevnet, true);
      expect(MagicBlockNetwork.mainnet.isDevnet, false);
    });

    test('test_MagicBlockNetwork_isMainnet', () {
      expect(MagicBlockNetwork.mainnet.isMainnet, true);
      expect(MagicBlockNetwork.devnet.isMainnet, false);
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
      const status1 = DelegationStatus(
        account: 'test_address',
        state: DelegationState.delegated,
      );
      const status2 = DelegationStatus(
        account: 'test_address',
        state: DelegationState.delegated,
      );
      const status3 = DelegationStatus(
        account: 'other_address',
        state: DelegationState.delegated,
      );

      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('test_DelegationStatus_toJson_fromJson', () {
      const original = DelegationStatus(
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
      const asia = ValidatorInfo(pubkey: 'key', region: 'asia', latency: 100, load: 0, available: true);
      const eu = ValidatorInfo(pubkey: 'key', region: 'eu', latency: 100, load: 0, available: true);
      const us = ValidatorInfo(pubkey: 'key', region: 'us', latency: 100, load: 0, available: true);

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
      const vrf = VrfResult(
        randomness: [0x12, 0x34, 0xAB, 0xCD],
        proof: [0xFF, 0xEE],
        slot: 100,
      );

      expect(vrf.randomnessHex, '1234abcd');
    });
  });
}
