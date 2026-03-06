import 'dart:ui';
import 'package:flutter/material.dart';

class StickyGroupHeader extends StatelessWidget {
  final String letter;
  static const double height = 48.0;

  const StickyGroupHeader({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          color: Colors.black.withValues(alpha: 0.6),
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
