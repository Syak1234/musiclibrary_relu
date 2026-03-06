import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'package:musiclibrary_relu/core/utills/global_exception.dart';
import '../../core/network/network_checker.dart';
import '../api/music_api.dart';
import '../models/track.dart';
import '../models/track_detail.dart';
import 'music_repository_interface.dart';

List<Track> _parse(List<Map<String, dynamic>> raw) =>
    raw.map(Track.fromJson).toList();

class MusicRepository implements MusicRepositoryInterface {
  final MusicApi _api;
  final NetworkChecker _networkChecker;

  MusicRepository({
    required MusicApi api,
    required NetworkChecker networkChecker,
  }) : _api = api,
       _networkChecker = networkChecker;

  static const _queries = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];

  String _queryForPage(int pageIndex) {
    return _queries[pageIndex % _queries.length];
  }

  int _offsetForPage(int pageIndex) {
    return (pageIndex ~/ _queries.length) * 50;
  }

  Future<void> _ensureConnected() async {
    final connected = await _networkChecker.hasConnection;
    if (!connected) {
      throw GlobalException(message: AppStrings.noInternetConnection);
    }
  }

  @override
  Future<List<Track>> loadPage(int pageIndex, {int? limit}) async {
    await _ensureConnected();
    try {
      // log(limit.toString());
      final query = _queryForPage(pageIndex);
      final index = _offsetForPage(pageIndex);

      // log(query.toString());
      // log(index.toString());
      final rawTracks = await _api.fetchTracks(
        query: query,
        startIndex: index,
        limit: limit ?? 50,
      );
      return await compute(_parse, rawTracks);
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        throw GlobalException(message: AppStrings.noInternetConnection);
      }
      rethrow;
    }
  }

  @override
  Future<List<Track>> searchTracks(String searchQuery, int startIndex) async {
    await _ensureConnected();
    try {
      final rawTracks = await _api.fetchTracks(
        query: searchQuery,
        startIndex: startIndex,
        limit: 50,
      );
      return await compute(_parse, rawTracks);
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        throw GlobalException(message: AppStrings.noInternetConnection);
      }
      rethrow;
    }
  }

  @override
  TrackDetail getTrackDetail(Track track) {
    return TrackDetail.fromTrack(track);
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  @override
  void dispose() {
    _api.dispose();
  }
}
