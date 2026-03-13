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

  static String _str(dynamic v) => v?.toString() ?? '';

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      shopName: _str(json['shop_name']).isEmpty ? _str(json['name']) : _str(json['shop_name']),
      tagline: _str(json['tagline']),
      primaryColor: _parseColor(json['primary_color']),
      secondaryColor: _parseColor(json['secondary_color']),
      heroImageUrl: _str(json['hero_image_url']).isEmpty ? _str(json['hero_image']) : _str(json['hero_image_url']),
      heroTitle: _str(json['hero_title']),
      heroSubtitle: _str(json['hero_subtitle']),
      logoUrl: _str(json['logo_url']).isEmpty ? _str(json['logo']) : _str(json['logo_url']),
      whatsappNumber: _str(json['whatsapp_number']).isEmpty ? _str(json['whatsapp']) : _str(json['whatsapp_number']),
      phone: _str(json['phone']).isEmpty ? _str(json['phone_number']) : _str(json['phone']),
      email: _str(json['email']),
      address: _str(json['address']),
      facebookUrl: _str(json['facebook_url']).isEmpty ? _str(json['facebook']) : _str(json['facebook_url']),
      instagramUrl: _str(json['instagram_url']).isEmpty ? _str(json['instagram']) : _str(json['instagram_url']),
      twitterUrl: _str(json['twitter_url']).isEmpty ? _str(json['twitter']) : _str(json['twitter_url']),
    );
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is num) return Color(value.toInt());
    final str = _str(value);
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
    final heroImg = SiteConfig._str(json['hero_image_url']).isEmpty ? SiteConfig._str(json['hero_image']) : SiteConfig._str(json['hero_image_url']);
    final story = SiteConfig._str(json['story_text']).isEmpty
        ? (SiteConfig._str(json['story']).isEmpty ? SiteConfig._str(json['content']) : SiteConfig._str(json['story']))
        : SiteConfig._str(json['story_text']);
    final craftText = SiteConfig._str(json['craftsmanship_text']).isEmpty ? SiteConfig._str(json['craftsmanship']) : SiteConfig._str(json['craftsmanship_text']);
    final craftImg = SiteConfig._str(json['craftsmanship_image_url']).isEmpty ? SiteConfig._str(json['craftsmanship_image']) : SiteConfig._str(json['craftsmanship_image_url']);
    return AboutPageData(
      heroImageUrl: heroImg.isEmpty ? null : heroImg,
      title: SiteConfig._str(json['title']).isEmpty ? null : SiteConfig._str(json['title']),
      storyText: story.isEmpty ? null : story,
      craftsmanshipTitle: SiteConfig._str(json['craftsmanship_title']).isEmpty ? null : SiteConfig._str(json['craftsmanship_title']),
      craftsmanshipText: craftText.isEmpty ? null : craftText,
      craftsmanshipImageUrl: craftImg.isEmpty ? null : craftImg,
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
    final mapEmbed = SiteConfig._str(json['map_embed_url']).isEmpty ? SiteConfig._str(json['google_map']) : SiteConfig._str(json['map_embed_url']);
    final hours = SiteConfig._str(json['store_hours']).isEmpty ? SiteConfig._str(json['hours']) : SiteConfig._str(json['store_hours']);
    return ContactPageData(
      address: SiteConfig._str(json['address']).isEmpty ? null : SiteConfig._str(json['address']),
      phone: SiteConfig._str(json['phone']).isEmpty ? null : SiteConfig._str(json['phone']),
      email: SiteConfig._str(json['email']).isEmpty ? null : SiteConfig._str(json['email']),
      mapEmbedUrl: mapEmbed.isEmpty ? null : mapEmbed,
      mapUrl: SiteConfig._str(json['map_url']).isEmpty ? null : SiteConfig._str(json['map_url']),
      storeHours: hours.isEmpty ? null : hours,
      latitude: double.tryParse(SiteConfig._str(json['latitude'])),
      longitude: double.tryParse(SiteConfig._str(json['longitude'])),
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
