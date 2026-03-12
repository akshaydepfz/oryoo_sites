import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../providers/shop_provider.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ShopProvider>().siteConfig;
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final whatsapp = config?.whatsappNumber ?? config?.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(
          product.name,
          style: GoogleFonts.inter(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductImage(url: product.displayImage),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (whatsapp.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openWhatsApp(whatsapp, product),
                        icon: const Icon(Icons.chat),
                        label: const Text('Contact on WhatsApp'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String number, Product product) async {
    final clean = number.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent('Hi, I am interested in ${product.name} (₹${product.price.toStringAsFixed(0)})')}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        height: 320,
        color: Colors.grey.shade200,
        child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey.shade400),
      );
    }

    return Image.network(
      url,
      height: 320,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 320,
        color: Colors.grey.shade200,
        child: Icon(Icons.broken_image, size: 80, color: Colors.grey.shade400),
      ),
    );
  }
}
