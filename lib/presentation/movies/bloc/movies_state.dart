import 'package:equatable/equatable.dart';

import '../../../domain/entities/movie.dart';

enum MoviesViewMode { list, grid }

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

class MoviesSuccess extends MoviesState {
  const MoviesSuccess({
    required this.movies,
    required this.viewMode,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.isOffline = false,
  });

  final List<Movie> movies;
  final MoviesViewMode viewMode;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool isOffline;

  bool get hasMore => currentPage < totalPages;

  MoviesSuccess copyWith({
    List<Movie>? movies,
    MoviesViewMode? viewMode,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isOffline,
  }) {
    return MoviesSuccess(
      movies: movies ?? this.movies,
      viewMode: viewMode ?? this.viewMode,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props =>
      [movies, viewMode, currentPage, totalPages, isLoadingMore, isOffline];
}

class MoviesError extends MoviesState {
  const MoviesError({required this.message, required this.isOffline});

  final String message;
  final bool isOffline;

  @override
  List<Object?> get props => [message, isOffline];
}
