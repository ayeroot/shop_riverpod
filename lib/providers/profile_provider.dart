import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

/// (9) FutureProvider — profil utilisateur (mock), chargé de façon
/// asynchrone pour illustrer la gestion loading / erreur avec
/// AsyncValue sur l'écran de profil.
final profileProvider = FutureProvider<UserProfile>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return const UserProfile(
    name: 'Ayeda François Daniel',
    email: 'dev@example.com',
    city: 'Djougou, Bénin',
    memberSince: 'Membre depuis 2024',
    avatarEmoji: '🧑‍💻',
  );
});

/// (10) StateProvider — thème clair / sombre (bonus UX, piloté depuis
/// l'écran de profil).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
