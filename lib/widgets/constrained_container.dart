import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Wraps content in a max-width container (1200px) centered on desktop
class ConstrainedContainer extends StatelessWidget {
  const ConstrainedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
