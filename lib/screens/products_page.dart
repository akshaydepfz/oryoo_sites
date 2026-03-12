import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_card.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';
import 'product_details_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        if (shopProvider.isLoading) {
          return Scaffold(
            body: LoadingView(message: 'Loading...'),
          );
        }

        if (shopProvider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(shopProvider.errorMessage!)),
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
          body: Column(
            children: [
              Expanded(
                child: Consumer<ProductsProvider>(
                  builder: (context, prodProvider, _) {
                    if (prodProvider.isLoading) {
                      return const LoadingView(message: 'Loading products...');
                    }
                    if (prodProvider.products.isEmpty) {
                      return const Center(
                        child: Text('No products yet.'),
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
                          padding: const EdgeInsets.all(24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: prodProvider.products.length,
                          itemBuilder: (context, i) {
                            final product = prodProvider.products[i];
                            return ProductCard(
                              product: product,
                              primaryColor: config?.effectivePrimaryColor,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsPage(product: product),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SiteFooter(shopName: shopName, siteConfig: config),
            ],
          ),
        );
      },
    );
  }
}
