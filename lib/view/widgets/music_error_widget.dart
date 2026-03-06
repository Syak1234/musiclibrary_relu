import 'package:flutter/material.dart';
import 'package:musiclibrary_relu/core/theme/app_theme.dart';

class MusicErrorWidget extends StatelessWidget {
  final FlutterErrorDetails d;
  const MusicErrorWidget(this.d, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppTheme.errorRed.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(height: 40),
                Text(
                  'SYSTEM PAUSE',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unexpected Error',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The application encountered a technical issue and needs to skip this beat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary.withValues(alpha: 0.5),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                const SizedBox(height: 40),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorRed.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.errorRed.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.priority_high_rounded,
            color: AppTheme.errorRed,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Try Again',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: Text(
            'Report Issue',
            style: TextStyle(
              color: AppTheme.textPrimary.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
