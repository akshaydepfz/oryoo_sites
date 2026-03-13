import 'package:flutter/material.dart' show Color;

class SiteConfig {
  SiteConfig({
    this.shopName,
    this.tagline,
    this.primaryColor,
    this.secondaryColor,
    this.heroImageUrl,
    this.heroTitle,
    this.heroSubtitle,
    this.logoUrl,
    this.whatsappNumber,
    this.phone,
    this.email,
    this.address,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      shopName: json['shop_name']?.toString() ?? json['name']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      primaryColor: _parseColor(json['primary_color']),
      secondaryColor: _parseColor(json['secondary_color']),
      heroImageUrl: json['hero_image_url']?.toString() ?? json['hero_image']?.toString() ?? '',
      heroTitle: json['hero_title']?.toString() ?? '',
      heroSubtitle: json['hero_subtitle']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? json['logo']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? json['whatsapp']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      facebookUrl: json['facebook_url']?.toString() ?? json['facebook']?.toString() ?? '',
      instagramUrl: json['instagram_url']?.toString() ?? json['instagram']?.toString() ?? '',
      twitterUrl: json['twitter_url']?.toString() ?? json['twitter']?.toString() ?? '',
    );
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is num) return Color(value.toInt());
    final str = value.toString();
    final hex = str.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.tryParse('FF$hex', radix: 16) ?? 0);
    }
    if (hex.length == 8) {
      return Color(int.tryParse(hex, radix: 16) ?? 0);
    }
    return null;
  }

  final String? shopName;
  final String? tagline;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? heroImageUrl;
  final String? heroTitle;
  final String? heroSubtitle;
  final String? logoUrl;
  final String? whatsappNumber;
  final String? phone;
  final String? email;
  final String? address;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;

  Color get effectivePrimaryColor => primaryColor ?? const Color(0xFF1A1A2E);
  Color get effectiveSecondaryColor => secondaryColor ?? const Color(0xFFE94560);
}

/// About page data from GET /sites/about
class AboutPageData {
  AboutPageData({
    this.heroImageUrl,
    this.title,
    this.storyText,
    this.craftsmanshipTitle,
    this.craftsmanshipText,
    this.craftsmanshipImageUrl,
  });

  factory AboutPageData.fromJson(Map<String, dynamic> json) {
    return AboutPageData(
      heroImageUrl: json['hero_image_url']?.toString() ?? json['hero_image']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      storyText: json['story_text']?.toString() ?? json['story']?.toString() ?? json['content']?.toString() ?? '',
      craftsmanshipTitle: json['craftsmanship_title']?.toString() ?? '',
      craftsmanshipText: json['craftsmanship_text']?.toString() ?? json['craftsmanship']?.toString() ?? '',
      craftsmanshipImageUrl: json['craftsmanship_image_url']?.toString() ?? json['craftsmanship_image']?.toString() ?? '',
    );
  }

  final String? heroImageUrl;
  final String? title;
  final String? storyText;
  final String? craftsmanshipTitle;
  final String? craftsmanshipText;
  final String? craftsmanshipImageUrl;
}

/// Contact page data from GET /sites/contact
class ContactPageData {
  ContactPageData({
    this.address,
    this.phone,
    this.email,
    this.mapEmbedUrl,
    this.mapUrl,
    this.storeHours,
    this.latitude,
    this.longitude,
  });

  factory ContactPageData.fromJson(Map<String, dynamic> json) {
    return ContactPageData(
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mapEmbedUrl: json['map_embed_url']?.toString() ?? json['google_map']?.toString() ?? '',
      mapUrl: json['map_url']?.toString() ?? '',
      storeHours: json['store_hours']?.toString() ?? json['hours']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }

  final String? address;
  final String? phone;
  final String? email;
  final String? mapEmbedUrl;
  final String? mapUrl;
  final String? storeHours;
  final double? latitude;
  final double? longitude;
}
