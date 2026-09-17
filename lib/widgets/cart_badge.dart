import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

/// Icône panier avec pastille de comptage qui « rebondit » à chaque
/// changement du nombre d'articles (bonus : animation sur l'ajout au
/// panier). Lit [cartCountProvider] via Riverpod.
class CartBadge extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const CartBadge({super.key, required this.onTap});

  @override
  ConsumerState<CartBadge> createState() => _CartBadgeState();
}

class _CartBadgeState extends ConsumerState<CartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1, end: 1.5)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(cartCountProvider);

    // Déclenche un rebond à chaque fois que le compteur change.
    ref.listen<int>(cartCountProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        _controller.forward(from: 0);
      }
    });

    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: widget.onTap,
          tooltip: 'Panier',
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: scheme.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
