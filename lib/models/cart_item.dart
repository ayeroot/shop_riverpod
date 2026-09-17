import 'product.dart';

/// Une ligne du panier : un produit + une quantité.
///
/// Immuable : toute modification passe par [copyWith], ce qui facilite
/// la gestion d'état côté Riverpod (on remplace l'objet, on ne le mute
/// pas).
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  int get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
