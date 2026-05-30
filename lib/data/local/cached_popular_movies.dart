import 'package:hive/hive.dart';

/// Hive snapshot — only primitives (JSON strings + ints), no image bytes.
class CachedPopularMovies {
  CachedPopularMovies({
    required this.movieJsonRows,
    required this.page,
    required this.totalPages,
  });

  final List<String> movieJsonRows;
  final int page;
  final int totalPages;
}

class CachedPopularMoviesAdapter extends TypeAdapter<CachedPopularMovies> {
  @override
  final int typeId = 0;

  @override
  CachedPopularMovies read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    var page = 1;
    var totalPages = 1;
    List<String> rows = const [];

    for (var i = 0; i < fieldCount; i++) {
      final field = reader.readByte();
      switch (field) {
        case 0:
          rows = reader.readList().cast<String>();
        case 1:
          page = reader.readInt();
        case 2:
          totalPages = reader.readInt();
      }
    }

    return CachedPopularMovies(
      movieJsonRows: rows,
      page: page,
      totalPages: totalPages,
    );
  }

  @override
  void write(BinaryWriter writer, CachedPopularMovies obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.movieJsonRows)
      ..writeByte(1)
      ..write(obj.page)
      ..writeByte(2)
      ..write(obj.totalPages);
  }
}
