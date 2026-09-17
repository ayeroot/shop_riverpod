import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Logique métier du panier, isolée des widgets (StateNotifier).
///
/// L'état est une liste immuable de [CartItem] : chaque opération
/// produit une NOUVELLE liste plutôt que de muter l'existante.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  /// Ajoute un produit ; s'il est déjà présent, incrémente la quantité.
  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: 1)];
    } else {
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ];
    }
  }

  /// Retire complètement une ligne du panier.
  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Diminue la quantité d'une unité ; retire la ligne si elle tombe à 0.
  void decrement(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ].where((item) => item.quantity > 0).toList();
  }

  /// Augmente la quantité d'une unité.
  void increment(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void clear() => state = const [];
}

/// (7) StateNotifierProvider — le panier.
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Provider dérivé — nombre total d'articles (somme des quantités).
final cartCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Provider dérivé — montant total du panier.
final cartTotalProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.lineTotal);
});
