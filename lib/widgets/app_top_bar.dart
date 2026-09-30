import 'package:flutter/material.dart';

/// The standard top bar used across the app so every screen shares the same
/// title style and action placement.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
