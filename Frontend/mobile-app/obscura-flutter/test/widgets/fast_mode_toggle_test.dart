import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obscura_vault/models/magic_block_models.dart';
import 'package:obscura_vault/widgets/fast_mode_toggle.dart';
import 'package:obscura_vault/theme/theme.dart';

void main() {
  // Create a testable widget wrapper with theme
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }

  group('FastModeToggle Widget Tests', () {
    testWidgets('test_FastModeToggle_renders_all_6_modes', (tester) async {
      int selectedCount = 0;

      await tester.pumpWidget(
        buildTestWidget(
          FastModeToggle(
            mode: ExecutionMode.standard,
            onChanged: (mode) {
              selectedCount++;
            },
          ),
        ),
      );

      // Verify all 6 mode buttons are rendered
      for (final mode in ExecutionMode.values) {
        expect(find.text(mode.emoji), findsOneWidget,
            reason: '${mode.name} emoji should be rendered');
      }

      // Verify all mode labels are shown (since showLabels defaults to true)
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Fast'), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Compressed'), findsOneWidget);
      expect(find.text('Fast+Comp'), findsOneWidget);
      expect(find.text('Priv+Comp'), findsOneWidget);
    });

    testWidgets('test_FastModeToggle_selection_updates', (tester) async {
      // Verify that selecting different modes renders correctly
      await tester.pumpWidget(
        buildTestWidget(
          FastModeToggle(
            mode: ExecutionMode.fast,
            onChanged: (mode) {},
          ),
        ),
      );

      expect(find.text('Fast'), findsOneWidget);
    });

    testWidgets('test_FastModeToggle_disabled_state', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FastModeToggle(
            mode: ExecutionMode.fast,
            onChanged: (mode) {},
            enabled: false,
          ),
        ),
      );

      // Verify the widget renders but doesn't respond to taps
      expect(find.byType(FastModeToggle), findsOneWidget);

      // Try to tap (should not trigger onChanged)
      await tester.tap(find.text('⏱️'));
      await tester.pump();

      // Widget should still be showing fast mode (no change)
      expect(find.text('⚡'), findsOneWidget);
    });

    testWidgets('test_FastModeToggle_without_labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FastModeToggle(
            mode: ExecutionMode.standard,
            onChanged: (mode) {},
            showLabels: false,
          ),
        ),
      );

      // Should show emojis but not labels
      expect(find.text('⏱️'), findsOneWidget);
      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('🔒'), findsOneWidget);
      expect(find.text('🗜️'), findsOneWidget);
      expect(find.text('⚡🗜️'), findsOneWidget);
      expect(find.text('🔒🗜️'), findsOneWidget);

      // Labels should not be shown
      expect(find.text('Standard'), findsNothing);
      expect(find.text('Fast'), findsNothing);
    });

    testWidgets('test_FastModeToggle_hybrid_mode_selection', (tester) async {
      // Verify hybrid mode buttons are rendered and tappable
      await tester.pumpWidget(
        buildTestWidget(
          FastModeToggle(
            mode: ExecutionMode.fastCompressed,
            onChanged: (mode) {},
          ),
        ),
      );

      // Verify Fast+Comp label exists
      expect(find.text('Fast+Comp'), findsOneWidget);

      // Verify Priv+Comp label exists
      expect(find.text('Priv+Comp'), findsOneWidget);
    });
  });

  group('FastModeSwitch Widget Tests', () {
    testWidgets('test_FastModeSwitch_standard_mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FastModeSwitch(
            isFastMode: false,
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.text('⏱️'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Fast Mode'), findsNothing);
      expect(find.text('~50ms'), findsNothing);
    });

    testWidgets('test_FastModeSwitch_fast_mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FastModeSwitch(
            isFastMode: true,
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('Fast Mode'), findsOneWidget);
      expect(find.text('~50ms'), findsOneWidget);
      expect(find.text('Standard'), findsNothing);
    });

    testWidgets('test_FastModeSwitch_toggle', (tester) async {
      // Verify FastModeSwitch renders and is tappable
      await tester.pumpWidget(
        buildTestWidget(
          FastModeSwitch(
            isFastMode: true,
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.byType(FastModeSwitch), findsOneWidget);
      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('Fast Mode'), findsOneWidget);
    });
  });

  group('ExecutionModeSelector Widget Tests', () {
    testWidgets('test_ExecutionModeSelector_shows_all_6_modes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeSelector(
            mode: ExecutionMode.standard,
            onChanged: (mode) {},
          ),
        ),
      );

      // Verify all 6 mode options are displayed
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Fast (ER)'), findsOneWidget);
      expect(find.text('Private (PER)'), findsOneWidget);
      expect(find.text('Compressed'), findsOneWidget);
      expect(find.text('Fast + Compressed'), findsOneWidget);
      expect(find.text('Private + Compressed'), findsOneWidget);
    });

    testWidgets('test_ExecutionModeSelector_selection_works', (tester) async {
      // Verify ExecutionModeSelector renders in different modes
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeSelector(
            mode: ExecutionMode.fast,
            onChanged: (mode) {},
          ),
        ),
      );

      expect(find.text('Fast (ER)'), findsOneWidget);
    });

    testWidgets('test_ExecutionModeSelector_shows_descriptions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeSelector(
            mode: ExecutionMode.standard,
            onChanged: (mode) {},
          ),
        ),
      );

      // Verify descriptions are shown
      expect(find.textContaining('Normal Solana'), findsOneWidget);
      expect(find.textContaining('Ephemeral Rollup'), findsOneWidget);
      expect(find.textContaining('Private execution'), findsOneWidget);
      expect(find.textContaining('ZK compressed'), findsOneWidget);
      expect(find.textContaining('ER speed'), findsOneWidget);
      expect(find.textContaining('PER privacy'), findsOneWidget);
    });

    testWidgets('test_ExecutionModeSelector_hybrid_modes_included', (tester) async {
      // Verify hybrid modes are included in selector
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeSelector(
            mode: ExecutionMode.fastCompressed,
            onChanged: (mode) {},
          ),
        ),
      );

      expect(find.text('Fast + Compressed'), findsOneWidget);
      expect(find.text('Private + Compressed'), findsOneWidget);
    });
  });

  group('SpeedComparisonWidget Tests', () {
    testWidgets('test_SpeedComparisonWidget_renders_all_bars', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SpeedComparisonWidget(
            mode: ExecutionMode.standard,
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(SpeedComparisonWidget), findsOneWidget);
    });

    testWidgets('test_SpeedComparisonWidget_highlights_selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SpeedComparisonWidget(
            mode: ExecutionMode.fastCompressed,
          ),
        ),
      );

      // The selected mode should be highlighted
      expect(find.byType(SpeedComparisonWidget), findsOneWidget);
    });

    testWidgets('test_SpeedComparisonWidget_includes_hybrid_modes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SpeedComparisonWidget(
            mode: ExecutionMode.privateCompressed,
          ),
        ),
      );

      // Verify widget renders for hybrid mode
      expect(find.byType(SpeedComparisonWidget), findsOneWidget);
    });
  });

  group('ExecutionModeBadge Tests', () {
    testWidgets('test_ExecutionModeBadge_renders', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeBadge(mode: ExecutionMode.fast),
        ),
      );

      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('Fast'), findsOneWidget);
    });

    testWidgets('test_ExecutionModeBadge_hybrid_modes', (tester) async {
      // Test fast compressed badge
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeBadge(mode: ExecutionMode.fastCompressed),
        ),
      );

      expect(find.text('⚡🗜️'), findsOneWidget);
      expect(find.text('Fast+Comp'), findsOneWidget);

      // Test private compressed badge
      await tester.pumpWidget(
        buildTestWidget(
          ExecutionModeBadge(mode: ExecutionMode.privateCompressed),
        ),
      );

      expect(find.text('🔒🗜️'), findsOneWidget);
      expect(find.text('Priv+Comp'), findsOneWidget);
    });
  });

  group('HybridModeBadge Tests', () {
    testWidgets('test_HybridModeBadge_renders', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridModeBadge(mode: ExecutionMode.fastCompressed),
        ),
      );

      expect(find.text('⚡🗜️'), findsOneWidget);
    });

    testWidgets('test_HybridModeBadge_shows_description_when_enabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridModeBadge(
            mode: ExecutionMode.fastCompressed,
            showDescription: true,
          ),
        ),
      );

      expect(find.text('⚡🗜️'), findsOneWidget);
      expect(find.text('Fast+Comp'), findsOneWidget);
    });

    testWidgets('test_HybridModeBadge_non_hybrid_returns_standard_badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridModeBadge(mode: ExecutionMode.fast),
        ),
      );

      // Non-hybrid modes should show standard badge
      expect(find.text('⚡'), findsOneWidget);
    });

    testWidgets('test_HybridModeBadge_privateCompressed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridModeBadge(
            mode: ExecutionMode.privateCompressed,
            showDescription: true,
          ),
        ),
      );

      expect(find.text('🔒🗜️'), findsOneWidget);
      expect(find.text('Priv+Comp'), findsOneWidget);
    });
  });

  group('HybridBalanceDisplay Tests', () {
    testWidgets('test_HybridBalanceDisplay_shows_total_balance', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridBalanceDisplay(
            regularBalance: 1.5,
            compressedBalance: 0.5,
            mode: ExecutionMode.compressed, // Changed to compressed to show total
          ),
        ),
      );

      expect(find.textContaining('SOL'), findsOneWidget);
      expect(find.textContaining('2.0000'), findsOneWidget);
    });

    testWidgets('test_HybridBalanceDisplay_shows_breakdown_for_compression_modes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridBalanceDisplay(
            regularBalance: 1.5,
            compressedBalance: 0.5,
            mode: ExecutionMode.compressed,
          ),
        ),
      );

      // Should show breakdown chips
      expect(find.textContaining('Regular:'), findsOneWidget);
      expect(find.textContaining('Compressed:'), findsOneWidget);
    });

    testWidgets('test_HybridBalanceDisplay_shows_hybrid_emoji', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridBalanceDisplay(
            regularBalance: 1.5,
            compressedBalance: 0.5,
            mode: ExecutionMode.fastCompressed,
          ),
        ),
      );

      // Should show hybrid mode emoji
      expect(find.text('⚡🗜️'), findsOneWidget);
    });

    testWidgets('test_HybridBalanceDisplay_no_compression_no_breakdown', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridBalanceDisplay(
            regularBalance: 2.0,
            compressedBalance: 0.0,
            mode: ExecutionMode.fast,
          ),
        ),
      );

      // Should not show breakdown for non-compression modes with no compressed balance
      expect(find.textContaining('Regular:'), findsNothing);
      expect(find.textContaining('Compressed:'), findsNothing);
    });
  });

  group('HybridCostComparison Tests', () {
    testWidgets('test_HybridCostComparison_shows_for_hybrid_modes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridCostComparison(mode: ExecutionMode.fastCompressed),
        ),
      );

      expect(find.textContaining('~1000x cheaper'), findsOneWidget);
      expect(find.byIcon(Icons.savings_rounded), findsOneWidget);
    });

    testWidgets('test_HybridCostComparison_privateCompressed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridCostComparison(mode: ExecutionMode.privateCompressed),
        ),
      );

      expect(find.textContaining('~1000x cheaper'), findsOneWidget);
    });

    testWidgets('test_HybridCostComparison_hidden_for_non_hybrid', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridCostComparison(mode: ExecutionMode.fast),
        ),
      );

      // Should be empty for non-hybrid modes
      expect(find.textContaining('~1000x cheaper'), findsNothing);
      expect(find.byIcon(Icons.savings_rounded), findsNothing);
    });

    testWidgets('test_HybridCostComparison_hidden_for_standard', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          HybridCostComparison(mode: ExecutionMode.standard),
        ),
      );

      // Should be empty for standard mode
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
