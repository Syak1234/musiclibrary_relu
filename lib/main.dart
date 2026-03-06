import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'viewmodel/library/library_bloc.dart';
import 'view/screens/library_screen.dart';

void main() {
  runApp(const MusicLibraryApp());
}

class MusicLibraryApp extends StatelessWidget {
  const MusicLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator();

    return BlocProvider(
      create: (_) => LibraryBloc(repository: locator.musicRepository),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const LibraryScreen(),
      ),
    );
  }
}
