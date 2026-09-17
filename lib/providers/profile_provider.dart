import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

// Profil utilisateur (mock). Chargé de façon asynchrone pour montrer
// le loading/erreur avec AsyncValue sur l'écran profil.
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

// Thème clair / sombre / système, changé depuis l'écran profil.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
