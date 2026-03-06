import 'package:equatable/equatable.dart';
import '../../data/models/track_detail.dart';

enum DetailStatus { loading, loaded, error }

class TrackDetailState extends Equatable {
  final DetailStatus status;
  final TrackDetail? detail;
  final String lyrics;
  final String errorMessage;

  const TrackDetailState({
    this.status = DetailStatus.loading,
    this.detail,
    this.lyrics = '',
    this.errorMessage = '',
  });

  TrackDetailState copyWith({
    DetailStatus? status,
    TrackDetail? detail,
    String? lyrics,
    String? errorMessage,
  }) {
    return TrackDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      lyrics: lyrics ?? this.lyrics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail?.id, lyrics, errorMessage];
}
