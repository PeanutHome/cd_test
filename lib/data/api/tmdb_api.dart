import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/movie_model.dart';

part 'tmdb_api.g.dart';

@RestApi()
abstract class TmdbApi {
  factory TmdbApi(Dio dio, {String baseUrl}) = _TmdbApi;

  @GET('/movie/popular')
  Future<PopularMoviesResponse> getPopularMovies(@Query('page') int page);
}
