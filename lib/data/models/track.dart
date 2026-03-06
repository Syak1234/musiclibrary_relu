import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final String titleShort;
  final int duration;
  final String artistName;
  final int artistId;
  final String artistPictureMedium;
  final String albumTitle;
  final int albumId;
  final String albumCoverSmall;
  final String albumCoverMedium;
  final String albumCoverBig;
  final String previewUrl;
  final String link;
  final int rank;
  final bool explicitLyrics;

  const Track({
    required this.id,
    required this.title,
    required this.titleShort,
    required this.duration,
    required this.artistName,
    required this.artistId,
    required this.artistPictureMedium,
    required this.albumTitle,
    required this.albumId,
    required this.albumCoverSmall,
    required this.albumCoverMedium,
    required this.albumCoverBig,
    required this.previewUrl,
    required this.link,
    required this.rank,
    required this.explicitLyrics,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>? ?? {};
    final album = json['album'] as Map<String, dynamic>? ?? {};

    return Track(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      titleShort: json['title_short'] ?? json['title'] ?? '',
      duration: json['duration'] ?? 0,
      artistName: artist['name'] ?? 'Unknown Artist',
      artistId: artist['id'] ?? 0,
      artistPictureMedium: artist['picture_medium'] ?? '',
      albumTitle: album['title'] ?? 'Unknown Album',
      albumId: album['id'] ?? 0,
      albumCoverSmall: album['cover_small'] ?? '',
      albumCoverMedium: album['cover_medium'] ?? '',
      albumCoverBig: album['cover_big'] ?? '',
      previewUrl: json['preview'] ?? '',
      link: json['link'] ?? '',
      rank: json['rank'] ?? 0,
      explicitLyrics: json['explicit_lyrics'] ?? false,
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get groupLetter {
    if (titleShort.isEmpty) return '#';
    final first = titleShort[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(first)) return first;
    return '#';
  }

  String get artistGroupLetter {
    if (artistName.isEmpty) return '#';
    final first = artistName[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(first)) return first;
    return '#';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id];

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ;

  // @override
  // int get hashCode =>;
}
