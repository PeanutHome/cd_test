import '../../core/network/network_failure.dart';
import '../entities/movie.dart';
import '../entities/popular_movies_sync.dart';
import '../repositories/movies_repository.dart';
import '../services/connectivity_gateway.dart';

/// Owns cache/network policy so BLoC stays UI-focused.
class LoadPopularMovies {
  LoadPopularMovies(this._movies, this._connectivity);

  final MoviesRepository _movies;
  final ConnectivityGateway _connectivity;

  Future<List<Movie>> readCache() => _movies.readCache();

  int get cachedPage => _movies.cachedPage;

  int get totalPages => _movies.totalPages;

  Future<PopularMoviesSync> syncFirstPage({required bool replaceCache}) {
    return _syncPage(page: 1, replaceCache: replaceCache);
  }

  Future<PopularMoviesSync> syncNextPage({required int nextPage}) {
    return _syncPage(page: nextPage, replaceCache: false);
  }

  /// Assessment: pull-to-refresh clears local data, then forces a remote fetch.
  Future<PopularMoviesSync> forceRefresh() async {
    await _movies.clearCache();

    if (!await _connectivity.isOnline) {
      return const PopularMoviesSync(
        movies: [],
        page: 1,
        totalPages: 1,
        isOffline: true,
        errorMessage:
            'You are offline. Connect to the internet and pull to refresh.',
      );
    }

    return _syncPage(page: 1, replaceCache: true, skipOfflineCache: true);
  }

  Future<PopularMoviesSync> _syncPage({
    required int page,
    required bool replaceCache,
    bool skipOfflineCache = false,
  }) async {
    final cached = skipOfflineCache ? <Movie>[] : await _movies.readCache();

    if (!await _connectivity.isOnline) {
      if (cached.isEmpty) {
        return const PopularMoviesSync(
          movies: [],
          page: 1,
          totalPages: 1,
          isOffline: true,
          errorMessage:
              'You are offline and no saved movies were found. Pull to refresh when back online.',
        );
      }

      return PopularMoviesSync(
        movies: cached,
        page: _movies.cachedPage,
        totalPages: _movies.totalPages,
        isOffline: true,
      );
    }

    try {
      final result = await _movies.fetchPage(
        page: page,
        replaceCache: replaceCache,
      );

      final movies = replaceCache || cached.isEmpty
          ? result.movies
          : await _movies.readCache();

      return PopularMoviesSync(
        movies: movies,
        page: replaceCache || cached.isEmpty ? result.page : _movies.cachedPage,
        totalPages: result.totalPages,
      );
    } catch (error) {
      final failure = NetworkFailure.from(error);

      if (cached.isNotEmpty) {
        return PopularMoviesSync(
          movies: cached,
          page: _movies.cachedPage,
          totalPages: _movies.totalPages,
          isOffline: failure.isOffline,
        );
      }

      return PopularMoviesSync(
        movies: const [],
        page: 1,
        totalPages: 1,
        isOffline: failure.isOffline,
        errorMessage: failure.message,
      );
    }
  }
}
