import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

// Les façons de trier le catalogue
enum SortOption {
  nameAsc('Nom (A→Z)'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  ratingDesc('Meilleures notes');

  const SortOption(this.label);
  final String label;
}

// Le repository (source des données). Mis dans un provider pour pouvoir
// le remplacer par un faux dans les tests.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository();
});

// Charge la liste des produits (asynchrone) -> AsyncValue
final catalogProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProducts();
});

// Charge un seul produit par son id, pour l'écran de détail.
// autoDispose : le provider se libère quand on quitte l'écran de détail
// (on n'a pas besoin de garder ce produit en mémoire après). family
// parce qu'il prend un paramètre (l'id).
final productByIdProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProductById(id);
});

// Le texte tapé dans la recherche
final searchQueryProvider = StateProvider<String>((ref) => '');

// La catégorie choisie ('Toutes' = on ne filtre pas)
final categoryFilterProvider = StateProvider<String>((ref) => 'Toutes');

// Le tri choisi
final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.nameAsc);

// La liste des catégories, construite à partir des produits chargés
final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(catalogProvider).valueOrNull ?? [];
  final cats = products.map((p) => p.category).toSet().toList()..sort();
  return ['Toutes', ...cats];
});

// Le catalogue après recherche + filtre + tri.
// On garde un AsyncValue pour continuer à gérer le chargement/erreur.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final catalog = ref.watch(catalogProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final sort = ref.watch(sortOptionProvider);

  return catalog.whenData((products) {
    // 1) on filtre
    final list = products.where((p) {
      final okQuery = query.isEmpty || p.name.toLowerCase().contains(query);
      final okCategory = category == 'Toutes' || p.category == category;
      return okQuery && okCategory;
    }).toList();

    // 2) on trie
    switch (sort) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  });
});
