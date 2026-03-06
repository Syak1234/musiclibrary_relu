import 'package:go_router/go_router.dart';
import '../../data/models/track.dart';
import '../../view/screens/library_screen.dart';
import '../../view/screens/track_detail_screen.dart';

class AppRoutes {
  static const String library = '/';
  static const String detail = '/detail';

  static final router = GoRouter(
    initialLocation: library,
    routes: [
      GoRoute(
        path: library,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: detail,
        builder: (context, state) {
          final track = state.extra as Track;
          return TrackDetailScreen(track: track);
        },
      ),
    ],
  );
}
