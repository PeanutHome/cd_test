import '../entities/movie.dart';
import '../entities/popular_movies_result.dart';
import '../repositories/movie_repository.dart';

class GetPopularMoviesUseCase {
  const GetPopularMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> getCached() => _repository.getCachedPopularMovies();

  int get cachedPage => _repository.cachedPage;

  int get totalPages => _repository.totalPages;

  Future<void> clearCache() => _repository.clearCache();

  Future<PopularMoviesResult> fetch({
    required int page,
    bool replaceCache = false,
  }) {
    return _repository.fetchPopularMovies(
      page: page,
      replaceCache: replaceCache,
    );
  }
}
