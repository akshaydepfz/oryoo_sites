import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../widgets/constrained_container.dart';

/// About page content - used inside SiteLayout
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final about = shopProvider.aboutPage;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(
            imageUrl: about?.heroImageUrl,
            title: about?.title ?? 'Our Story',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
            child: ConstrainedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (about?.storyText != null && about!.storyText!.isNotEmpty)
                    Text(
                      about.storyText!,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        height: 1.9,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  if (about?.craftsmanshipTitle != null ||
                      (about?.craftsmanshipText != null &&
                          about!.craftsmanshipText!.isNotEmpty)) ...[
                    const SizedBox(height: 56),
                    if (about?.craftsmanshipTitle != null)
                      Text(
                        about!.craftsmanshipTitle!,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    if (about?.craftsmanshipText != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        about!.craftsmanshipText!,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          height: 1.9,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (about?.craftsmanshipImageUrl != null) ...[
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          about!.craftsmanshipImageUrl!,
                          width: double.infinity,
                          height: 320,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    this.imageUrl,
    this.title,
  });

  final String? imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(48),
        child: Text(
          title ?? 'About Us',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
