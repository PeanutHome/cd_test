import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/movies/bloc/movies_bloc.dart';
import 'presentation/movies/bloc/movies_event.dart';
import 'presentation/movies/pages/movies_page.dart';

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key, required this.container});

  final AppContainer container;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MoviesBloc(container.loadPopularMovies)..add(const MoviesStarted()),
      child: MaterialApp(
        title: 'Movie Explorer',
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const MoviesPage(),
      ),
    );
  }
}
