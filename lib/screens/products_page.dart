import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_container.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_card.dart';

/// Products page content - used inside SiteLayout
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? _selectedCategoryId;
  double _minPrice = 0;
  double _maxPrice = 100000;

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
    final config = shopProvider.siteConfig;

    return Consumer2<ProductsProvider, CategoriesProvider>(
      builder: (context, prodProvider, catProvider, _) {
        if (prodProvider.isLoading) {
          return const LoadingView(message: 'Loading products...');
        }

        final products = _selectedCategoryId == null
            ? prodProvider.products
            : prodProvider.products
                .where((p) => p.categoryId == _selectedCategoryId)
                .toList();

        return ConstrainedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width >=
                    AppLayout.tabletBreakpoint)
                  _FiltersSection(
                    categories: catProvider.categories,
                    selectedCategoryId: _selectedCategoryId,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                    onCategorySelected: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                    onPriceChanged: (min, max) {
                      setState(() {
                        _minPrice = min;
                        _maxPrice = max;
                      });
                    },
                  ),
                if (MediaQuery.of(context).size.width >=
                    AppLayout.tabletBreakpoint)
                  const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Products',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (products.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(64),
                          child: Center(
                            child: Text(
                              'No products yet.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                AppLayout.productGridColumns(
                              constraints.maxWidth,
                            );
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 32,
                                mainAxisSpacing: 32,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final product = products[i];
                                final productId =
                                    product.id ?? '${product.name.hashCode}';
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
              ],
            ),
        );
      },
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({
    required this.categories,
    required this.selectedCategoryId,
    required this.minPrice,
    required this.maxPrice,
    required this.onCategorySelected,
    required this.onPriceChanged,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final double minPrice;
  final double maxPrice;
  final void Function(String?) onCategorySelected;
  final void Function(double, double) onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Categories',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => onCategorySelected(null),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(
                    selectedCategoryId == null
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: selectedCategoryId == null
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: selectedCategoryId == null
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final cat in categories)
            GestureDetector(
              onTap: () => onCategorySelected(cat.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      selectedCategoryId == cat.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18,
                      color: selectedCategoryId == cat.id
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: selectedCategoryId == cat.id
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 40),
          Text(
            'Price Range',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '₹${minPrice.toStringAsFixed(0)} - ₹${maxPrice.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayColor: Colors.transparent,
              thumbColor: const Color(0xFF1A1A2E),
              activeTrackColor: const Color(0xFF1A1A2E),
              inactiveTrackColor: Colors.grey.shade300,
            ),
            child: RangeSlider(
              values: RangeValues(minPrice, maxPrice),
              min: 0,
              max: 100000,
              divisions: 100,
              onChanged: (values) {
                onPriceChanged(values.start, values.end);
              },
            ),
          ),
        ],
      ),
    );
  }
}
