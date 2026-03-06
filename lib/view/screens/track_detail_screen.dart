import '../../data/models/track_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/detail/track_detail_bloc.dart';
import '../../viewmodel/detail/track_detail_event.dart';
import '../../viewmodel/detail/track_detail_state.dart';
import '../../data/models/track.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/no_internet_banner.dart';

class TrackDetailScreen extends StatelessWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TrackDetailBloc(repository: ServiceLocator().musicRepository)
            ..add(LoadTrackDetail(track)),
      child: _TrackDetailBody(track: track),
    );
  }
}

class _TrackDetailBody extends StatelessWidget {
  final Track track;

  const _TrackDetailBody({required this.track});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<TrackDetailBloc, TrackDetailState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(child: _buildContent(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppTheme.background,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: track.albumCoverBig,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppTheme.card),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.card,
                child: Icon(
                  Icons.album,
                  size: 80,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.background.withOpacity(0.7),
                    AppTheme.background,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.titleShort,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.artistName,
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrackDetailState state) {
    if (state.status == DetailStatus.loading) {
      return Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (state.status == DetailStatus.error) {
      if (state.errorMessage == AppStrings.noInternetConnection) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: NoInternetBanner(
            onRetry: () =>
                context.read<TrackDetailBloc>().add(LoadTrackDetail(track)),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 12),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<TrackDetailBloc>().add(
                  LoadTrackDetail(track),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    final detail = state.detail;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _infoSection(context, detail),
          const SizedBox(height: 32),
          _lyricsSection(context, state.lyrics),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _infoSection(BuildContext context, TrackDetail? detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('Album', detail?.albumTitle ?? track.albumTitle),
          _divider(),
          _infoRow(
            'Duration',
            detail?.durationFormatted ?? track.durationFormatted,
          ),
          if (detail != null) ...[
            _divider(),
            _infoRow('Track #', '${detail.trackPosition}'),
            if (detail.releaseDate.isNotEmpty) ...[
              _divider(),
              _infoRow('Released', detail.releaseDate),
            ],
            if (detail.bpm > 0) ...[
              _divider(),
              _infoRow('BPM', '${detail.bpm.toInt()}'),
            ],
          ],
          _divider(),
          _infoRow('Track ID', '${track.id}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final displayValue = value.isEmpty ? 'Unknown' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: AppTheme.textSecondary.withOpacity(0.1), height: 1);
  }

  Widget _lyricsSection(BuildContext context, String lyrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lyrics_rounded, color: AppTheme.accent, size: 22),
            const SizedBox(width: 10),
            Text('Lyrics', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.05)),
          ),
          child: Text(
            lyrics,
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.9),
              fontSize: 15,
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
