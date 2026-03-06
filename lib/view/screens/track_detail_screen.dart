import 'dart:ui';
import '../../data/models/track_detail.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/detail/track_detail_bloc.dart';
import '../../viewmodel/detail/track_detail_event.dart';
import '../../viewmodel/detail/track_detail_state.dart';
import '../../data/models/track.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodel/connection/connection_bloc.dart';
import '../../viewmodel/connection/connection_state.dart';
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
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _TrackDetailBody(track: track),
      ),
    );
  }
}

class _TrackDetailBody extends StatefulWidget {
  final Track track;

  const _TrackDetailBody({required this.track});

  @override
  State<_TrackDetailBody> createState() => _TrackDetailBodyState();
}

class _TrackDetailBodyState extends State<_TrackDetailBody> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _buildBlurredBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, size: 28),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'TRACK INFO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 22),
                tooltip: 'Share Track',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<TrackDetailBloc>().add(ShareTrack(widget.track));
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocBuilder<ConnectionBloc, ConnectionState>(
            builder: (context, connectionState) {
              if (connectionState is ConnectionDisconnected) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildIdentityHeader(context, cs),
                      const SizedBox(height: 100),
                      NoInternetBanner(
                        onRetry: () => context.read<TrackDetailBloc>().add(
                          LoadTrackDetail(widget.track),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return BlocBuilder<TrackDetailBloc, TrackDetailState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildIdentityHeader(context, cs),
                        const SizedBox(height: 40),
                        _buildMetricsSection(cs),
                        const SizedBox(height: 32),
                        _buildDetailsList(state, cs, context),
                        const SizedBox(height: 32),
                        if (state.lyrics.isNotEmpty &&
                            state.status == DetailStatus.loaded) ...[
                          _sectionHeader('LYRICS', Icons.short_text_rounded),
                          const SizedBox(height: 16),
                          _buildLyricsContent(state.lyrics),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlurredBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.track.albumCoverBig,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader(BuildContext context, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'track_${widget.track.id}',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.track.albumCoverBig,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.track.titleShort,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.track.artistName,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.track.albumTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(ColorScheme cs) {
    return Row(
      children: [
        _metricItem(
          'RANK',
          '#${(widget.track.rank / 1000).toStringAsFixed(1)}K',
          Icons.trending_up_rounded,
        ),
        _vDivider(),
        _metricItem(
          'LENGTH',
          widget.track.durationFormatted,
          Icons.timer_outlined,
        ),
        _vDivider(),
        _metricItem(
          'ID',
          widget.track.id.toString(),
          Icons.fingerprint_rounded,
        ),
      ],
    );
  }

  Widget _metricItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.white30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(height: 30, width: 1, color: Colors.white10);

  Widget _buildDetailsList(
    TrackDetailState state,
    ColorScheme cs,
    BuildContext context,
  ) {
    if (state.status == DetailStatus.loading) {
      return const Center(
        child: LinearProgressIndicator(backgroundColor: Colors.white12),
      );
    }

    final detail = state.detail;

    return Column(
      children: [
        _sectionHeader(
          'Track Details'.toUpperCase(),
          Icons.info_outline_rounded,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _infoRow(
                'ALBUM NAME',
                detail?.albumTitle ?? widget.track.albumTitle,
              ),
              _rowDivider(),
              _infoRow(
                'TEMPO',
                detail?.bpm != null && detail!.bpm > 0
                    ? '${detail.bpm.toInt()} BPM'
                    : 'NOT ANALYZED',
              ),
              _rowDivider(),
              _infoRow(
                'RELEASE DATE',
                detail?.releaseDate.isNotEmpty == true
                    ? detail!.releaseDate
                    : 'UNKNOWN',
              ),
              _rowDivider(),
              _infoRow(
                'ALBUM TRACKS',
                detail?.albumTracksCount != null
                    ? detail!.albumTracksCount.toString()
                    : 'VARIES',
              ),
              _rowDivider(),
              _infoRow(
                'LINK',
                'VIEW ON DEEZER',
                isLink: true,
                onTap: () => context.read<TrackDetailBloc>().add(
                  OpenTrackLink(widget.track.link),
                ),
              ),
              _rowDivider(),
              _infoRow(
                'PREVIEW',
                'LISTEN TO 30S CLIP',
                isLink: true,
                onTap: () => context.read<TrackDetailBloc>().add(
                  OpenTrackLink(widget.track.previewUrl),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white30),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: isLink ? Colors.blueAccent : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowDivider() =>
      Divider(color: Colors.white.withValues(alpha: 0.03), height: 1);

  Widget _buildLyricsContent(String lyrics) {
    final lines = lyrics.split('\n');
    final isLong = lines.length > 5;
    final displayLyrics = (_isExpanded || !isLong)
        ? lyrics
        : lines.take(5).join('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            displayLyrics,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.8,
              letterSpacing: 0.2,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'SHOW LESS' : 'SHOW MORE',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TrackDetailState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.white54),
            ),
            TextButton(
              onPressed: () => context.read<TrackDetailBloc>().add(
                LoadTrackDetail(widget.track),
              ),
              child: const Text('RETRY', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
