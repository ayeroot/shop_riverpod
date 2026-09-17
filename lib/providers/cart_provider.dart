import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

// Le panier. J'utilise Notifier (Riverpod 2.x) vu dans le cours.
// L'état est une liste de CartItem qu'on remplace à chaque changement.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      // pas encore dans le panier
      state = [...state, CartItem(product: product, quantity: 1)];
    } else {
      // déjà présent -> on ajoute 1 à la quantité
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ];
    }
  }

  void increment(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String productId) {
    // enlève 1, et si la quantité tombe à 0 on retire la ligne
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ].where((item) => item.quantity > 0).toList();
  }

  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

// Nombre d'articles (pour le badge du panier)
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});

// Prix total du panier
final cartTotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, item) => sum + item.lineTotal);
});
