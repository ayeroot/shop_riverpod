import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère l'ensemble des identifiants de produits mis en favori.
///
/// Persistance locale via `shared_preferences` : les favoris survivent
/// au redémarrage de l'application. Le chargement initial est
/// asynchrone (déclenché dans le constructeur).
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(const {}) {
    _load();
  }

  static const _prefsKey = 'favorite_product_ids';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const [];
    state = saved.toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state);
    if (!next.add(id)) next.remove(id); // add renvoie false si déjà présent
    state = next;
    await _persist();
  }
}

/// (8) StateNotifierProvider — favoris persistés.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

/// Provider dérivé (family) — un produit donné est-il en favori ?
final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(favoritesProvider).contains(id);
});
