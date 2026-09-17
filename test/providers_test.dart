import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_riverpod/models/product.dart';
import 'package:shop_riverpod/data/product_repository.dart';
import 'package:shop_riverpod/providers/product_providers.dart';
import 'package:shop_riverpod/providers/cart_provider.dart';

/// Faux repository : renvoie une liste fixe, sans asset ni délai.
class FakeRepo extends ProductRepository {
  const FakeRepo();
  @override
  Future<List<Product>> fetchProducts() async => const [
        Product(id: 'a', name: 'Alpha', category: 'X', price: 1000, rating: 4.0, emoji: '🅰️', description: 'a', inStock: true),
        Product(id: 'b', name: 'Beta', category: 'Y', price: 3000, rating: 5.0, emoji: '🅱️', description: 'b', inStock: true),
        Product(id: 'c', name: 'Gamma', category: 'X', price: 2000, rating: 3.0, emoji: '🇬', description: 'c', inStock: true),
      ];
}

const _p = Product(
  id: 'a', name: 'Alpha', category: 'X', price: 1000,
  rating: 4.0, emoji: '🅰️', description: 'a', inStock: true,
);

void main() {
  group('CartNotifier', () {
    test('ajout, incrément, décrément, total', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).add(_p);
      c.read(cartProvider.notifier).add(_p); // même produit -> quantité 2
      expect(c.read(cartCountProvider), 2);
      expect(c.read(cartTotalProvider), 2000);

      c.read(cartProvider.notifier).decrement('a');
      expect(c.read(cartCountProvider), 1);

      c.read(cartProvider.notifier).remove('a');
      expect(c.read(cartProvider), isEmpty);
    });
  });

  group('filteredProductsProvider', () {
    test('filtre par recherche et trie par prix croissant', () async {
      final c = ProviderContainer(overrides: [
        productRepositoryProvider.overrideWithValue(const FakeRepo()),
      ]);
      addTearDown(c.dispose);

      // Attend le chargement asynchrone du catalogue.
      await c.read(catalogProvider.future);

      // Tri par prix croissant : Alpha(1000), Gamma(2000), Beta(3000).
      c.read(sortOptionProvider.notifier).state = SortOption.priceAsc;
      final sorted = c.read(filteredProductsProvider).value!;
      expect(sorted.map((p) => p.name).toList(), ['Alpha', 'Gamma', 'Beta']);

      // Recherche "beta" -> un seul résultat.
      c.read(searchQueryProvider.notifier).state = 'beta';
      final searched = c.read(filteredProductsProvider).value!;
      expect(searched.length, 1);
      expect(searched.first.name, 'Beta');
    });
  });
}
