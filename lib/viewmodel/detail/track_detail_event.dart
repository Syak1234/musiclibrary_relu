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

class ShareTrack extends TrackDetailEvent {
  final Track track;
  ShareTrack(this.track);

  @override
  List<Object?> get props => [track.id];
}

class OpenTrackLink extends TrackDetailEvent {
  final String link;
  OpenTrackLink(this.link);

  @override
  List<Object?> get props => [link];
}
