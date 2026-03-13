import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../widgets/loading_view.dart';
import 'site_footer.dart';
import 'site_header.dart';

/// Global layout wrapper for the e-commerce site.
/// Structure: SiteHeader (sticky) | MainContent | SiteFooter
/// Header and footer stay fixed; MainContent changes with routes.
class SiteLayout extends StatelessWidget {
  const SiteLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        if (shopProvider.isLoading) {
          return Scaffold(
            body: LoadingView(message: 'Loading your store...'),
          );
        }

        if (shopProvider.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shopProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final shopName = shopProvider.shop?.name ??
            shopProvider.siteConfig?.shopName ??
            'Store';
        final config = shopProvider.siteConfig;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SiteHeader(
                shopName: shopName,
                siteConfig: config,
              ),
              Expanded(
                child: child,
              ),
              SiteFooter(
                shopName: shopName,
                siteConfig: config,
              ),
            ],
          ),
        );
      },
    );
  }
}
