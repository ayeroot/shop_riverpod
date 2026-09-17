import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

/// Options de tri disponibles sur le catalogue.
enum SortOption {
  nameAsc('Nom (A→Z)'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  ratingDesc('Meilleures notes');

  const SortOption(this.label);
  final String label;
}

/// (1) Provider — expose le repository (couche données).
/// Injecté ici pour pouvoir être remplacé facilement dans les tests
/// (override) par un faux repository.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository();
});

/// (2) FutureProvider — charge le catalogue de façon asynchrone.
/// Expose un AsyncValue<List<Product>> (loading / data / error) que
/// l'UI consomme directement.
final catalogProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProducts();
});

/// (3) FutureProvider.family — charge un produit précis pour l'écran
/// de détail (paramètre = id du produit).
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProductById(id);
});

/// (4) StateProvider — texte de recherche.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// (5) StateProvider — catégorie sélectionnée ('Toutes' = pas de filtre).
final categoryFilterProvider = StateProvider<String>((ref) => 'Toutes');

/// (6) StateProvider — option de tri courante.
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.nameAsc);

/// Provider dérivé — liste des catégories disponibles, calculée à partir
/// du catalogue chargé.
final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(catalogProvider).valueOrNull ?? const <Product>[];
  final set = products.map((p) => p.category).toSet().toList()..sort();
  return ['Toutes', ...set];
});

/// Provider dérivé — catalogue filtré + trié.
///
/// Combine le catalogue (async) avec les filtres/tri (synchrones) et
/// renvoie un AsyncValue : l'UI garde ainsi la gestion du chargement et
/// des erreurs même après filtrage.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final catalog = ref.watch(catalogProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final sort = ref.watch(sortOptionProvider);

  return catalog.whenData((products) {
    final list = products.where((p) {
      final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query);
      final matchesCategory = category == 'Toutes' || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();

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
