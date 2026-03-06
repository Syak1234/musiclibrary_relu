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
    if (_st) return;
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 600) {
      _st = true;
      context.read<LibraryBloc>().add(LoadNextPage(limit: _lim));
      Future.delayed(const Duration(seconds: 2), () => _st = false);
    }
    if (_glet.isEmpty) return;
    final px = _scroll.position.pixels;
    var l = _glet.first;
    for (int i = 1; i < _goff.length; i++) {
      if (_goff[i] <= px)
        l = _glet[i];
      else
        break;
    }
    if (_letter.value != l) _letter.value = l;
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _top(ctx),
            _bar(ctx),
            _tabs(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _top(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: Row(
      children: [
        Icon(Icons.library_music_rounded, color: AppTheme.primary, size: 28),
        const SizedBox(width: 10),
        Text(AppStrings.appName, style: Theme.of(ctx).textTheme.headlineLarge),
        const Spacer(),
        BlocBuilder<LibraryBloc, LibraryState>(
          buildWhen: (p, c) => p.tracks.length != c.tracks.length,
          builder: (_, s) => s.tracks.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${s.tracks.length} tracks',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
    ),
  );

  Widget _bar(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: TextField(
      controller: _search,
      onChanged: (v) => ctx.read<LibraryBloc>().add(SearchQueryChanged(v)),
      decoration: InputDecoration(
        hintText: AppStrings.search,
        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
        suffixIcon: BlocBuilder<LibraryBloc, LibraryState>(
          buildWhen: (p, c) => p.isSearching != c.isSearching,
          builder: (_, s) => !s.isSearching
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    _search.clear();
                    ctx.read<LibraryBloc>().add(ClearSearch());
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _tabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        Icon(
          Icons.sort_by_alpha_rounded,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          'Group by:',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        _pill(
          'Track',
          Icons.music_note_rounded,
          _by == GroupBy.title,
          () => setState(() {
            _by = GroupBy.title;
            _cs = null;
          }),
        ),
        const SizedBox(width: 8),
        _pill(
          'Artist',
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: on
                ? AppTheme.primary.withValues(alpha: 0.85)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: on
                  ? AppTheme.primary
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: on ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: on ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _body() => BlocBuilder<LibraryBloc, LibraryState>(
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
            slivers: [
              ...sortfn(s.tracks),
              if (s.status == LibraryStatus.loading)
                SliverToBoxAdapter(child: _spin()),
              if (s.status == LibraryStatus.error && s.tracks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      s.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.errorRed, fontSize: 13),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
          pos += StickyGroupHeader.height + (i - from) * 68.0;
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
          out
            ..add(SliverToBoxAdapter(child: StickyGroupHeader(letter: last)))
            ..add(
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, idx) => TweenAnimationBuilder<double>(
                    key: ValueKey(musiclist[idx].id),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 280 + (idx % 7) * 40),
                    curve: Curves.easeOut,
                    builder: (_, v, ch) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, (1 - v) * 18),
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

  Widget _fullLoader() => SizedBox.expand(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
        const SizedBox(height: 20),
        Text(
          'Loading music...',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _spin() => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: CircularProgressIndicator(
        color: AppTheme.primary,
        strokeWidth: 2.5,
      ),
    ),
  );

  Widget _err(BuildContext ctx, String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ctx.read<LibraryBloc>().add(LoadNextPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.retry,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _empty(LibraryState s) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            s.isSearching ? Icons.search_off_rounded : Icons.music_off_rounded,
            size: 52,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            s.isSearching
                ? 'No results for "${s.searchQuery}"'
                : AppStrings.noTracksFound,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (s.isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different song or artist name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
