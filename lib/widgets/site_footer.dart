import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/site_config.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({
    super.key,
    required this.shopName,
    this.siteConfig,
  });

  final String shopName;
  final SiteConfig? siteConfig;

  @override
  Widget build(BuildContext context) {
    final primary = siteConfig?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: primary,
      child: Column(
        children: [
          Text(
            shopName,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (siteConfig?.tagline != null) ...[
            const SizedBox(height: 8),
            Text(
              siteConfig!.tagline!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              if (siteConfig?.facebookUrl != null)
                _SocialLink(
                  label: 'Facebook',
                  url: siteConfig!.facebookUrl!,
                  icon: Icons.facebook,
                ),
              if (siteConfig?.instagramUrl != null)
                _SocialLink(
                  label: 'Instagram',
                  url: siteConfig!.instagramUrl!,
                  icon: Icons.camera_alt,
                ),
              if (siteConfig?.twitterUrl != null)
                _SocialLink(
                  label: 'Twitter',
                  url: siteConfig!.twitterUrl!,
                  icon: Icons.tag,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} $shopName. All rights reserved.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  const _SocialLink({
    required this.label,
    required this.url,
    required this.icon,
  });

  final String label;
  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
