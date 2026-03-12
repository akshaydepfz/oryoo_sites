import 'package:flutter/foundation.dart';

import '../api/pages_api.dart';
import '../api/shop_api.dart';
import '../api/site_config_api.dart';
import '../models/shop.dart';
import '../models/site_config.dart';
import '../models/testimonial.dart';
import '../utils/domain_utils.dart';

class ShopProvider with ChangeNotifier {
  ShopProvider();

  String? _shopId;
  Shop? _shop;
  SiteConfig? _siteConfig;
  AboutPageData? _aboutPage;
  ContactPageData? _contactPage;
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? get shopId => _shopId;
  Shop? get shop => _shop;
  SiteConfig? get siteConfig => _siteConfig;
  AboutPageData? get aboutPage => _aboutPage;
  ContactPageData? get contactPage => _contactPage;
  List<Testimonial> get testimonials => _testimonials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isShopResolved => _shopId != null && _shopId!.isNotEmpty;

  /// Initialize: detect domain, resolve shop, load site data.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final domain = getCurrentDomain();
      if (domain.isEmpty) {
        _errorMessage = 'Could not detect domain. Run on web.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await resolveShopByDomain(domain);
      if (!response.found || response.shopId.isEmpty) {
        _errorMessage = 'Shop not found for domain: $domain';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _shopId = response.shopId;
      _shop = response.shop;

      notifyListeners();

      await Future.wait([
        _loadSiteConfig(),
        _loadAboutPage(),
        _loadContactPage(),
        _loadTestimonials(),
      ]);
    } catch (e, st) {
      _errorMessage = e.toString();
      debugPrint('ShopProvider.initialize error: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSiteConfig() async {
    if (_shopId == null) return;
    _siteConfig = await fetchSiteConfig(_shopId!);
    notifyListeners();
  }

  Future<void> _loadAboutPage() async {
    if (_shopId == null) return;
    _aboutPage = await fetchAboutPage(_shopId!);
    notifyListeners();
  }

  Future<void> _loadContactPage() async {
    if (_shopId == null) return;
    _contactPage = await fetchContactPage(_shopId!);
    notifyListeners();
  }

  Future<void> _loadTestimonials() async {
    if (_shopId == null) return;
    _testimonials = await fetchTestimonials(_shopId!);
    notifyListeners();
  }
}
