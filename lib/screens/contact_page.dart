import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/shop_provider.dart';
import '../widgets/constrained_container.dart';

/// Contact page content - used inside SiteLayout
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final config = shopProvider.siteConfig;
    final contact = shopProvider.contactPage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
            child: ConstrainedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _ContactCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    content: contact?.address ??
                        config?.address ??
                        'Address not available',
                    onTap: contact?.mapUrl != null
                        ? () => launchUrl(Uri.parse(contact!.mapUrl!))
                        : null,
                  ),
                  _ContactCard(
                    icon: Icons.phone_outlined,
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
                    icon: Icons.email_outlined,
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
                    const SizedBox(height: 24),
                    _ContactCard(
                      icon: Icons.schedule_outlined,
                      title: 'Store Hours',
                      content: contact.storeHours!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (contact?.mapEmbedUrl != null &&
              contact!.mapEmbedUrl!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ConstrainedContainer(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Us',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(contact.mapEmbedUrl!)),
                      child: Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to open map',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1A1A2E), size: 28),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.5,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                size: 18,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}
