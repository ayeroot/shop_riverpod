import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/async_value_widget.dart';

// Écran profil : charge un utilisateur (mock) en async et permet
// de changer le thème.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final cartCount = ref.watch(cartCountProvider);
    final favCount = ref.watch(favoritesProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: AsyncValueWidget(
        value: profileAsync,
        onRetry: () => ref.invalidate(profileProvider),
        data: (user) {
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(user.avatarEmoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: theme.textTheme.bodyMedium),
                    Text(user.city, style: theme.textTheme.bodySmall),
                    Text(user.memberSince, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        icon: Icons.shopping_cart,
                        label: 'Panier',
                        value: '$cartCount'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.favorite,
                        label: 'Favoris',
                        value: '$favCount'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Apparence', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: RadioGroup<ThemeMode>(
                  groupValue: themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(themeModeProvider.notifier).state = v;
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                          title: Text('Système'), value: ThemeMode.system),
                      RadioListTile<ThemeMode>(
                          title: Text('Clair'), value: ThemeMode.light),
                      RadioListTile<ThemeMode>(
                          title: Text('Sombre'), value: ThemeMode.dark),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
