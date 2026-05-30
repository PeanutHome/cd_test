import '../../domain/entities/movie.dart';
import '../../domain/entities/popular_movies_result.dart';
import '../../domain/repositories/movies_repository.dart';
import '../api/tmdb_api.dart';
import '../local/movies_cache_store.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  MoviesRepositoryImpl(this._api, this._cache);

  final TmdbApi _api;
  final MoviesCacheStore _cache;

  @override
  Future<List<Movie>> readCache() async {
    return _cache.readMovies().map((model) => model.toEntity()).toList();
  }

  @override
  int get cachedPage => _cache.page;

  @override
  int get totalPages => _cache.totalPages;

  @override
  Future<void> clearCache() => _cache.clear();

  @override
  Future<PopularMoviesResult> fetchPage({
    required int page,
    bool replaceCache = false,
  }) async {
    final response = await _api.getPopularMovies(page);

    await _cache.save(
      movies: response.results,
      page: page,
      totalPages: response.totalPages,
      replace: replaceCache,
    );

    return PopularMoviesResult(
      movies: response.results.map((model) => model.toEntity()).toList(),
      page: page,
      totalPages: response.totalPages,
    );
  }
}
