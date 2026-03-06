import 'track.dart';

class TrackDetail {
  final int id;
  final String title;
  final int duration;
  final int trackPosition;
  final int diskNumber;
  final String releaseDate;
  final double bpm;
  final int gain;
  final String artistName;
  final String artistPictureBig;
  final String albumTitle;
  final String albumCoverBig;
  final String albumCoverXl;
  final int albumTracksCount;
  final String link;

  TrackDetail({
    required this.id,
    required this.title,
    required this.duration,
    required this.trackPosition,
    required this.diskNumber,
    required this.releaseDate,
    required this.bpm,
    required this.gain,
    required this.artistName,
    required this.artistPictureBig,
    required this.albumTitle,
    required this.albumCoverBig,
    required this.albumCoverXl,
    required this.albumTracksCount,
    required this.link,
  });

  factory TrackDetail.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>? ?? {};
    final album = json['album'] as Map<String, dynamic>? ?? {};

    return TrackDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      duration: json['duration'] ?? 0,
      trackPosition: json['track_position'] ?? 0,
      diskNumber: json['disk_number'] ?? 0,
      releaseDate: album['release_date'] ?? '',
      bpm: (json['bpm'] ?? 0).toDouble(),
      gain: (json['gain'] ?? 0).toInt(),
      artistName: artist['name'] ?? 'Unknown',
      artistPictureBig: artist['picture_big'] ?? '',
      albumTitle: album['title'] ?? '',
      albumCoverBig: album['cover_big'] ?? '',
      albumCoverXl: album['cover_xl'] ?? '',
      albumTracksCount: album['nb_tracks'] ?? 0,
      link: json['link'] ?? '',
    );
  }

  factory TrackDetail.fromTrack(Track track) {
    return TrackDetail(
      id: track.id,
      title: track.title,
      duration: track.duration,
      trackPosition: 0,
      diskNumber: 0,
      releaseDate: '',
      bpm: 0,
      gain: 0,
      artistName: track.artistName,
      artistPictureBig: track.artistPictureMedium,
      albumTitle: track.albumTitle,
      albumCoverBig: track.albumCoverBig,
      albumCoverXl: track.albumCoverBig,
      albumTracksCount: 0,
      link: track.link,
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
