import '../../domain/entities/cast_member.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/popular_movies_result.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._remote, this._local);

  final MovieRemoteDataSource _remote;
  final MovieLocalDataSource _local;

  @override
  Future<List<Movie>> getCachedPopularMovies() async {
    return _local.getCachedMovies().map((model) => model.toEntity()).toList();
  }

  @override
  int get cachedPage => _local.cachedPage;

  @override
  int get totalPages => _local.totalPages;

  @override
  Future<void> clearCache() => _local.clear();

  @override
  Future<PopularMoviesResult> fetchPopularMovies({
    required int page,
    bool replaceCache = false,
  }) async {
    final response = await _remote.getPopularMovies(page);
    await _local.saveMovies(
      response.results,
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

  @override
  Future<MovieDetail> getMovieDetail(int id) async {
    final detail = await _remote.getMovieDetail(id);

    var cast = <CastMember>[];
    try {
      final credits = await _remote.getMovieCredits(id);
      cast = credits.cast.take(15).map((member) => member.toEntity()).toList();
    } catch (_) {}

    return detail.toEntity(cast);
  }
}
