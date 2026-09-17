import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/profile_provider.dart';
import 'screens/home_shell.dart';
import 'theme.dart';

void main() {
  // ProviderScope : racine indispensable de Riverpod, stocke l'état de
  // tous les providers de l'application.
  runApp(const ProviderScope(child: ShopApp()));
}

class ShopApp extends ConsumerWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Shop Riverpod',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomeShell(),
    );
  }
}
