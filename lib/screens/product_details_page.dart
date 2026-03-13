import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_container.dart';
import '../widgets/site_footer.dart';
import '../widgets/site_header.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _selectedImageIndex = 0;

  List<String> get _allImages {
    final product = widget.product;
    final list = <String>[];
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      list.add(product.imageUrl!);
    }
    if (product.images != null) {
      for (final url in product.images!) {
        if (url.isNotEmpty && !list.contains(url)) {
          list.add(url);
        }
      }
    }
    if (list.isEmpty && product.displayImage.isNotEmpty) {
      list.add(product.displayImage);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ShopProvider>().siteConfig;
    final shopName = context.watch<ShopProvider>().shop?.name ??
        config?.shopName ??
        'Store';
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final whatsapp = config?.whatsappNumber ?? config?.phone ?? '';
    final images = _allImages;
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SiteHeader(
        shopName: shopName,
        siteConfig: config,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _ImagesSection(
                            images: images,
                            selectedIndex: _selectedImageIndex,
                            onImageSelected: (i) {
                              setState(() => _selectedImageIndex = i);
                            },
                          ),
                        ),
                        const SizedBox(width: 64),
                        Expanded(
                          flex: 1,
                          child: _ProductInfoSection(
                            product: widget.product,
                            primary: primary,
                            whatsapp: whatsapp,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ImagesSection(
                          images: images,
                          selectedIndex: _selectedImageIndex,
                          onImageSelected: (i) {
                            setState(() => _selectedImageIndex = i);
                          },
                        ),
                        const SizedBox(height: 32),
                        _ProductInfoSection(
                          product: widget.product,
                          primary: primary,
                          whatsapp: whatsapp,
                        ),
                      ],
                    ),
            ),
            SiteFooter(shopName: shopName, siteConfig: config),
          ],
        ),
      ),
    );
  }
}

class _ImagesSection extends StatelessWidget {
  const _ImagesSection({
    required this.images,
    required this.selectedIndex,
    required this.onImageSelected,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onImageSelected;

  @override
  Widget build(BuildContext context) {
    final mainImage =
        images.isNotEmpty ? images[selectedIndex.clamp(0, images.length - 1)] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: mainImage.isEmpty
                ? Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey.shade400,
                  )
                : Image.network(
                    mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onImageSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({
    required this.product,
    required this.primary,
    required this.whatsapp,
  });

  final Product product;
  final Color primary;
  final String whatsapp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '₹${product.price.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 32),
        if (product.description.isNotEmpty) ...[
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.7,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 40),
        ],
        if (whatsapp.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openWhatsApp(whatsapp, product),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Contact on WhatsApp',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openWhatsApp(String number, Product product) async {
    final clean = number.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent('Hi, I am interested in ${product.name} (₹${product.price.toStringAsFixed(0)})')}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
