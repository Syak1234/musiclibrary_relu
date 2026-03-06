import 'package:equatable/equatable.dart';
import '../../data/models/track.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<Track> tracks;
  final bool hasend;
  final int currentPage;
  final String searchQuery;
  final int searchOffset;
  final String errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.tracks = const [],
    this.hasend = false,
    this.currentPage = 0,
    this.searchQuery = '',
    this.searchOffset = 0,
    this.errorMessage = '',
  });

  bool get isSearching => searchQuery.isNotEmpty;

  LibraryState copyWith({
    LibraryStatus? status,
    List<Track>? tracks,
    bool? hasend,
    int? currentPage,
    String? searchQuery,
    int? searchOffset,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      hasend: hasend ?? this.hasend,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      searchOffset: searchOffset ?? this.searchOffset,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tracks.length,
    hasend,
    currentPage,
    searchQuery,
    searchOffset,
    errorMessage,
  ];
}
