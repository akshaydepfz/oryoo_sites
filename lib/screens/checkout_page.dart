import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/orders_api.dart';
import '../api/payment_config_api.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/shop_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/constrained_container.dart';
import '../widgets/order_form.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cod;
  bool _submitting = false;
  PaymentConfig? _paymentConfig;
  bool _loadingPaymentConfig = false;
  Razorpay? _razorpay;
  OrderResponse? _pendingOrder;

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

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

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty || _submitting) return;
    if (!_formKey.currentState!.validate()) return;

    final shopId = context.read<ShopProvider>().shopId;
    if (shopId == null || shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place order. Shop not loaded.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final itemsPayload = cart.items
        .map<Map<String, dynamic>>(
          (CartItem item) => {
            'product_id': item.product.id ?? '',
            'quantity': item.quantity,
            if (item.variant != null && item.variant!.id.isNotEmpty)
              'variant_id': item.variant!.id,
          },
        )
        .toList();

    final paymentMethodString =
        _paymentMethod == PaymentMethod.cod ? 'COD' : 'ONLINE';

    try {
      final order = await createOrderWithItems(
        shopId: shopId,
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        items: itemsPayload,
        paymentMethod: paymentMethodString,
      );

      if (!mounted) return;

      final paymentEnabled = _paymentConfig?.paymentEnabled == true &&
          _paymentConfig?.razorpayKey != null;

      if (_paymentMethod == PaymentMethod.cod || !paymentEnabled) {
        cart.clearCart();
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
          'description': 'Order from cart',
          'order_id': order.razorpayOrderId ?? order.id,
          'prefill': {
            'contact': _phoneController.text.trim(),
            'name': _nameController.text.trim(),
          },
        };
        _razorpay?.open(options);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final order = _pendingOrder;
    if (order == null) return;
    _pendingOrder = null;
    final cart = context.read<CartProvider>();
    cart.clearCart();
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
    final cart = context.watch<CartProvider>();
    final isDesktop =
        MediaQuery.of(context).size.width >= AppLayout.desktopBreakpoint;

    if (cart.isEmpty) {
      return ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your cart is empty',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add items to your cart before checking out.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.products),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(
                  'Browse products',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final paymentEnabled = _paymentConfig?.paymentEnabled == true &&
        _paymentConfig?.razorpayKey != null;

    return ConstrainedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your shipping details and confirm your order.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 32),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildAddressForm(paymentEnabled),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: _CheckoutSummary(cart: cart),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddressForm(paymentEnabled),
                    const SizedBox(height: 24),
                    _CheckoutSummary(cart: cart),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(bool paymentEnabled) {
    final titleStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A2E),
      letterSpacing: 0.5,
    );

    final labelStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade800,
    );

    final isWide = MediaQuery.of(context).size.width >= 640;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Shipping address', style: titleStyle),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full name',
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 8) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Address',
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          if (isWide)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pincode',
                      labelStyle: labelStyle,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter pincode';
                      }
                      if (value.trim().length < 4) {
                        return 'Enter valid pincode';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            )
          else ...[
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter city';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pincode',
                labelStyle: labelStyle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter pincode';
                }
                if (value.trim().length < 4) {
                  return 'Enter valid pincode';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          Text('Payment method', style: titleStyle),
          const SizedBox(height: 8),
          if (paymentEnabled)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PaymentChip(
                  label: 'Cash on Delivery',
                  selected: _paymentMethod == PaymentMethod.cod,
                  onTap: () {
                    setState(() {
                      _paymentMethod = PaymentMethod.cod;
                    });
                  },
                ),
                _PaymentChip(
                  label: 'Pay Online',
                  selected: _paymentMethod == PaymentMethod.online,
                  onTap: () {
                    setState(() {
                      _paymentMethod = PaymentMethod.online;
                    });
                  },
                ),
              ],
            )
          else
            Text(
              'Cash on Delivery',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _placeOrder,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1A1A2E),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Place order',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order summary',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          if (item.variant != null)
                            Text(
                              item.variant!.name,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items total',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '₹${cart.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Calculated at delivery',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total payable',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '₹${cart.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}

