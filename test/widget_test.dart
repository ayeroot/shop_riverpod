import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_riverpod/main.dart';
import 'package:shop_riverpod/models/product.dart';
import 'package:shop_riverpod/data/product_repository.dart';
import 'package:shop_riverpod/providers/product_providers.dart';

const _products = [
  Product(id: 'a', name: 'Casque Test', category: 'Audio', price: 1000, rating: 4.0, emoji: '🎧', description: 'desc', inStock: true),
  Product(id: 'b', name: 'Souris Test', category: 'Info', price: 2000, rating: 4.5, emoji: '🖱️', description: 'desc', inStock: true),
];

// Repo qui répond tout de suite.
class FastRepo extends ProductRepository {
  const FastRepo();
  @override
  Future<List<Product>> fetchProducts() async => _products;
}

// Repo lent, pour voir l'état "chargement".
class SlowRepo extends ProductRepository {
  const SlowRepo();
  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products;
  }
}

// Repo qui plante, pour tester l'état d'erreur.
class FailingRepo extends ProductRepository {
  const FailingRepo();
  @override
  Future<List<Product>> fetchProducts() async {
    throw Exception('Erreur réseau simulée');
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
  }

  Widget wrap(ProductRepository repo) => ProviderScope(
        overrides: [productRepositoryProvider.overrideWithValue(repo)],
        child: const ShopApp(),
      );

  testWidgets('affiche un indicateur de chargement puis le catalogue',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(wrap(const SlowRepo()));

    // Future encore en attente -> état loading (spinner) via AsyncValue.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Après résolution -> les produits mockés s'affichent.
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Casque Test'), findsOneWidget);
    expect(find.text('Souris Test'), findsOneWidget);
  });

  testWidgets('la recherche filtre la liste', (tester) async {
    phone(tester);
    await tester.pumpWidget(wrap(const FastRepo()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'casque');
    await tester.pumpAndSettle();

    expect(find.text('Casque Test'), findsOneWidget);
    expect(find.text('Souris Test'), findsNothing);
  });

  testWidgets('le catalogue affiche le titre', (tester) async {
    phone(tester);
    await tester.pumpWidget(wrap(const FastRepo()));
    await tester.pumpAndSettle();
    expect(find.text('Catalogue'), findsWidgets);
  });

  testWidgets("affiche un message d'erreur et un bouton Réessayer quand le "
      "chargement échoue", (tester) async {
    phone(tester);
    await tester.pumpWidget(wrap(const FailingRepo()));
    await tester.pumpAndSettle();

    // Le repo plante -> l'UI doit montrer l'erreur, pas crasher.
    expect(find.text('Impossible de charger les données.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
