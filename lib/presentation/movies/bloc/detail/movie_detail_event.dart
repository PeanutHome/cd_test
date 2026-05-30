import 'package:equatable/equatable.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

class MovieDetailStarted extends MovieDetailEvent {
  const MovieDetailStarted(this.movieId);

  final int movieId;

  @override
  List<Object?> get props => [movieId];
}
