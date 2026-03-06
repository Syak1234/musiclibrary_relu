import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StickyGroupHeader extends StatelessWidget {
  final String letter;

  /// Fixed height used both by the widget and the SliverPersistentHeaderDelegate.
  static const double height = 38.0;

  const StickyGroupHeader({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.97),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: AppTheme.accent,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
