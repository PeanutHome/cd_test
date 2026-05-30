import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

part 'tmdb_api.g.dart';

@RestApi()
abstract class TmdbApi {
  factory TmdbApi(Dio dio, {String baseUrl}) = _TmdbApi;

  @GET('/movie/popular')
  Future<PopularMoviesResponse> getPopularMovies(@Query('page') int page);

  @GET('/movie/{id}')
  Future<MovieDetailModel> getMovieDetail(
    @Path('id') int id,
    @Query('language') String language,
  );

  @GET('/movie/{id}/credits')
  Future<MovieCreditsResponse> getMovieCredits(
    @Path('id') int id,
    @Query('language') String language,
  );
}
