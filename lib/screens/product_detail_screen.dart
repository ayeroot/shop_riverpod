import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/format.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/rating_stars.dart';

/// Écran de détail d'un produit.
/// Reçoit un [productId] et charge les données via
/// [productByIdProvider] (FutureProvider.family) → AsyncValue.
class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final isFav = ref.watch(isFavoriteProvider(productId));
            return IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : null),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(productId),
            );
          }),
        ],
      ),
      body: AsyncValueWidget(
        value: productAsync,
        onRetry: () => ref.invalidate(productByIdProvider(productId)),
        data: (product) {
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(product.emoji, style: const TextStyle(fontSize: 96)),
              ),
              const SizedBox(height: 20),
              Text(product.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(product.category)),
                  const SizedBox(width: 12),
                  RatingStars(rating: product.rating, size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Text(formatPrice(product.price),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 6),
              Text(
                product.inStock ? 'En stock' : 'Rupture de stock',
                style: TextStyle(
                  color: product.inStock ? Colors.green : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(product.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 28),
              FilledButton.icon(
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
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Ajouter au panier'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
