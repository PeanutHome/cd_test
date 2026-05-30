import '../../domain/usecases/get_movie_detail.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/services/network_info.dart';

class AppDependencies {
  const AppDependencies({
    required this.getPopularMovies,
    required this.getMovieDetail,
    required this.networkInfo,
  });

  final GetPopularMoviesUseCase getPopularMovies;
  final GetMovieDetailUseCase getMovieDetail;
  final NetworkInfo networkInfo;
}
