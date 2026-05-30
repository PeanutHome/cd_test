import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../di/app_dependencies.dart';
import '../network/api_key_interceptor.dart';
import '../../data/api/tmdb_api.dart';
import '../../data/datasources/movie_local_datasource.dart';
import '../../data/datasources/movie_remote_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/services/network_info_impl.dart';
import '../../domain/usecases/get_movie_detail.dart';
import '../../domain/usecases/get_popular_movies.dart';

class AppBootstrap {
  static Future<AppDependencies?> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppConfig.load();

    if (!AppConfig.isConfigured) return null;

    await Hive.initFlutter();
    final moviesBox = await Hive.openBox('movies');

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..interceptors.add(ApiKeyInterceptor());

    final repository = MovieRepositoryImpl(
      MovieRemoteDataSource(TmdbApi(dio)),
      MovieLocalDataSource(moviesBox),
    );

    return AppDependencies(
      getPopularMovies: GetPopularMoviesUseCase(repository),
      getMovieDetail: GetMovieDetailUseCase(repository),
      networkInfo: NetworkInfoImpl(Connectivity()),
    );
  }
}
