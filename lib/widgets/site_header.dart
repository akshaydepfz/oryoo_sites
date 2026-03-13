import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/site_config.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'constrained_container.dart';

/// Modern sticky header with URL-based navigation
class SiteHeader extends StatelessWidget {
  const SiteHeader({
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
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
                // Left: Shop name only
                GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  behavior: HitTestBehavior.opaque,
                  child: _buildLogoText(context),
                ),
                const Spacer(),
                // Center: Navigation links
                if (isWide) ...[
                  _NavItem(
                    label: 'Home',
                    route: AppRoutes.home,
                  ),
                  _NavItem(
                    label: 'Products',
                    route: AppRoutes.products,
                  ),
                  _NavItem(
                    label: 'About',
                    route: AppRoutes.about,
                  ),
                  _NavItem(
                    label: 'Contact',
                    route: AppRoutes.contact,
                  ),
                ],
                const Spacer(),
                // Right: Web = nav links only. Mobile = menu icon (opens drawer)
                if (!isWide)
                  IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: Colors.grey.shade700,
                      size: 24,
                    ),
                    tooltip: 'Menu',
                  ),
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
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.label, required this.route});

  final String label;
  final String route;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final isActive = path == widget.route ||
        (widget.route == AppRoutes.home && (path == '/' || path.isEmpty)) ||
        (widget.route == AppRoutes.products && path.startsWith('/products'));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hovered || isActive
                      ? const Color(0xFF1A1A2E)
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: _hovered || isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
