import 'package:equatable/equatable.dart';

sealed class LibraryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNextPage extends LibraryEvent {
  final int? limit;
  LoadNextPage({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class SearchQueryChanged extends LibraryEvent {
  final String query;
  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends LibraryEvent {}
