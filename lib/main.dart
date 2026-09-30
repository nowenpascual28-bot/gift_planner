import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  }

  runApp(
    DevicePreview(enabled: true, builder: (context) => const GiftPlannerApp()),
  );
}

class GiftPlannerApp extends StatelessWidget {
  const GiftPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Planner',
      debugShowCheckedModeBanner: false,

      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: AppTheme.lightTheme,

      home: Env.isConfigured ? const AuthGate() : const SupabaseSetupScreen(),
    );
  }
}

/// Shown instead of crashing when the app has no Supabase configuration.
/// Run with, for example:
///   flutter run -d chrome --dart-define-from-file=.env
/// after copying .env.example to .env and filling in your project's URL and
/// publishable key.
class SupabaseSetupScreen extends StatelessWidget {
  const SupabaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gift Planner',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Supabase is not configured yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Copy .env.example to .env\n'
                  '2. Fill in SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY '
                  'from your Supabase project settings\n'
                  '3. Run the app with:\n'
                  '   flutter run -d chrome --dart-define-from-file=.env',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
