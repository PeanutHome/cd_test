import '../api/tmdb_api.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  const MovieRemoteDataSource(this._api);

  final TmdbApi _api;
  static const _language = 'en-US';

  Future<PopularMoviesResponse> getPopularMovies(int page) =>
      _api.getPopularMovies(page);

  Future<MovieDetailModel> getMovieDetail(int id) =>
      _api.getMovieDetail(id, _language);

  Future<MovieCreditsResponse> getMovieCredits(int id) =>
      _api.getMovieCredits(id, _language);
}
