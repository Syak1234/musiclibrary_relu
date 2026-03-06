import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repository/music_repository_interface.dart';
import 'track_detail_event.dart';
import 'track_detail_state.dart';

class TrackDetailBloc extends Bloc<TrackDetailEvent, TrackDetailState> {
  final MusicRepositoryInterface _repository;

  TrackDetailBloc({required MusicRepositoryInterface repository})
    : _repository = repository,
      super(const TrackDetailState()) {
    on<LoadTrackDetail>(_onLoadTrackDetail);
    on<ShareTrack>(_onShareTrack);
    on<OpenTrackLink>(_onOpenTrackLink);
  }

  void _onLoadTrackDetail(
    LoadTrackDetail event,
    Emitter<TrackDetailState> emit,
  ) {
    try {
      final detail = _repository.getTrackDetail(event.track);
      emit(
        state.copyWith(
          status: DetailStatus.loaded,
          detail: detail,
          lyrics: AppStrings.noLyricsFound,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DetailStatus.error,
          errorMessage: AppStrings.failedToLoadDetail,
        ),
      );
    }
  }

  Future<void> _onShareTrack(ShareTrack event, Emitter<TrackDetailState> emit) async {
    final text = 'Check out "${event.track.title}" by ${event.track.artistName} on Deezer: ${event.track.link}';
    await Share.share(text);
  }

  Future<void> _onOpenTrackLink(OpenTrackLink event, Emitter<TrackDetailState> emit) async {
    final uri = Uri.parse(event.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
