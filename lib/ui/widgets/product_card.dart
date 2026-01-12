// lib/ui/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // neutral pale background used behind the product image
    const imageBg = Color(0xFFF5F5F7);

    return Card(
      color: Colors.white, // card itself stays white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Image container with neutral bg to avoid tinted/colored artifacts
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: imageBg,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: Center(
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black87, height: 1.1),
              ),
            ),

            const SizedBox(height: 6),
            // Price
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${product.price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
