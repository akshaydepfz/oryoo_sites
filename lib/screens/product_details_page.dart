import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/orders_api.dart';
import '../api/payment_config_api.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../providers/shop_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_container.dart';
import '../widgets/order_form.dart';

/// Product details content - used inside SiteLayout
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
  ProductVariant? _selectedVariant;
  PaymentConfig? _paymentConfig;
  bool _loadingPaymentConfig = false;
  Razorpay? _razorpay;
  OrderResponse? _pendingOrder;

  @override
  void initState() {
    super.initState();
    _selectedVariant =
        widget.product.variants.isNotEmpty ? widget.product.variants.first : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentConfig();
    });
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

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

  double get _effectivePrice =>
      _selectedVariant?.price ?? widget.product.price;

  Future<void> _loadPaymentConfig() async {
    if (_loadingPaymentConfig) return;
    final shopId = context.read<ShopProvider>().shopId;
    if (shopId == null || shopId.isEmpty) return;
    setState(() {
      _loadingPaymentConfig = true;
    });
    try {
      final config = await fetchPaymentConfig(shopId);
      if (mounted) {
        setState(() {
          _paymentConfig = config;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _paymentConfig = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPaymentConfig = false;
        });
      }
    }
  }

  Future<void> _openOrderForm() async {
    final shopId = context.read<ShopProvider>().shopId;
    if (shopId == null || shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place order. Shop not loaded.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: OrderForm(
            product: widget.product,
            selectedVariant: _selectedVariant,
            price: _effectivePrice,
            paymentEnabled: _paymentConfig?.paymentEnabled == true,
            onSubmit: (result) async {
              final paymentMethod = result.paymentMethod == PaymentMethod.cod
                  ? 'COD'
                  : 'ONLINE';

              final order = await createOrder(
                shopId: shopId,
                customerName: result.customerName,
                phone: result.phone,
                address: result.address,
                city: result.city,
                pincode: result.pincode,
                productId: widget.product.id ?? '',
                variantId: _selectedVariant?.id,
                quantity: 1,
                paymentMethod: paymentMethod,
              );

              if (!mounted) return;

              if (result.paymentMethod == PaymentMethod.cod ||
                  _paymentConfig?.paymentEnabled != true ||
                  _paymentConfig?.razorpayKey == null) {
                Navigator.of(context).pop();
                final orderId = Uri.encodeComponent(order.id);
                final amount =
                    Uri.encodeComponent(order.amount.toStringAsFixed(0));
                context.go(
                  '${AppRoutes.orderSuccess}?orderId=$orderId&amount=$amount',
                );
              } else {
                _pendingOrder = order;
                final key = _paymentConfig!.razorpayKey!;
                final options = {
                  'key': key,
                  'amount': (order.amount * 100).round(),
                  'currency': order.currency ?? 'INR',
                  'name': context.read<ShopProvider>().siteConfig?.shopName ??
                      'Store',
                  'description': widget.product.name,
                  'order_id': order.razorpayOrderId ?? order.id,
                  'prefill': {
                    'contact': result.phone,
                    'name': result.customerName,
                  },
                };
                Navigator.of(context).pop();
                _razorpay?.open(options);
              }
            },
          ),
        );
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final order = _pendingOrder;
    if (order == null) return;
    _pendingOrder = null;
    if (!mounted) return;
    final orderId = Uri.encodeComponent(order.id);
    final amount = Uri.encodeComponent(order.amount.toStringAsFixed(0));
    context.go(
      '${AppRoutes.orderSuccess}?orderId=$orderId&amount=$amount',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _pendingOrder = null;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment failed. Please try again or choose COD.'),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ShopProvider>().siteConfig;
    final primary = config?.effectivePrimaryColor ?? const Color(0xFF1A1A2E);
    final whatsapp = config?.whatsappNumber ?? config?.phone ?? '';
    final images = _allImages;
    final isWide =
        MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    return ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
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
                  const SizedBox(width: 80),
                  Expanded(
                    flex: 1,
                    child: _ProductInfoSection(
                      product: widget.product,
                      primary: primary,
                      whatsapp: whatsapp,
                      variants: widget.product.variants,
                      selectedVariant: _selectedVariant,
                      onVariantSelected: (v) {
                        setState(() {
                          _selectedVariant = v;
                        });
                      },
                      price: _effectivePrice,
                      onBuyNow: _openOrderForm,
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
                  const SizedBox(height: 40),
                  _ProductInfoSection(
                    product: widget.product,
                    primary: primary,
                    whatsapp: whatsapp,
                    variants: widget.product.variants,
                    selectedVariant: _selectedVariant,
                    onVariantSelected: (v) {
                      setState(() {
                        _selectedVariant = v;
                      });
                    },
                    price: _effectivePrice,
                    onBuyNow: _openOrderForm,
              ),
            ],
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
              borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 20),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onImageSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 88,
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
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
    required this.price,
    required this.onBuyNow,
  });

  final Product product;
  final Color primary;
  final String whatsapp;
  final List<ProductVariant> variants;
  final ProductVariant? selectedVariant;
  final ValueChanged<ProductVariant>? onVariantSelected;
  final double price;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 40),
        if (variants.isNotEmpty) ...[
          Text(
            'Select Size',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variants.map((variant) {
              final selected = selectedVariant?.id == variant.id;
              return GestureDetector(
                onTap: () => onVariantSelected?.call(variant),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? primary : Colors.grey.shade300,
                      width: selected ? 2 : 1,
                    ),
                    color: selected ? primary.withOpacity(0.06) : Colors.white,
                  ),
                  child: Text(
                    variant.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? primary : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
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
          const SizedBox(height: 16),
          Text(
            product.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.8,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 48),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onBuyNow,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: primary,
            ),
            child: Text(
              'Buy Now',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (whatsapp.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openWhatsApp(whatsapp, product),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
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
        if (whatsapp.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openWhatsAppOrder(whatsapp, product, price),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF1A1A2E),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Order on WhatsApp',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _openWhatsAppOrder(
    String number,
    Product product,
    double price,
  ) async {
    final clean = number.replaceAll(RegExp(r'[^\d+]'), '');
    final message = 'Hi, I want to order:\n\n'
        'Product: ${product.name}\n'
        'Price: ₹${price.toStringAsFixed(0)}';
    final url = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
