import 'package:flutter/material.dart';

/// Widget réutilisable : affiche une note sous forme d'étoiles.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < full
                ? Icons.star_rounded
                : (i == full && half)
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            size: size,
            color: Colors.amber,
          ),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.75, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
