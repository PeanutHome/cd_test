import 'package:equatable/equatable.dart';

import 'movies_state.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

class MoviesStarted extends MoviesEvent {
  const MoviesStarted();
}

class MoviesRefreshed extends MoviesEvent {
  const MoviesRefreshed();
}

class MoviesLoadMore extends MoviesEvent {
  const MoviesLoadMore();
}

class MoviesViewModeChanged extends MoviesEvent {
  const MoviesViewModeChanged(this.viewMode);

  final MoviesViewMode viewMode;

  @override
  List<Object?> get props => [viewMode];
}
