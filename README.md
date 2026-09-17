# 🛒 Shop Riverpod — App e-commerce Flutter

Application e-commerce Flutter démontrant la maîtrise du **state
management avec Riverpod** : catalogue de produits (liste + détail),
panier, favoris persistés, filtrage/tri, et profil utilisateur (mock).
Les données produits sont **mockées** (fichier JSON local) et chargées
de façon **asynchrone** ; les états de chargement et d'erreur sont
gérés dans l'UI via **`AsyncValue`**.

---

## ✨ Fonctionnalités

- **Catalogue** : liste responsive (grille 2→4 colonnes), recherche,
  filtrage par catégorie et tri (nom, prix ↑/↓, note).
- **Détail produit** : chargé via un `FutureProvider.family`.
- **Panier** : ajout, suppression, gestion des quantités (+/−), total
  calculé, vidage, badge de comptage.
- **Favoris** : ajout/retrait, **persistés localement**
  (`shared_preferences`), survivent au redémarrage.
- **Profil utilisateur (mock)** : chargé de façon asynchrone, + choix
  du thème clair/sombre/système.
- **États UI** : chargement (spinner), erreur (message + « Réessayer »)
  et données, centralisés dans un widget réutilisable `AsyncValueWidget`.
- **Bonus** : animation « rebond » du badge panier à chaque ajout
  (`CartBadge`), retour visuel via SnackBar.
- Navigation adaptative (NavigationBar mobile / NavigationRail desktop).

## 🏗️ Architecture en couches

La logique métier est **séparée des widgets** : les écrans ne font que
lire des providers et déclencher des actions ; ils ne connaissent ni le
`shared_preferences`, ni le chargement JSON.

```
┌─────────────────────────────────────────────┐
│  PRÉSENTATION  (lib/screens, lib/widgets)     │  ← UI, ConsumerWidget
├─────────────────────────────────────────────┤
│  ÉTAT / LOGIQUE  (lib/providers)              │  ← Riverpod (Notifiers)
├─────────────────────────────────────────────┤
│  DONNÉES  (lib/data/product_repository.dart)  │  ← fausse API (JSON)
├─────────────────────────────────────────────┤
│  DOMAINE  (lib/models)                         │  ← modèles immuables
└─────────────────────────────────────────────┘
```

```
lib/
├── main.dart                       # ProviderScope + MaterialApp
├── theme.dart                      # thèmes clair/sombre (Material 3)
├── models/
│   ├── product.dart                # modèle Product (immuable, fromJson)
│   ├── cart_item.dart              # ligne de panier (product + quantité)
│   └── user_profile.dart           # profil mock
├── data/
│   └── product_repository.dart     # fausse API : charge assets/products.json
├── providers/
│   ├── product_providers.dart      # repo, catalogue, filtres, tri, dérivés
│   ├── cart_provider.dart          # panier (StateNotifier) + dérivés
│   ├── favorites_provider.dart     # favoris persistés (StateNotifier)
│   └── profile_provider.dart       # profil (FutureProvider) + thème
├── screens/
│   ├── home_shell.dart             # navigation adaptative (4 onglets)
│   ├── catalog_screen.dart         # liste + recherche + filtre + tri
│   ├── product_detail_screen.dart  # détail (FutureProvider.family)
│   ├── cart_screen.dart            # panier
│   ├── favorites_screen.dart       # favoris
│   └── profile_screen.dart         # profil + thème
├── widgets/
│   ├── async_value_widget.dart     # gestion loading/erreur réutilisable
│   ├── product_card.dart           # carte produit
│   ├── cart_badge.dart             # badge panier animé (bonus)
│   ├── quantity_selector.dart      # sélecteur de quantité
│   └── rating_stars.dart           # note en étoiles
└── utils/
    └── format.dart                 # formatage des prix (FCFA)
assets/
└── products.json                   # 12 produits mockés
```

## 🧩 Providers utilisés

10 providers distincts, de types variés :

| # | Provider | Type Riverpod | Rôle |
|---|----------|---------------|------|
| 1 | `productRepositoryProvider` | `Provider` | Expose le repository (injectable/overridable en test) |
| 2 | `catalogProvider` | `FutureProvider` | Charge le catalogue → `AsyncValue<List<Product>>` |
| 3 | `productByIdProvider` | `FutureProvider.family` | Charge un produit par id (écran détail) |
| 4 | `searchQueryProvider` | `StateProvider` | Texte de recherche |
| 5 | `categoryFilterProvider` | `StateProvider` | Catégorie sélectionnée |
| 6 | `sortOptionProvider` | `StateProvider` | Option de tri |
| 7 | `cartProvider` | `StateNotifierProvider` | Panier (ajout/suppr./quantité) |
| 8 | `favoritesProvider` | `StateNotifierProvider` | Favoris persistés (shared_preferences) |
| 9 | `profileProvider` | `FutureProvider` | Profil utilisateur mock (async) |
| 10 | `themeModeProvider` | `StateProvider` | Thème clair/sombre/système |

Providers **dérivés** (calculés à partir d'autres, sans état propre) :
`filteredProductsProvider` (catalogue filtré + trié, renvoie un
`AsyncValue`), `categoriesProvider`, `cartCountProvider`,
`cartTotalProvider`, `isFavoriteProvider` (family).

### Gestion asynchrone (`AsyncValue`)

Le catalogue, le détail et le profil sont exposés en `AsyncValue`. Le
widget réutilisable `AsyncValueWidget<T>` traite les trois cas via
`.when(data / loading / error)` et propose un bouton « Réessayer »
(`ref.invalidate(...)`), évitant de dupliquer cette logique.

## 🚀 Installation et lancement

```bash
git clone https://github.com/ayeroot/recipes_app.git   # ← remplacez par l'URL de ce dépôt
cd <dossier-du-projet>

flutter pub get
flutter run                 # appareil / émulateur
flutter run -d chrome       # Web
```

### Tests

```bash
flutter test        # 5 tests : logique panier, filtrage, UI (loading→data, recherche)
```

### Analyse statique

```bash
flutter analyze     # 0 problème
```

## 📱 Captures d'écran

| Catalogue (mobile) | Détail | Panier |
|---|---|---|
| ![Catalogue](screenshots/catalog_mobile.png) | ![Détail](screenshots/detail.png) | ![Panier](screenshots/cart.png) |

| Favoris | Profil | Catalogue (desktop / NavigationRail) |
|---|---|---|
| ![Favoris](screenshots/favorites.png) | ![Profil](screenshots/profile.png) | ![Desktop](screenshots/catalog_desktop.png) |

## 🛠️ Technologies

- **Flutter** (Material 3)
- **flutter_riverpod** (2.x) — `Provider`, `FutureProvider`,
  `FutureProvider.family`, `StateProvider`, `StateNotifierProvider`
- **shared_preferences** — persistance des favoris
- **flutter_test** — tests unitaires (ProviderContainer) et de widgets
