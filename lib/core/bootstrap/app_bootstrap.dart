import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/api/tmdb_api.dart';
import '../../data/local/cached_popular_movies.dart';
import '../../data/local/movies_cache_store.dart';
import '../../data/repositories/movies_repository_impl.dart';
import '../../data/services/connectivity_plugin.dart';
import '../../domain/usecases/load_popular_movies.dart';
import '../config/app_config.dart';
import '../di/app_container.dart';
import '../network/api_key_interceptor.dart';

class AppBootstrap {
  static Future<AppContainer?> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppConfig.load();

    if (!AppConfig.isConfigured) return null;

    await Hive.initFlutter();
    Hive.registerAdapter(CachedPopularMoviesAdapter());

    final cacheBox = await Hive.openBox<CachedPopularMovies>('movies_cache');
    final cacheStore = MoviesCacheStore(cacheBox);

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..interceptors.add(ApiKeyInterceptor());

    final moviesRepo = MoviesRepositoryImpl(TmdbApi(dio), cacheStore);
    final connectivity = ConnectivityPlugin(Connectivity());

    return AppContainer(
      loadPopularMovies: LoadPopularMovies(moviesRepo, connectivity),
      connectivity: connectivity,
    );
  }
}
