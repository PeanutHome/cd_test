import 'package:hive/hive.dart';

import '../models/movie_model.dart';

class MovieLocalDataSource {
  MovieLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const _cacheKey = 'popular_movies';
  static const _pageKey = 'current_page';
  static const _totalPagesKey = 'total_pages';

  List<MovieModel> getCachedMovies() {
    final raw = _box.get(_cacheKey);
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => MovieModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  int get cachedPage => _box.get(_pageKey, defaultValue: 1) as int;

  int get totalPages => _box.get(_totalPagesKey, defaultValue: 1) as int;

  Future<void> saveMovies(
    List<MovieModel> movies, {
    required int page,
    required int totalPages,
    required bool replace,
  }) async {
    final List<MovieModel> updated;

    if (page == 1) {
      final existing = getCachedMovies();
      final tail = replace || existing.length <= movies.length
          ? <MovieModel>[]
          : existing.sublist(movies.length);
      updated = [...movies, ...tail];
    } else {
      updated = [...getCachedMovies(), ...movies];
    }

    await _box.put(_cacheKey, updated.map((movie) => movie.toJson()).toList());
    await _box.put(_pageKey, page);
    await _box.put(_totalPagesKey, totalPages);
  }

  Future<void> clear() async {
    await _box.delete(_cacheKey);
    await _box.delete(_pageKey);
    await _box.delete(_totalPagesKey);
  }
}
