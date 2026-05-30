import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/popular_movies_result.dart';

abstract class MovieRepository {
  Future<List<Movie>> getCachedPopularMovies();

  int get cachedPage;

  int get totalPages;

  Future<void> clearCache();

  Future<PopularMoviesResult> fetchPopularMovies({
    required int page,
    bool replaceCache = false,
  });

  Future<MovieDetail> getMovieDetail(int id);
}
