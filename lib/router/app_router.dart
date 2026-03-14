import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/shop_provider.dart';
import '../screens/about_page.dart';
import '../screens/contact_page.dart';
import '../screens/home_page.dart';
import '../screens/order_success_page.dart';
import '../screens/product_details_page.dart';
import '../screens/products_page.dart';
import '../screens/cart_page.dart';
import '../screens/checkout_page.dart';
import '../widgets/site_layout.dart';

/// App routes - URL-based navigation for web-style behavior
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String products = '/products';
  static const String productDetails = '/products/:productId';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';

  static String productDetailsPath(String productId) => '/products/$productId';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return SiteLayout(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.products,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const ProductsPage(),
            ),
          ),
          GoRoute(
            path: '/products/:productId',
            pageBuilder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return _noTransitionPage(
                state,
                _ProductDetailsWrapper(productId: productId),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.about,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const AboutPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.contact,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const ContactPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.cart,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const CartPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.checkout,
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const CheckoutPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.orderSuccess,
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters;
              final orderId = query['orderId'];
              final amount = query['amount'];
              return _noTransitionPage(
                state,
                OrderSuccessPage(
                  orderId: orderId,
                  amount: amount,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// Wrapper that looks up product by ID from provider
class _ProductDetailsWrapper extends StatefulWidget {
  const _ProductDetailsWrapper({required this.productId});

  final String productId;

  @override
  State<_ProductDetailsWrapper> createState() => _ProductDetailsWrapperState();
}

class _ProductDetailsWrapperState extends State<_ProductDetailsWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>();
      if (shop.shopId != null) {
        context.read<ProductsProvider>().loadProducts(shop.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductsProvider, ShopProvider>(
      builder: (context, productsProvider, shopProvider, _) {
        final product = productsProvider.getProductById(widget.productId);

        if (product != null) {
          return ProductDetailsPage(product: product);
        }

        if (productsProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Product not found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go(AppRoutes.products),
                  child: const Text('Back to Products'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

CustomTransitionPage _noTransitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}
