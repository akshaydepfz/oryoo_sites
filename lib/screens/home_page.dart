import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/site_config.dart';
import '../models/testimonial.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/constrained_container.dart';
import '../widgets/product_card.dart';

/// Homepage content - used inside SiteLayout
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>();
      if (shop.shopId != null) {
        context.read<ProductsProvider>().loadProducts(shop.shopId);
        context.read<CategoriesProvider>().loadCategories(shop.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final shopName = shopProvider.shop?.name ??
        shopProvider.siteConfig?.shopName ??
        'Store';
    final config = shopProvider.siteConfig;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(config: config),
          _TrustBadgesSection(config: config),
          _CategoriesSection(shopName: shopName, config: config),
          _FeaturedProductsSection(shopName: shopName, config: config),
          _PromotionalBanner(config: config),
          _FeaturedCollectionsSection(config: config),
          _TestimonialsSection(testimonials: shopProvider.testimonials),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({this.config});

  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final isDesktop =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Container(
      height: isDesktop ? 560 : 420,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary,
        image: config?.heroImageUrl != null
            ? DecorationImage(
                image: NetworkImage(config!.heroImageUrl!),
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
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: ConstrainedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  config?.heroTitle ?? config?.shopName ?? 'Welcome',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: isDesktop ? 56 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (config?.heroSubtitle != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    config!.heroSubtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 40),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.products),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Shop Now',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadgesSection extends StatelessWidget {
  const _TrustBadgesSection({this.config});

  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TrustBadge(
                    icon: Icons.local_shipping_outlined,
                    title: 'Free Shipping',
                    subtitle: 'On orders above ₹999',
                    primary: primary,
                  ),
                  const SizedBox(width: 48),
                  _TrustBadge(
                    icon: Icons.verified_user_outlined,
                    title: 'Secure Payment',
                    subtitle: '100% secure checkout',
                    primary: primary,
                  ),
                  const SizedBox(width: 48),
                  _TrustBadge(
                    icon: Icons.diamond_outlined,
                    title: 'Premium Quality',
                    subtitle: 'Handcrafted excellence',
                    primary: primary,
                  ),
                  const SizedBox(width: 48),
                  _TrustBadge(
                    icon: Icons.people_outline,
                    title: 'Trusted',
                    subtitle: '5000+ happy customers',
                    primary: primary,
                  ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  _TrustBadge(
                    icon: Icons.local_shipping_outlined,
                    title: 'Free Shipping',
                    subtitle: 'On orders above ₹999',
                    primary: primary,
                  ),
                  _TrustBadge(
                    icon: Icons.verified_user_outlined,
                    title: 'Secure Payment',
                    subtitle: '100% secure checkout',
                    primary: primary,
                  ),
                  _TrustBadge(
                    icon: Icons.diamond_outlined,
                    title: 'Premium Quality',
                    subtitle: 'Handcrafted excellence',
                    primary: primary,
                  ),
                  _TrustBadge(
                    icon: Icons.people_outline,
                    title: 'Trusted',
                    subtitle: '5000+ happy customers',
                    primary: primary,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.shopName,
    this.config,
  });

  final String shopName;
  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop by Category',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 48),
            Consumer<CategoriesProvider>(
              builder: (context, catProvider, _) {
                if (catProvider.isLoading) {
                  return const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (catProvider.categories.isEmpty) {
                  return const SizedBox.shrink();
                }
                final isDesktop =
                    MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;
                if (isDesktop) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                    ),
                    itemCount: catProvider.categories.length,
                    itemBuilder: (context, i) {
                      final cat = catProvider.categories[i];
                      return CategoryCard(
                        category: cat,
                        primaryColor: config?.effectivePrimaryColor,
                        onTap: () => context.go(AppRoutes.products),
                      );
                    },
                  );
                }
                return SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catProvider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 24),
                    itemBuilder: (context, i) {
                      final cat = catProvider.categories[i];
                      return SizedBox(
                        width: 240,
                        child: CategoryCard(
                          category: cat,
                          primaryColor: config?.effectivePrimaryColor,
                          onTap: () => context.go(AppRoutes.products),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProductsSection extends StatelessWidget {
  const _FeaturedProductsSection({
    required this.shopName,
    this.config,
  });

  final String shopName;
  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Products',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 48),
            Consumer<ProductsProvider>(
              builder: (context, prodProvider, _) {
                if (prodProvider.isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final products = prodProvider.featuredProducts.isNotEmpty
                    ? prodProvider.featuredProducts
                    : prodProvider.products.take(8).toList();
                if (products.isEmpty) {
                  return Text(
                    'No products yet.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  );
                }
                final width = MediaQuery.of(context).size.width;
                final crossAxisCount = AppLayout.productGridColumns(width);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 32,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];
                    final productId = product.id ?? '${product.name.hashCode}';
                    return ProductCard(
                      product: product,
                      primaryColor: config?.effectivePrimaryColor,
                      onTap: () => context.go(
                        AppRoutes.productDetailsPath(productId),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionalBanner extends StatelessWidget {
  const _PromotionalBanner({this.config});

  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 48),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 48),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
      ),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            Text(
              'Premium Jewelry Collection',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Handcrafted Excellence — Discover timeless pieces',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.products),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Explore Collection',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCollectionsSection extends StatelessWidget {
  const _FeaturedCollectionsSection({this.config});

  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    child: _CollectionCard(
                      title: 'New Arrivals',
                      subtitle: 'Latest additions',
                      config: config,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _CollectionCard(
                      title: 'Best Sellers',
                      subtitle: 'Customer favorites',
                      config: config,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _CollectionCard(
                    title: 'New Arrivals',
                    subtitle: 'Latest additions',
                    config: config,
                  ),
                  const SizedBox(height: 24),
                  _CollectionCard(
                    title: 'Best Sellers',
                    subtitle: 'Customer favorites',
                    config: config,
                  ),
                ],
              ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.title,
    required this.subtitle,
    this.config,
  });

  final String title;
  final String subtitle;
  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.products),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection({required this.testimonials});

  final List<Testimonial> testimonials;

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What Our Customers Say',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: testimonials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 32),
                itemBuilder: (context, i) {
                  final t = testimonials[i];
                  return SizedBox(
                    width: 380,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.rating != null)
                            Row(
                              children: List.generate(
                                5,
                                (j) => Icon(
                                  j < t.rating!
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                          if (t.rating != null) const SizedBox(height: 16),
                          Expanded(
                            child: Text(
                              t.content,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '— ${t.authorName}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
