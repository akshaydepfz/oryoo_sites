import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/site_config.dart';
import '../models/testimonial.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/constrained_container.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_card.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';
import 'product_details_page.dart';

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
                      style: GoogleFonts.inter(fontSize: 16),
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
          appBar: SiteHeader(
            shopName: shopName,
            siteConfig: config,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(config: config),
                _CategoriesSection(shopName: shopName, config: config),
                _FeaturedProductsSection(shopName: shopName, config: config),
                _PromotionalBanner(config: config),
                _TestimonialsSection(testimonials: shopProvider.testimonials),
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
  const _HeroSection({this.config});

  final SiteConfig? config;

  @override
  Widget build(BuildContext context) {
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);

    return Container(
      height: MediaQuery.of(context).size.width > AppLayout.tabletBreakpoint
          ? 520
          : 380,
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
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: ConstrainedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  config?.heroTitle ?? config?.shopName ?? 'Welcome',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: MediaQuery.of(context).size.width > 768 ? 52 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (config?.heroSubtitle != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    config!.heroSubtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/products');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop by Category',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<CategoriesProvider>(
              builder: (context, catProvider, _) {
                if (catProvider.isLoading) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (catProvider.categories.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catProvider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 24),
                    itemBuilder: (context, i) {
                      final cat = catProvider.categories[i];
                      return SizedBox(
                        width: 220,
                        child: CategoryCard(
                          category: cat,
                          primaryColor: config?.effectivePrimaryColor,
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(
                              '/products',
                            );
                          },
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
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Products',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 40),
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
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];
                    return ProductCard(
                      product: product,
                      primaryColor: config?.effectivePrimaryColor,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: product),
                        ),
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
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
      ),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PromoItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Free Shipping',
                    subtitle: 'On orders above ₹999',
                    primary: primary,
                  ),
                  const SizedBox(width: 64),
                  _PromoItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Secure Payment',
                    subtitle: '100% secure checkout',
                    primary: primary,
                  ),
                ],
              )
            : Column(
                children: [
                  _PromoItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Free Shipping',
                    subtitle: 'On orders above ₹999',
                    primary: primary,
                  ),
                  const SizedBox(height: 32),
                  _PromoItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Secure Payment',
                    subtitle: '100% secure checkout',
                    primary: primary,
                  ),
                ],
              ),
      ),
    );
  }
}

class _PromoItem extends StatelessWidget {
  const _PromoItem({
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
        Icon(icon, size: 48, color: primary),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What Our Customers Say',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: testimonials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (context, i) {
                  final t = testimonials[i];
                  return SizedBox(
                    width: 360,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
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
                          const SizedBox(height: 12),
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
