import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'viewmodel/library/library_bloc.dart';
import 'view/screens/library_screen.dart';

void main() {
  runZonedGuarded(
    () {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          child: Center(
            child: Text(
              'An error occurred: ${details.exception}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      };
      runApp(const MusicLibraryApp());
    },
    (error, stack) {
      log(error.toString());
      log(stack.toString());
    },
  );
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
