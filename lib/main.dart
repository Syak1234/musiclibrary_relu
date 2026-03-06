import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musiclibrary_relu/core/utills/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/utills/routes.dart';
import 'viewmodel/library/library_bloc.dart';
import 'viewmodel/connection/connection_bloc.dart';
import 'view/widgets/music_error_widget.dart';

void main() {
  runZonedGuarded(
    () {
      ErrorWidget.builder = (FlutterErrorDetails d) {
        return Material(child: MusicErrorWidget(d));
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LibraryBloc(repository: locator.musicRepository),
        ),
        BlocProvider(
          create: (_) => ConnectionBloc(networkChecker: locator.networkChecker),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
