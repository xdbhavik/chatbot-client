import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/chat/screens/chat_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/providers/settings_provider.dart';
import 'router.dart';
import 'theme.dart';

final appRouterProvider = StateProvider<AppRouterState>((ref) => const AppRouterState());

class LmStudioChatApp extends ConsumerWidget {
  const LmStudioChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).settings;
    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    return MaterialApp(
      title: 'LM Studio Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(appRouterProvider).route;
    return switch (route) {
      AppRoute.chat => const ChatScreen(),
      AppRoute.settings => const SettingsScreen(),
    };
  }
}
