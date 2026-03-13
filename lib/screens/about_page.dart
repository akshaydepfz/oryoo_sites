import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/testimonial.dart';
import '../router/app_router.dart';
import '../providers/shop_provider.dart';
import '../widgets/constrained_container.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final about = shopProvider.aboutPage;
    final testimonials = shopProvider.testimonials;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroSection(
          imageUrl: about?.heroImageUrl,
          title: about?.title ?? 'Our Story',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: ConstrainedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (about?.storyText != null && about!.storyText!.isNotEmpty)
                  Text(
                    about.storyText!,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      height: 1.9,
                      color: Colors.grey.shade700,
                    ),
                  ),
                if (about?.storyText == null || about!.storyText!.isEmpty)
                  Text(
                    'We believe in creating products that tell a story—each piece crafted with care, passion, and an unwavering commitment to quality. From our humble beginnings to where we stand today, our journey has been shaped by the people we serve and the values we hold dear.',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      height: 1.9,
                      color: Colors.grey.shade700,
                    ),
                  ),
                if (about?.craftsmanshipTitle != null ||
                    (about?.craftsmanshipText != null &&
                        about!.craftsmanshipText!.isNotEmpty)) ...[
                  const SizedBox(height: 56),
                  if (about?.craftsmanshipTitle != null)
                    Text(
                      about!.craftsmanshipTitle!,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  if (about?.craftsmanshipText != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      about!.craftsmanshipText!,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        height: 1.9,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  if (about?.craftsmanshipImageUrl != null) ...[
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        about!.craftsmanshipImageUrl!,
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const _ValuesSection(),
        if (testimonials.isNotEmpty)
          _TestimonialsSection(testimonials: testimonials),
        const _StatsSection(),
        const _CtaSection(),
      ],
    );
  }
}

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  static const _values = [
    (
      icon: Icons.verified_user_outlined,
      title: 'Quality First',
      desc: 'Every product meets our highest standards before it reaches you.',
    ),
    (
      icon: Icons.handshake_outlined,
      title: 'Customer Focus',
      desc:
          'Your satisfaction drives everything we do. We listen, adapt, and deliver.',
    ),
    (
      icon: Icons.eco_outlined,
      title: 'Sustainable Practices',
      desc:
          'We care about our planet and strive to make responsible choices in our craft.',
    ),
    (
      icon: Icons.diversity_3_outlined,
      title: 'Community',
      desc:
          'We build lasting relationships with artisans, partners, and customers alike.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Values',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The principles that guide everything we create',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 900
                    ? 4
                    : (constraints.maxWidth > 600 ? 2 : 1);
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: _values.map((v) {
                    final width =
                        (constraints.maxWidth - 24 * (crossCount - 1)) /
                        crossCount;
                    return SizedBox(
                      width: width,
                      child: _ValueCard(
                        icon: v.icon,
                        title: v.title,
                        description: v.desc,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1A1A2E), size: 32),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection({required this.testimonials});

  final List<Testimonial> testimonials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What Our Customers Say',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Real stories from people who trust us',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 800 ? 2 : 1;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: testimonials
                      .map(
                        (t) => SizedBox(
                          width: crossCount == 2
                              ? (constraints.maxWidth - 24) / 2
                              : constraints.maxWidth,
                          child: _TestimonialCard(testimonial: t),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.testimonial});

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) {
    final authorName = testimonial.authorName.isNotEmpty
        ? testimonial.authorName
        : 'Customer';
    final content = testimonial.content;
    final authorTitle = testimonial.authorTitle;
    final rating = testimonial.rating;
    final avatarUrl = testimonial.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rating != null && rating > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFE94560),
                    size: 20,
                  ),
                ),
              ),
            ),
          Text(
            '"$content"',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (avatarUrl != null && avatarUrl.isNotEmpty)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl),
                  onBackgroundImageError: (_, __) {},
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1A1A2E),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    if (authorTitle != null && authorTitle.isNotEmpty)
                      Text(
                        authorTitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  static const _stats = [
    (value: '10+', label: 'Years of Excellence'),
    (value: '50K+', label: 'Happy Customers'),
    (value: '100%', label: 'Quality Assured'),
    (value: '24/7', label: 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 48),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _stats
              .map(
                (s) => Column(
                  children: [
                    Text(
                      s.value,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: ConstrainedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Text(
              'Ready to experience the difference?',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'d love to hear from you. Whether you have a question, feedback, or just want to say hello—reach out and let\'s connect.',
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => context.go(AppRoutes.contact),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Get in Touch'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A2E),
                    side: const BorderSide(color: Color(0xFF1A1A2E)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Explore Our Collection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({this.imageUrl, this.title});

  final String? imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(48),
        child: Text(
          title ?? 'About Us',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
