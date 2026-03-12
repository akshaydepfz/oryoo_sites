import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/site_config.dart';
import '../models/testimonial.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/category_card.dart';
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
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
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
      height: 320,
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
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                config?.heroTitle ?? config?.shopName ?? 'Welcome',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (config?.heroSubtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  config!.heroSubtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<CategoriesProvider>(
            builder: (context, catProvider, _) {
              if (catProvider.isLoading) {
                return const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (catProvider.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: catProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final cat = catProvider.categories[i];
                    return SizedBox(
                      width: 180,
                      child: CategoryCard(
                        category: cat,
                        primaryColor: config?.effectivePrimaryColor,
                        onTap: () {
                          // Could navigate to category products
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Products',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<ProductsProvider>(
            builder: (context, prodProvider, _) {
              if (prodProvider.isLoading) {
                return const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final products = prodProvider.featuredProducts.isNotEmpty
                  ? prodProvider.featuredProducts
                  : prodProvider.products.take(6).toList();
              if (products.isEmpty) {
                return Text(
                  'No products yet.',
                  style: GoogleFonts.inter(color: Colors.grey),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                          ? 3
                          : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
              );
            },
          ),
        ],
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
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Our Customers Say',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, i) {
                final t = testimonials[i];
                return SizedBox(
                  width: 300,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.rating != null)
                            Row(
                              children: List.generate(
                                5,
                                (j) => Icon(
                                  j < t.rating! ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              t.content,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '— ${t.authorName}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
