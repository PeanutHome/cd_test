import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/movie_model.dart';
import 'cached_popular_movies.dart';

class MoviesCacheStore {
  MoviesCacheStore(this._box);

  static const _snapshotKey = 'popular_snapshot';

  final Box<CachedPopularMovies> _box;

  List<MovieModel> readMovies() {
    final snapshot = _box.get(_snapshotKey);
    if (snapshot == null) return [];

    return snapshot.movieJsonRows
        .map(
          (row) => MovieModel.fromJson(
            jsonDecode(row) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  int get page => _box.get(_snapshotKey)?.page ?? 1;

  int get totalPages => _box.get(_snapshotKey)?.totalPages ?? 1;

  Future<void> save({
    required List<MovieModel> movies,
    required int page,
    required int totalPages,
    required bool replace,
  }) async {
    final existing = readMovies();
    final List<MovieModel> merged;

    if (page == 1) {
      final tail = replace || existing.length <= movies.length
          ? <MovieModel>[]
          : existing.sublist(movies.length);
      merged = [...movies, ...tail];
    } else {
      merged = [...existing, ...movies];
    }

    final snapshot = CachedPopularMovies(
      movieJsonRows: merged.map((movie) => jsonEncode(movie.toJson())).toList(),
      page: page,
      totalPages: totalPages,
    );

    await _box.put(_snapshotKey, snapshot);
  }

  Future<void> clear() => _box.delete(_snapshotKey);
}
