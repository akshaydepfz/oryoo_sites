import 'package:flutter/material.dart' show Color;

import '../utils/json_utils.dart';

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
      shopName: safeStr(json['shop_name']).isEmpty ? safeStr(json['name']) : safeStr(json['shop_name']),
      tagline: safeStr(json['tagline']),
      primaryColor: _parseColor(json['primary_color']),
      secondaryColor: _parseColor(json['secondary_color']),
      heroImageUrl: safeStr(json['hero_image_url']).isEmpty ? safeStr(json['hero_image']) : safeStr(json['hero_image_url']),
      heroTitle: safeStr(json['hero_title']),
      heroSubtitle: safeStr(json['hero_subtitle']),
      logoUrl: safeStr(json['logo_url']).isEmpty ? safeStr(json['logo']) : safeStr(json['logo_url']),
      whatsappNumber: safeStr(json['whatsapp_number']).isEmpty ? safeStr(json['whatsapp']) : safeStr(json['whatsapp_number']),
      phone: safeStr(json['phone']).isEmpty ? safeStr(json['phone_number']) : safeStr(json['phone']),
      email: safeStr(json['email']),
      address: safeStr(json['address']),
      facebookUrl: safeStr(json['facebook_url']).isEmpty ? safeStr(json['facebook']) : safeStr(json['facebook_url']),
      instagramUrl: safeStr(json['instagram_url']).isEmpty ? safeStr(json['instagram']) : safeStr(json['instagram_url']),
      twitterUrl: safeStr(json['twitter_url']).isEmpty ? safeStr(json['twitter']) : safeStr(json['twitter_url']),
    );
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is num) return Color(value.toInt());
    final str = safeStr(value);
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
    final heroImg = safeStr(json['hero_image_url']).isEmpty ? safeStr(json['hero_image']) : safeStr(json['hero_image_url']);
    final story = safeStr(json['story_text']).isEmpty
        ? (safeStr(json['story']).isEmpty ? safeStr(json['content']) : safeStr(json['story']))
        : safeStr(json['story_text']);
    final craftText = safeStr(json['craftsmanship_text']).isEmpty ? safeStr(json['craftsmanship']) : safeStr(json['craftsmanship_text']);
    final craftImg = safeStr(json['craftsmanship_image_url']).isEmpty ? safeStr(json['craftsmanship_image']) : safeStr(json['craftsmanship_image_url']);
    return AboutPageData(
      heroImageUrl: heroImg.isEmpty ? null : heroImg,
      title: safeStrOrNull(json['title']),
      storyText: story.isEmpty ? null : story,
      craftsmanshipTitle: safeStrOrNull(json['craftsmanship_title']),
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
    final mapEmbed = safeStr(json['map_embed_url']).isEmpty ? safeStr(json['google_map']) : safeStr(json['map_embed_url']);
    final address = safeStr(json['address']).isEmpty ? safeStr(json['store_address']) : safeStr(json['address']);
    final phone = safeStr(json['phone']).isEmpty ? safeStr(json['phone_number']) : safeStr(json['phone']);
    final hours = json['store_hours'];
    final hoursStr = hours is Map ? safeStr(hours) : safeStr(hours);
    return ContactPageData(
      address: address.isEmpty ? null : address,
      phone: phone.isEmpty ? null : phone,
      email: safeStrOrNull(json['email']),
      mapEmbedUrl: mapEmbed.isEmpty ? null : mapEmbed,
      mapUrl: safeStrOrNull(json['map_url']),
      storeHours: hoursStr.isEmpty ? null : hoursStr,
      latitude: double.tryParse(safeStr(json['latitude'])),
      longitude: double.tryParse(safeStr(json['longitude'])),
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
