import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/shop_provider.dart';
import '../widgets/loading_view.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
        final contact = shopProvider.contactPage;

        return Scaffold(
          appBar: SiteHeader(
            shopName: shopName,
            siteConfig: config,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _ContactCard(
                        icon: Icons.location_on,
                        title: 'Address',
                        content: contact?.address ??
                            config?.address ??
                            'Address not available',
                        onTap: contact?.mapUrl != null
                            ? () => launchUrl(Uri.parse(contact!.mapUrl!))
                            : null,
                      ),
                      _ContactCard(
                        icon: Icons.phone,
                        title: 'Phone',
                        content: contact?.phone ??
                            config?.phone ??
                            'Phone not available',
                        onTap: (contact?.phone ?? config?.phone) != null
                            ? () => launchUrl(Uri.parse(
                                  'tel:${contact?.phone ?? config?.phone}',
                                ))
                            : null,
                      ),
                      _ContactCard(
                        icon: Icons.email,
                        title: 'Email',
                        content: contact?.email ??
                            config?.email ??
                            'Email not available',
                        onTap: (contact?.email ?? config?.email) != null
                            ? () => launchUrl(Uri.parse(
                                  'mailto:${contact?.email ?? config?.email}',
                                ))
                            : null,
                      ),
                      if (contact?.storeHours != null &&
                          contact!.storeHours!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _ContactCard(
                          icon: Icons.schedule,
                          title: 'Store Hours',
                          content: contact.storeHours!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (contact?.mapEmbedUrl != null &&
                    contact!.mapEmbedUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Find Us',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: _MapEmbed(url: contact.mapEmbedUrl!),
                  ),
                  const SizedBox(height: 24),
                ],
                SiteFooter(shopName: shopName, siteConfig: config),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.content,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF1A1A2E), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.open_in_new, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders an iframe for Google Maps embed.
/// For Flutter web, we use HtmlElementView with an iframe.
class _MapEmbed extends StatelessWidget {
  const _MapEmbed({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    // Use an iframe via HtmlElementView for web
    return Builder(
      builder: (context) {
        // For Flutter web, we can use dart:html to create an iframe
        // For simplicity, use a clickable link that opens the map
        return GestureDetector(
          onTap: () => launchUrl(Uri.parse(url)),
          child: Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Tap to open map',
                  style: GoogleFonts.inter(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
