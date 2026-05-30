import '../entities/movie.dart';
import '../entities/popular_movies_result.dart';

abstract class MoviesRepository {
  Future<List<Movie>> readCache();

  int get cachedPage;

  int get totalPages;

  Future<void> clearCache();

  Future<PopularMoviesResult> fetchPage({
    required int page,
    bool replaceCache = false,
  });
}
