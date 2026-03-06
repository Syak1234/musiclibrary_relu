import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'package:musiclibrary_relu/core/utills/global_exception.dart';
import '../../data/repository/music_repository_interface.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final MusicRepositoryInterface _repository;
  Timer? _dbt;
  int _sv = 0;

  LibraryBloc({required MusicRepositoryInterface repository})
    : _repository = repository,
      super(const LibraryState()) {
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadNextPage(LoadNextPage event, Emitter<LibraryState> emit) async {
    if (state.hasend || state.status == LibraryStatus.loading) return;
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      if (state.isSearching) {
        final nw = await _repository.searchTracks(state.searchQuery, state.searchOffset);
        final all = [...state.tracks, ...nw];
        _dedup(all);
        emit(state.copyWith(
          status: LibraryStatus.loaded,
          tracks: all,
          searchOffset: state.searchOffset + 50,
          hasend: nw.isEmpty || nw.length < 50,
        ));
      } else {
        final nw = await _repository.loadPage(state.currentPage, limit: event.limit);
        final all = [...state.tracks, ...nw];
        _dedup(all);
        emit(state.copyWith(
          status: LibraryStatus.loaded,
          tracks: all,
          currentPage: state.currentPage + 1,
          hasend: nw.isEmpty,
        ));
      }
    } on GlobalException catch (e) {
      emit(state.copyWith(status: LibraryStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: LibraryStatus.error, errorMessage: AppStrings.somethingWentWrong));
    }
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<LibraryState> emit) async {
    _dbt?.cancel();
    _sv++;
    final v = _sv;
    final q = event.query.trim();

    if (q.isEmpty) { add(ClearSearch()); return; }

    final cp = Completer<void>();
    _dbt = Timer(const Duration(milliseconds: 400), cp.complete);
    await cp.future;

    if (v != _sv) return;

    emit(const LibraryState().copyWith(status: LibraryStatus.loading, searchQuery: q));

    try {
      final res = await _repository.searchTracks(q, 0);
      if (v != _sv) return;
      emit(state.copyWith(
        status: LibraryStatus.loaded,
        tracks: res,
        searchOffset: 50,
        hasend: res.isEmpty || res.length < 50,
      ));
    } on GlobalException catch (e) {
      emit(state.copyWith(status: LibraryStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: LibraryStatus.error, errorMessage: AppStrings.searchFailed));
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<LibraryState> emit) async {
    _dbt?.cancel();
    _sv++;
    emit(const LibraryState());
    add(LoadNextPage());
  }

  void _dedup(List all) {
    final seen = <int>{};
    all.retainWhere((t) => seen.add(t.id));
  }

  @override
  Future<void> close() {
    _dbt?.cancel();
    return super.close();
  }
}
