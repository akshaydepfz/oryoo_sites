import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/site_config.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'constrained_container.dart';

/// Four-column footer: Logo+tagline | Quick links | Contact | Social
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
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      color: const Color(0xFF1A1A2E),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _Column1(shopName: shopName, siteConfig: siteConfig),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _Column2(),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _Column3(siteConfig: siteConfig),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _Column4(siteConfig: siteConfig),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Column1(shopName: shopName, siteConfig: siteConfig),
                  const SizedBox(height: 32),
                  _Column2(),
                  const SizedBox(height: 32),
                  _Column3(siteConfig: siteConfig),
                  const SizedBox(height: 32),
                  _Column4(siteConfig: siteConfig),
                ],
              ),
      ),
    );
  }
}

class _Column1 extends StatelessWidget {
  const _Column1({
    required this.shopName,
    this.siteConfig,
  });

  final String shopName;
  final SiteConfig? siteConfig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shopName,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        if (siteConfig?.tagline != null) ...[
          const SizedBox(height: 12),
          Text(
            siteConfig!.tagline!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _Column2 extends StatelessWidget {
  const _Column2();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _FooterLink(label: 'Home', route: AppRoutes.home),
        _FooterLink(label: 'Products', route: AppRoutes.products),
        _FooterLink(label: 'About', route: AppRoutes.about),
        _FooterLink(label: 'Contact', route: AppRoutes.contact),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.route});

  final String label;
  final String route;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _hovered ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _Column3 extends StatelessWidget {
  const _Column3({this.siteConfig});

  final SiteConfig? siteConfig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        if (siteConfig?.address != null && siteConfig!.address!.isNotEmpty)
          _ContactItem(
            icon: Icons.location_on_outlined,
            text: siteConfig!.address!,
          ),
        if (siteConfig?.phone != null && siteConfig!.phone!.isNotEmpty)
          _ContactItem(
            icon: Icons.phone_outlined,
            text: siteConfig!.phone!,
            onTap: () => launchUrl(Uri.parse('tel:${siteConfig!.phone}')),
          ),
        if (siteConfig?.email != null && siteConfig!.email!.isNotEmpty)
          _ContactItem(
            icon: Icons.email_outlined,
            text: siteConfig!.email!,
            onTap: () => launchUrl(Uri.parse('mailto:${siteConfig!.email}')),
          ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }
    return child;
  }
}

class _Column4 extends StatelessWidget {
  const _Column4({this.siteConfig});

  final SiteConfig? siteConfig;

  @override
  Widget build(BuildContext context) {
    final hasSocial = (siteConfig?.facebookUrl?.isNotEmpty ?? false) ||
        (siteConfig?.instagramUrl?.isNotEmpty ?? false) ||
        (siteConfig?.twitterUrl?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        if (hasSocial)
          Wrap(
            spacing: 16,
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
        const SizedBox(height: 24),
        Text(
          '© ${DateTime.now().year} All rights reserved.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white38,
          ),
        ),
      ],
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
