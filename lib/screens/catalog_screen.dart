import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_badge.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

/// Écran catalogue : recherche + filtrage par catégorie + tri.
/// Lit le provider dérivé [filteredProductsProvider] (AsyncValue) et
/// délègue la gestion loading/erreur au widget réutilisable
/// [AsyncValueWidget].
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final sort = ref.watch(sortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: 'Trier',
            icon: const Icon(Icons.sort),
            initialValue: sort,
            onSelected: (v) =>
                ref.read(sortOptionProvider.notifier).state = v,
            itemBuilder: (context) => [
              for (final o in SortOption.values)
                PopupMenuItem(value: o, child: Text(o.label)),
            ],
          ),
          CartBadge(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                return ChoiceChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (_) =>
                      ref.read(categoryFilterProvider.notifier).state = cat,
                );
              },
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: productsAsync,
              onRetry: () => ref.invalidate(catalogProvider),
              data: (products) {
                if (products.isEmpty) {
                  return const _Empty(
                    icon: Icons.search_off,
                    message: 'Aucun produit ne correspond à votre recherche.',
                  );
                }
                return LayoutBuilder(
                  builder: (context, c) {
                    final cross = c.maxWidth >= 900
                        ? 4
                        : c.maxWidth >= 600
                            ? 3
                            : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 224,
                      ),
                      itemBuilder: (context, i) {
                        final p = products[i];
                        return ProductCard(
                          product: p,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: p.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String message;
  const _Empty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
