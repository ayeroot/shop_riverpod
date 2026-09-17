import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';

/// Couche d'accès aux données (data layer).
///
/// Simule une API distante : les produits sont mockés dans un fichier
/// JSON local (`assets/products.json`), chargés de façon asynchrone
/// avec un délai artificiel pour rendre visibles les états de
/// chargement / erreur dans l'UI (via AsyncValue).
///
/// Les widgets ne connaissent jamais cette classe directement : ils
/// passent par les providers Riverpod (séparation logique / UI).
class ProductRepository {
  const ProductRepository();

  /// Récupère le catalogue. Peut être remplacé par un vrai appel HTTP
  /// sans toucher ni aux providers ni à l'UI.
  Future<List<Product>> fetchProducts() async {
    // Simule la latence réseau.
    await Future.delayed(const Duration(milliseconds: 700));

    final raw = await rootBundle.loadString('assets/products.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Récupère un produit par son identifiant (fausse API).
  Future<Product> fetchProductById(String id) async {
    final products = await fetchProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Produit introuvable : $id'),
    );
  }
}
