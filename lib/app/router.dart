import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/models/presentation/models_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/store/presentation/store_screen.dart';

abstract final class AppRouter {
  static final root = GoRouter(
    initialLocation: '/chat',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/store',
            name: 'store',
            builder: (context, state) => const StoreScreen(),
          ),
          GoRoute(
            path: '/models',
            name: 'models',
            builder: (context, state) => const ModelsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
