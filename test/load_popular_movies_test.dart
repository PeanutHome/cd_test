import 'package:flutter_test/flutter_test.dart';

import 'package:cd_test/domain/entities/movie.dart';
import 'package:cd_test/domain/entities/popular_movies_result.dart';
import 'package:cd_test/domain/repositories/movies_repository.dart';
import 'package:cd_test/domain/services/connectivity_gateway.dart';
import 'package:cd_test/domain/usecases/load_popular_movies.dart';

class _FakeMoviesRepository implements MoviesRepository {
  bool cacheCleared = false;
  List<Movie> cache = const [
    Movie(
      id: 1,
      title: 'Cached',
      overview: 'From disk',
      posterPath: '/p.jpg',
      backdropPath: '/b.jpg',
      releaseDate: '2024-01-01',
      voteAverage: 7.5,
    ),
  ];

  @override
  int get cachedPage => 1;

  @override
  int get totalPages => 1;

  @override
  Future<void> clearCache() async {
    cacheCleared = true;
    cache = const [];
  }

  @override
  Future<PopularMoviesResult> fetchPage({
    required int page,
    bool replaceCache = false,
  }) async {
    return PopularMoviesResult(
      movies: const [
        Movie(
          id: 2,
          title: 'Fresh',
          overview: 'From API',
          posterPath: '/p2.jpg',
          backdropPath: '/b2.jpg',
          releaseDate: '2025-01-01',
          voteAverage: 8.1,
        ),
      ],
      page: 1,
      totalPages: 5,
    );
  }

  @override
  Future<List<Movie>> readCache() async => cache;
}

class _FakeConnectivity implements ConnectivityGateway {
  _FakeConnectivity(this._online);

  bool _online;

  set online(bool value) => _online = value;

  @override
  Future<bool> get isOnline async => _online;
}

void main() {
  late _FakeMoviesRepository repo;
  late _FakeConnectivity connectivity;
  late LoadPopularMovies useCase;

  setUp(() {
    repo = _FakeMoviesRepository();
    connectivity = _FakeConnectivity(true);
    useCase = LoadPopularMovies(repo, connectivity);
  });

  test('forceRefresh clears cache before fetching', () async {
    final result = await useCase.forceRefresh();

    expect(repo.cacheCleared, isTrue);
    expect(result.hasMovies, isTrue);
    expect(result.movies.first.title, 'Fresh');
  });

  test('forceRefresh while offline returns error after clearing cache', () async {
    connectivity.online = false;

    final result = await useCase.forceRefresh();

    expect(repo.cacheCleared, isTrue);
    expect(result.failed, isTrue);
    expect(result.isOffline, isTrue);
  });

  test('syncFirstPage keeps cache when offline', () async {
    connectivity.online = false;

    final result = await useCase.syncFirstPage(replaceCache: false);

    expect(result.hasMovies, isTrue);
    expect(result.movies.first.title, 'Cached');
    expect(result.isOffline, isTrue);
  });
}
