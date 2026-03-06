import '../models/track.dart';
import '../models/track_detail.dart';

abstract class MusicRepositoryInterface {
  Future<List<Track>> loadPage(int pageIndex, {int? limit});
  Future<List<Track>> searchTracks(String searchQuery, int startIndex);
  TrackDetail getTrackDetail(Track track);
  Future<String?> getLyrics(String artist, String trackTitle);
  void dispose();
}
