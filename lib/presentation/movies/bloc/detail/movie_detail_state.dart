import 'package:equatable/equatable.dart';

import '../../../../domain/entities/movie_detail.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailSuccess extends MovieDetailState {
  const MovieDetailSuccess(this.detail);

  final MovieDetail detail;

  @override
  List<Object?> get props => [detail];
}

class MovieDetailError extends MovieDetailState {
  const MovieDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
