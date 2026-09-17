/// Modèle immuable représentant un produit du catalogue.
///
/// Fait partie de la couche "domaine" : aucune logique d'affichage ni
/// de state management ici, uniquement des données.
class Product {
  final String id;
  final String name;
  final String category;
  final int price; // en francs CFA (entier, pas de centimes)
  final double rating;
  final String emoji;
  final String description;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.emoji,
    required this.description,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      rating: (json['rating'] as num).toDouble(),
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      inStock: json['inStock'] as bool,
    );
  }
}
