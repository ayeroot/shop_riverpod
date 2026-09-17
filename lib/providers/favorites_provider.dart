import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Les favoris = un ensemble d'ids de produits.
// On les sauvegarde avec shared_preferences pour qu'ils restent
// après avoir fermé l'app.
class FavoritesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'favorite_product_ids';

  @override
  Set<String> build() {
    _load(); // on charge les favoris sauvegardés au démarrage
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    state = saved.toSet();
  }

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state);
    if (!next.add(id)) {
      next.remove(id); // add() renvoie false s'il y était déjà -> on l'enlève
    }
    state = next;

    // on sauvegarde
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

// Est-ce que ce produit est en favori ? (family = avec un paramètre)
final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(favoritesProvider).contains(id);
});
