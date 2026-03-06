import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import '../../viewmodel/library/library_bloc.dart';
import '../../viewmodel/library/library_event.dart';
import '../../viewmodel/library/library_state.dart';
import '../../data/models/track.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/track_tile.dart';
import '../widgets/sticky_group_header.dart';
import '../widgets/no_internet_banner.dart';
import 'track_detail_screen.dart';

enum GroupBy { title, artist }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  final _letter = ValueNotifier('');
  var _by = GroupBy.title;
  final _lim = 50;
  bool _st = false;
  int? _cl;
  GroupBy? _cb;
  List<Track>? _cs;
  final _glet = <String>[];
  final _goff = <double>[];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    context.read<LibraryBloc>().add(LoadNextPage(limit: _lim));
  }

  void _onScroll() {
    if (_st || !mounted || !_scroll.hasClients) return;

    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 800) {
      _st = true;
      context.read<LibraryBloc>().add(LoadNextPage(limit: _lim));
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _st = false;
      });
    }

    if (_glet.isEmpty) return;
    final px = _scroll.position.pixels;

    if (_goff.isEmpty || _glet.length != _goff.length) return;

    var l = _glet.first;
    if (px <= 0) {
      l = '';
    } else {
      for (int i = 0; i < _goff.length; i++) {
        if (_goff[i] <= px) {
          l = _glet[i];
        } else {
          break;
        }
      }
    }

    if (_letter.value != l) {
      _letter.value = l;
    }
  }

  void _open(Track t) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => TrackDetailScreen(track: t)));

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    _letter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Elegant Corner Glow (Pushed back to avoid search overlap)
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ctx),
                _buildSearchBar(ctx),
                _buildFilterTabs(),
                Expanded(child: _buildListBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(26, 24, 26, 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'EXPLICIT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        _itemCount(),
      ],
    ),
  );

  Widget _itemCount() {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (p, c) => p.tracks.length != c.tracks.length,
      builder: (_, s) => s.tracks.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${s.tracks.length} TITLES',
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    child: Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.08,
        ), // Solider background to prevent overlapping feel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _search,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (v) =>
                  ctx.read<LibraryBloc>().add(SearchQueryChanged(v)),
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                hintText: AppStrings.search,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                // isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (p, c) => p.isSearching != c.isSearching,
            builder: (context, s) => s.isSearching
                ? GestureDetector(
                    onTap: () {
                      _search.clear();
                      context.read<LibraryBloc>().add(ClearSearch());
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );

  Widget _buildFilterTabs() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      children: [
        _pill(
          'TRACKS',
          Icons.music_note_rounded,
          _by == GroupBy.title,
          () => setState(() {
            _by = GroupBy.title;
            _cs = null;
          }),
        ),
        const SizedBox(width: 10),
        _pill(
          'ARTISTS',
          Icons.person_rounded,
          _by == GroupBy.artist,
          () => setState(() {
            _by = GroupBy.artist;
            _cs = null;
          }),
        ),
      ],
    ),
  );

  Widget _pill(String label, IconData icon, bool on, VoidCallback fn) =>
      GestureDetector(
        onTap: fn,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: on ? AppTheme.primary : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: on ? Colors.black : Colors.white54),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: on ? Colors.black : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildListBody() => BlocBuilder<LibraryBloc, LibraryState>(
    builder: (ctx, s) {
      if (s.status == LibraryStatus.initial ||
          (s.status == LibraryStatus.loading && s.tracks.isEmpty))
        return _fullLoader();
      if (s.status == LibraryStatus.error && s.tracks.isEmpty) {
        return s.errorMessage == AppStrings.noInternetConnection
            ? NoInternetBanner(
                onRetry: () => ctx.read<LibraryBloc>().add(LoadNextPage()),
              )
            : _err(ctx, s.errorMessage);
      }
      if (s.tracks.isEmpty && s.status == LibraryStatus.loaded)
        return _empty(s);

      return Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              ...sortfn(s.tracks),
              if (s.status == LibraryStatus.loading)
                SliverToBoxAdapter(child: _spin()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          ValueListenableBuilder<String>(
            valueListenable: _letter,
            builder: (_, v, __) => v.isEmpty
                ? const SizedBox.shrink()
                : StickyGroupHeader(letter: v),
          ),
        ],
      );
    },
  );

  List<Track> _sorted(List<Track> t) {
    if (_cs != null && _cl == t.length && _cb == _by) return _cs!;
    final a = List<Track>.from(t);
    _by == GroupBy.title
        ? a.sort(
            (x, y) => x.titleShort.toUpperCase().compareTo(
              y.titleShort.toUpperCase(),
            ),
          )
        : a.sort((x, y) {
            final c = x.artistName.toUpperCase().compareTo(
              y.artistName.toUpperCase(),
            );
            return c != 0
                ? c
                : x.titleShort.toUpperCase().compareTo(
                    y.titleShort.toUpperCase(),
                  );
          });
    _cl = t.length;
    _cb = _by;
    _cs = a;
    _mkoffs(a);
    return a;
  }

  void _mkoffs(List<Track> sorted) {
    _glet.clear();
    _goff.clear();
    double pos = 0;
    String? last;
    int from = 0;
    for (int i = 0; i <= sorted.length; i++) {
      final cur = i < sorted.length
          ? (_by == GroupBy.title
                ? sorted[i].groupLetter
                : sorted[i].artistGroupLetter)
          : null;
      if (cur != last) {
        if (last != null) {
          _glet.add(last);
          _goff.add(pos);
          pos += StickyGroupHeader.height + (i - from) * 72.0;
        }
        from = i;
        last = cur;
      }
    }
  }

  List<Widget> sortfn(List<Track> tracks) {
    final all = _sorted(tracks);
    final out = <Widget>[];
    String? last;
    int from = 0;
    for (int i = 0; i <= all.length; i++) {
      final cur = i < all.length
          ? (_by == GroupBy.title
                ? all[i].groupLetter
                : all[i].artistGroupLetter)
          : null;
      if (cur != last) {
        if (last != null) {
          final musiclist = all.sublist(from, i);
          out.add(SliverToBoxAdapter(child: StickyGroupHeader(letter: last)));
          out.add(
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, idx) => TweenAnimationBuilder<double>(
                  key: ValueKey(musiclist[idx].id),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 350 + (idx % 8) * 45),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, ch) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * 20),
                      child: ch,
                    ),
                  ),
                  child: TrackTile(
                    track: musiclist[idx],
                    onTap: () => _open(musiclist[idx]),
                  ),
                ),
                childCount: musiclist.length,
              ),
            ),
          );
        }
        from = i;
        last = cur;
      }
    }
    return out;
  }

  Widget _fullLoader() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
        const SizedBox(height: 24),
        const Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );

  Widget _spin() => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
    ),
  );

  Widget _err(BuildContext ctx, String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            msg.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => ctx.read<LibraryBloc>().add(LoadNextPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'RETRY',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _empty(LibraryState s) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          s.isSearching
              ? Icons.search_off_rounded
              : Icons.library_books_rounded,
          size: 56,
          color: Colors.white12,
        ),
        const SizedBox(height: 20),
        Text(
          s.isSearching
              ? 'NO RESULTS FOR "${s.searchQuery.toUpperCase()}"'
              : 'EMPTY LIBRARY',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
