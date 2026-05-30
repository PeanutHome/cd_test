import '../entities/movie.dart';

class PopularMoviesSync {
  const PopularMoviesSync({
    required this.movies,
    required this.page,
    required this.totalPages,
    this.isOffline = false,
    this.errorMessage,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool isOffline;
  final String? errorMessage;

  bool get hasMovies => movies.isNotEmpty;
  bool get failed => errorMessage != null && !hasMovies;
}
