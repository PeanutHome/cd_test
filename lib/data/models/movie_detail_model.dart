import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cast_member.dart';
import '../../domain/entities/movie_detail.dart';

part 'movie_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GenreModel {
  const GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);

  final int id;
  final String name;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MovieDetailModel {
  const MovieDetailModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    this.genres = const [],
    this.runtime,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailModelFromJson(json);

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  @JsonKey(defaultValue: <GenreModel>[])
  final List<GenreModel> genres;
  final int? runtime;

  MovieDetail toEntity(List<CastMember> cast) => MovieDetail(
        id: id,
        title: title,
        overview: overview,
        posterPath: posterPath,
        backdropPath: backdropPath,
        releaseDate: releaseDate,
        voteAverage: voteAverage,
        genres: genres.map((genre) => genre.name).toList(),
        runtime: runtime,
        cast: cast,
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CastModel {
  const CastModel({
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) =>
      _$CastModelFromJson(json);

  final String name;
  final String character;
  final String? profilePath;

  CastMember toEntity() => CastMember(
        name: name,
        character: character,
        profilePath: profilePath,
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MovieCreditsResponse {
  const MovieCreditsResponse({this.cast = const []});

  factory MovieCreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieCreditsResponseFromJson(json);

  @JsonKey(defaultValue: <CastModel>[])
  final List<CastModel> cast;
}
