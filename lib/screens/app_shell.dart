import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'gift_plans/gift_plans_screen.dart';
import 'history/history_screen.dart';
import 'occasions/occasions_screen.dart';
import 'recipients/recipient_list_screen.dart';

/// The signed-in app: a bottom-navigation shell around the five main
/// screens. Each tab keeps its own state via [IndexedStack], but is forced
/// to rebuild (and re-fetch its data) every time you navigate *into* it, so
/// changes made on another tab always show up without needing a manual
/// pull-to-refresh or app restart.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  /// One refresh counter per tab. Bumping a counter changes the tab key,
  /// which makes Flutter rebuild that tab when the user navigates to it.
  final List<int> _versions = [0, 0, 0, 0, 0];

  void _goToTab(int index) {
    setState(() {
      _versions[index]++;
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        key: ValueKey('dashboard-${_versions[0]}'),
        onSeeRecipients: () => _goToTab(1),
        onSeeOccasions: () => _goToTab(2),
        onSeeGiftPlans: () => _goToTab(3),
        onSeeHistory: () => _goToTab(4),
      ),
      RecipientListScreen(key: ValueKey('recipients-${_versions[1]}')),
      OccasionsScreen(key: ValueKey('occasions-${_versions[2]}')),
      GiftPlansScreen(key: ValueKey('giftplans-${_versions[3]}')),
      HistoryScreen(key: ValueKey('history-${_versions[4]}')),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavBar(currentIndex: _index, onTap: _goToTab),
    );
  }
}
