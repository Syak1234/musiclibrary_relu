import 'package:flutter/material.dart';

class MusicErrorWidget extends StatelessWidget {
  final FlutterErrorDetails d;
  const MusicErrorWidget(this.d, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.music_off_rounded,
                    size: 54,
                    color: Color(0xFFFF6B6B),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '404',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track Not Found',
                style: TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The music you\'re looking for doesn\'t exist.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0B0C8), fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF1A1A2E),
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(
              //       color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
              //     ),
              //   ),
              //   child: Text(
              //     d.exceptionAsString(),
              //     textAlign: TextAlign.center,
              //     maxLines: 3,
              //     overflow: TextOverflow.ellipsis,
              //     style: const TextStyle(
              //       color: Color(0xFFB0B0C8),
              //       fontSize: 11,
              //       fontFamily: 'monospace',
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
