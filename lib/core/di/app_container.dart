import '../../domain/usecases/load_popular_movies.dart';
import '../../domain/services/connectivity_gateway.dart';

class AppContainer {
  const AppContainer({
    required this.loadPopularMovies,
    required this.connectivity,
  });

  final LoadPopularMovies loadPopularMovies;
  final ConnectivityGateway connectivity;
}
