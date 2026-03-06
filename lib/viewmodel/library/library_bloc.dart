import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'package:musiclibrary_relu/core/utills/global_exception.dart';
import '../../data/repository/music_repository_interface.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final MusicRepositoryInterface _repository;
  Timer? _searchDebounce;

  LibraryBloc({required MusicRepositoryInterface repository})
    : _repository = repository,
      super(const LibraryState()) {
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<LibraryState> emit,
  ) async {
    if (state.hasend || state.status == LibraryStatus.loading) return;

    emit(state.copyWith(status: LibraryStatus.loading));

    try {
      if (state.isSearching) {
        final newTracks = await _repository.searchTracks(
          state.searchQuery,
          state.searchOffset,
        );

        final allTracks = [...state.tracks, ...newTracks];
        _removeDuplicates(allTracks);

        emit(
          state.copyWith(
            status: LibraryStatus.loaded,
            tracks: allTracks,
            searchOffset: state.searchOffset + 50,
            hasend: newTracks.isEmpty || newTracks.length < 50,
          ),
        );
      } else {
        log(state.currentPage.toString() + "page");
        final newTracks = await _repository.loadPage(
          state.currentPage,
          limit: event.limit,
        );

        final allTracks = [...state.tracks, ...newTracks];
        _removeDuplicates(allTracks);

        emit(
          state.copyWith(
            status: LibraryStatus.loaded,
            tracks: allTracks,
            currentPage: state.currentPage + 1,
            hasend: newTracks.isEmpty,
          ),
        );
      }
    } on GlobalException catch (e) {
      emit(
        state.copyWith(status: LibraryStatus.error, errorMessage: e.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LibraryStatus.error,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<LibraryState> emit,
  ) async {
    _searchDebounce?.cancel();

    final query = event.query.trim();

    if (query.isEmpty) {
      add(ClearSearch());
      return;
    }

    final completer = Completer<void>();

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      completer.complete();
    });

    await completer.future;

    emit(
      const LibraryState().copyWith(
        status: LibraryStatus.loading,
        searchQuery: query,
      ),
    );

    try {
      final results = await _repository.searchTracks(query, 0);

      emit(
        state.copyWith(
          status: LibraryStatus.loaded,
          tracks: results,
          searchOffset: 50,
          hasend: results.isEmpty || results.length < 50,
        ),
      );
    } on GlobalException catch (e) {
      emit(
        state.copyWith(status: LibraryStatus.error, errorMessage: e.message),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LibraryStatus.error,
          errorMessage: AppStrings.searchFailed,
        ),
      );
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<LibraryState> emit,
  ) async {
    _searchDebounce?.cancel();

    emit(const LibraryState());
    add(LoadNextPage());
  }

  void _removeDuplicates(List allTracks) {
    final seen = <int>{};
    allTracks.retainWhere((track) => seen.add(track.id));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
