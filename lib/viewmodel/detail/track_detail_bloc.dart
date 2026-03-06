import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'package:musiclibrary_relu/core/utills/global_exception.dart';
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

  Future<void> _onLoadTrackDetail(
    LoadTrackDetail event,
    Emitter<TrackDetailState> emit,
  ) async {
    try {
      final detail = _repository.getTrackDetail(event.track);
      emit(state.copyWith(status: DetailStatus.loaded, detail: detail));

     
      final lyrics = await _repository.getLyrics(
        event.track.artistName,
        event.track.titleShort,
      );

      emit(
        state.copyWith(
          lyrics: lyrics ?? AppStrings.noLyricsFound,
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

  Future<void> _onShareTrack(
    ShareTrack event,
    Emitter<TrackDetailState> emit,
  ) async {
    try {
      HapticFeedback.lightImpact();
      final text =
          'Check out "${event.track.title}" by ${event.track.artistName} on Deezer: ${event.track.previewUrl}';
      await Share.share(text);
    } catch (e) {
      throw GlobalException(message: 'Failed to share track');
    }
  }

  Future<void> _onOpenTrackLink(
    OpenTrackLink event,
    Emitter<TrackDetailState> emit,
  ) async {
    try {
      if (event.link.isEmpty) return;
      
      final uri = Uri.parse(event.link);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      print('URL Launch Error: $e');
    }
  }
}
