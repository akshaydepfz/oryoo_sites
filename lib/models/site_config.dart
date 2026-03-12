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
      shopName: json['shop_name'] as String? ?? json['name'] as String?,
      tagline: json['tagline'] as String?,
      primaryColor: _parseColor(json['primary_color']),
      secondaryColor: _parseColor(json['secondary_color']),
      heroImageUrl: json['hero_image_url'] as String? ?? json['hero_image'] as String?,
      heroTitle: json['hero_title'] as String?,
      heroSubtitle: json['hero_subtitle'] as String?,
      logoUrl: json['logo_url'] as String? ?? json['logo'] as String?,
      whatsappNumber: json['whatsapp_number'] as String? ?? json['whatsapp'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      facebookUrl: json['facebook_url'] as String? ?? json['facebook'] as String?,
      instagramUrl: json['instagram_url'] as String? ?? json['instagram'] as String?,
      twitterUrl: json['twitter_url'] as String? ?? json['twitter'] as String?,
    );
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
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
      heroImageUrl: json['hero_image_url'] as String? ?? json['hero_image'] as String?,
      title: json['title'] as String?,
      storyText: json['story_text'] as String? ?? json['story'] as String? ?? json['content'] as String?,
      craftsmanshipTitle: json['craftsmanship_title'] as String?,
      craftsmanshipText: json['craftsmanship_text'] as String? ?? json['craftsmanship'] as String?,
      craftsmanshipImageUrl: json['craftsmanship_image_url'] as String? ?? json['craftsmanship_image'] as String?,
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
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      mapEmbedUrl: json['map_embed_url'] as String? ?? json['google_map'] as String?,
      mapUrl: json['map_url'] as String?,
      storeHours: json['store_hours'] as String? ?? json['hours'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
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
