import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/site_config.dart';
import '../theme/app_theme.dart';
import 'constrained_container.dart';

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
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                // Left: Logo / Shop Name
                GestureDetector(
                  onTap: () => _navigate(context, '/'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (siteConfig?.logoUrl != null) ...[
                        Image.network(
                          siteConfig!.logoUrl!,
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildLogoText(context),
                        ),
                        const SizedBox(width: 12),
                      ],
                      _buildLogoText(context),
                    ],
                  ),
                ),
                const Spacer(),
                // Center: Navigation
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
                const Spacer(),
                // Right: Search, Menu
                if (isWide) ...[
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, color: Colors.grey.shade700, size: 22),
                    tooltip: 'Search',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.menu, color: Colors.grey.shade700, size: 22),
                    tooltip: 'Menu',
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, color: Colors.grey.shade700),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.menu, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoText(BuildContext context) {
    return Text(
      shopName,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
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

class _NavItem extends StatefulWidget {
  const _NavItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _hovered ? const Color(0xFF1A1A2E) : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
