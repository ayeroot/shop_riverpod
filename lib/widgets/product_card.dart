import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/format.dart';
import 'rating_stars.dart';

/// Widget réutilisable : carte d'un produit (catalogue et favoris).
///
/// ConsumerWidget : lit l'état "favori" et déclenche les actions
/// panier / favoris via les notifiers — aucune donnée en dur, tout
/// vient du [product] et des providers.
class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFav = ref.watch(isFavoriteProvider(product.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 96,
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer,
                  alignment: Alignment.center,
                  child: Text(product.emoji, style: const TextStyle(fontSize: 44)),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(product.id),
                  ),
                ),
                if (!product.inStock)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Rupture',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  RatingStars(rating: product.rating, size: 13),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 34,
                        width: 34,
                        child: IconButton.filled(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onPressed: product.inStock
                              ? () {
                                  ref.read(cartProvider.notifier).add(product);
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      content: Text('« ${product.name} » ajouté au panier'),
                                      duration: const Duration(seconds: 1),
                                    ));
                                }
                              : null,
                          icon: const Icon(Icons.add_shopping_cart),
                          tooltip: 'Ajouter au panier',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
