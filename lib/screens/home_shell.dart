import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

// Écran principal avec la navigation.
// Sur petit écran -> barre en bas (NavigationBar).
// Sur grand écran (>= 720px) -> barre à gauche (NavigationRail).
// J'utilise un IndexedStack pour garder l'état des onglets.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _tabs = [
    CatalogScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);

    final destinations = <_Dest>[
      const _Dest(Icons.storefront_outlined, Icons.storefront, 'Catalogue'),
      const _Dest(Icons.favorite_border, Icons.favorite, 'Favoris'),
      _Dest(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Panier',
          badge: cartCount),
      const _Dest(Icons.person_outline, Icons.person, 'Profil'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: _maybeBadge(d.icon, d.badge),
                        selectedIcon: _maybeBadge(d.selected, d.badge),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _index, children: _tabs)),
              ],
            ),
          );
        }
        return Scaffold(
          body: IndexedStack(index: _index, children: _tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: _maybeBadge(d.icon, d.badge),
                  selectedIcon: _maybeBadge(d.selected, d.badge),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _maybeBadge(IconData icon, int badge) {
    if (badge <= 0) return Icon(icon);
    return Badge(label: Text('$badge'), child: Icon(icon));
  }
}

class _Dest {
  final IconData icon;
  final IconData selected;
  final String label;
  final int badge;
  const _Dest(this.icon, this.selected, this.label, {this.badge = 0});
}
