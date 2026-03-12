import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../widgets/loading_view.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        if (shopProvider.isLoading) {
          return Scaffold(
            body: LoadingView(message: 'Loading...'),
          );
        }

        if (shopProvider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(shopProvider.errorMessage!)),
          );
        }

        final shopName = shopProvider.shop?.name ??
            shopProvider.siteConfig?.shopName ??
            'Store';
        final config = shopProvider.siteConfig;
        final about = shopProvider.aboutPage;

        return Scaffold(
          appBar: SiteHeader(
            shopName: shopName,
            siteConfig: config,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(
                  imageUrl: about?.heroImageUrl,
                  title: about?.title ?? 'Our Story',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (about?.storyText != null && about!.storyText!.isNotEmpty)
                        Text(
                          about.storyText!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.8,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      if (about?.craftsmanshipTitle != null ||
                          (about?.craftsmanshipText != null &&
                              about!.craftsmanshipText!.isNotEmpty)) ...[
                        const SizedBox(height: 48),
                        if (about?.craftsmanshipTitle != null)
                          Text(
                            about!.craftsmanshipTitle!,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (about?.craftsmanshipText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            about!.craftsmanshipText!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              height: 1.8,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                        if (about?.craftsmanshipImageUrl != null) ...[
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              about!.craftsmanshipImageUrl!,
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                SiteFooter(shopName: shopName, siteConfig: config),
              ],
            ),
          ),
        );
      },
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
      height: 280,
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
        padding: const EdgeInsets.all(32),
        child: Text(
          title ?? 'About Us',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
