import '../../data/api/music_api.dart';
import '../../data/repository/music_repository.dart';
import '../../data/repository/music_repository_interface.dart';
import '../network/network_checker.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();

  factory ServiceLocator() => _instance;

  ServiceLocator._();

  MusicApi? _musicApi;
  MusicRepositoryInterface? _musicRepository;
  NetworkChecker? _networkChecker;

  MusicApi get musicApi {
    _musicApi ??= MusicApi();
    return _musicApi!;
  }

  MusicRepositoryInterface get musicRepository {
    _musicRepository ??= MusicRepository(
      api: musicApi,
      networkChecker: networkChecker,
    );
    return _musicRepository!;
  }

  NetworkChecker get networkChecker {
    _networkChecker ??= NetworkChecker();
    return _networkChecker!;
  }

  void reset() {
    _musicRepository?.dispose();
    _musicApi = null;
    _musicRepository = null;
    _networkChecker = null;
  }
}
