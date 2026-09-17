import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../providers/favorites_provider.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Écran favoris : croise les identifiants favoris ([favoritesProvider])
/// avec le catalogue chargé pour n'afficher que les produits aimés.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: AsyncValueWidget(
        value: catalogAsync,
        onRetry: () => ref.invalidate(catalogProvider),
        data: (products) {
          final favorites =
              products.where((p) => favIds.contains(p.id)).toList();
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Aucun favori pour l'instant.\n"
                      "Touchez le cœur d'un produit pour l'ajouter ici.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 224,
                ),
                itemBuilder: (context, i) {
                  final p = favorites[i];
                  return ProductCard(
                    product: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: p.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
