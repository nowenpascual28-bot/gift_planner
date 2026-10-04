import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'gift_plans/gift_plans_screen.dart';
import 'history/history_screen.dart';
import 'occasions/occasions_screen.dart';
import 'recipients/recipient_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

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
