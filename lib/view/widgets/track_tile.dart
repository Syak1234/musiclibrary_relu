import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/track.dart';
import '../../core/theme/app_theme.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;

  const TrackTile({super.key, required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            _buildArtwork(),
            const SizedBox(width: 16),
            Expanded(child: _buildInfo(context)),
            const SizedBox(width: 12),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: track.albumCoverSmall,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Colors.white.withValues(alpha: 0.05)),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.music_note, color: Colors.white10),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                track.titleShort,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          track.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Text(
      track.durationFormatted,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.2),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
