import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StickyGroupHeader extends StatelessWidget {
  final String letter;
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
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: AppTheme.background.withValues(alpha: 0.95),
            blurRadius: 10,
            spreadRadius: 4,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border(
          left: BorderSide(color: AppTheme.primary, width: 3),
          bottom: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: AppTheme.accent,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}
