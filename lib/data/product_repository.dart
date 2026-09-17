import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';

// Va chercher les données des produits.
// Ici c'est une fausse API : on lit un fichier JSON local avec un
// petit délai pour simuler le réseau (et voir le chargement).
// Plus tard on pourrait remplacer par un vrai appel HTTP ici sans
// rien changer aux écrans.
class ProductRepository {
  const ProductRepository();

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 700)); // faux délai réseau

    final raw = await rootBundle.loadString('assets/products.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Cherche un produit par son id
  Future<Product> fetchProductById(String id) async {
    final products = await fetchProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Produit introuvable : $id'),
    );
  }
}
