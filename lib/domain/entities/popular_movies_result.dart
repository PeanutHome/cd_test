import '../entities/movie.dart';

class PopularMoviesResult {
  const PopularMoviesResult({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;
}
