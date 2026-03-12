import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/site_config.dart';

class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  const SiteHeader({
    super.key,
    required this.shopName,
    this.siteConfig,
    this.onNavigate,
  });

  final String shopName;
  final SiteConfig? siteConfig;
  final void Function(String route)? onNavigate;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final primary = siteConfig?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final isWide = MediaQuery.of(context).size.width >= 768;

    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      title: Text(
        shopName,
        style: GoogleFonts.cormorantGaramond(
          fontSize: isWide ? 24 : 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (isWide) ...[
          _NavItem(
            label: 'Home',
            onTap: () => _navigate(context, '/'),
          ),
          _NavItem(
            label: 'Products',
            onTap: () => _navigate(context, '/products'),
          ),
          _NavItem(
            label: 'About',
            onTap: () => _navigate(context, '/about'),
          ),
          _NavItem(
            label: 'Contact',
            onTap: () => _navigate(context, '/contact'),
          ),
        ],
      ],
    );
  }

  void _navigate(BuildContext context, String route) {
    if (onNavigate != null) {
      onNavigate!(route);
    } else {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
