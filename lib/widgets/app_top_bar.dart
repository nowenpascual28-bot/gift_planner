import 'package:flutter/material.dart';

import 'theme_toggle_button.dart';

/// The standard top bar used across the app so every screen shares the same
/// title style, theme toggle, and action placement.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool showThemeToggle;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final allActions = <Widget>[
      if (showThemeToggle) const ThemeToggleButton(),
      ...?actions,
    ];

    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      automaticallyImplyLeading: showBack,
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
