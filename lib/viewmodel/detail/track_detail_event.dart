import 'package:equatable/equatable.dart';
import '../../data/models/track.dart';

sealed class TrackDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTrackDetail extends TrackDetailEvent {
  final Track track;
  LoadTrackDetail(this.track);

  @override
  List<Object?> get props => [track.id];
}
