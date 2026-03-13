import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/categories_provider.dart';
import 'providers/products_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/about_page.dart';
import 'screens/contact_page.dart';
import 'screens/home_page.dart';
import 'models/product.dart';
import 'screens/product_details_page.dart';
import 'screens/products_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OryooSitesApp());
}

class OryooSitesApp extends StatelessWidget {
  const OryooSitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
      ],
      child: MaterialApp(
        title: 'Oryoo Sites',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A1A2E),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/products': (context) => const ProductsPage(),
          '/about': (context) => const AboutPage(),
          '/contact': (context) => const ContactPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product' && settings.arguments != null) {
            return MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: settings.arguments! as Product,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
