import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gift_planner/main.dart';
import 'package:gift_planner/models/gift_plan.dart';
import 'package:gift_planner/theme/app_theme.dart';
import 'package:gift_planner/widgets/budget_progress.dart';
import 'package:gift_planner/widgets/status_chip.dart';

void main() {
  testWidgets('SupabaseSetupScreen shows setup instructions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SupabaseSetupScreen(),
      ),
    );

    expect(find.text('Gift Planner'), findsOneWidget);
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });

  testWidgets('BudgetProgress shows spent and remaining amounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: BudgetProgress(budget: 100, spent: 40)),
      ),
    );

    expect(find.textContaining('₱40.00 of ₱100.00 spent'), findsOneWidget);
    expect(find.textContaining('₱60.00 left'), findsOneWidget);
  });

  testWidgets('BudgetProgress flags overspending', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: BudgetProgress(budget: 50, spent: 75)),
      ),
    );

    expect(find.textContaining('over budget'), findsOneWidget);
  });

  testWidgets('StatusChip shows the status label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: StatusChip(status: GiftPlanStatus.purchased),
        ),
      ),
    );

    expect(find.text('Purchased'), findsOneWidget);
  });

  test('GiftPlanStatus.fromDb round-trips known values', () {
    for (final status in GiftPlanStatus.values) {
      expect(GiftPlanStatus.fromDb(status.dbValue), status);
    }
  });

  test('GiftPlanStatus.fromDb falls back to planned for unknown values', () {
    expect(GiftPlanStatus.fromDb('not-a-real-status'), GiftPlanStatus.planned);
  });
}
