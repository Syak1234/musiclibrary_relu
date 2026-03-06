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
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _albumArt(),
            const SizedBox(width: 14),
            Expanded(child: _trackInfo(context)),
            _duration(context),
          ],
        ),
      ),
    );
  }

  Widget _albumArt() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: track.albumCoverSmall,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.music_note,
            color: AppTheme.textSecondary,
            size: 24,
          ),
        ),
        errorWidget: (_, _, _) => Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.music_note,
            color: AppTheme.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _trackInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          track.titleShort,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 3),
        Text(
          track.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _duration(BuildContext context) {
    return Text(
      track.durationFormatted,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
