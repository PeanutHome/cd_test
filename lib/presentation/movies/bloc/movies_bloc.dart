import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/network_failure.dart';
import '../../../domain/services/network_info.dart';
import '../../../domain/usecases/get_popular_movies.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc(this._getPopularMovies, this._networkInfo)
      : super(const MoviesInitial()) {
    on<MoviesStarted>(_onStarted);
    on<MoviesRefreshed>(_onRefreshed);
    on<MoviesLoadMore>(_onLoadMore);
    on<MoviesViewModeChanged>(_onViewModeChanged);
  }

  final GetPopularMoviesUseCase _getPopularMovies;
  final NetworkInfo _networkInfo;

  Future<void> _onStarted(
    MoviesStarted event,
    Emitter<MoviesState> emit,
  ) async {
    await _load(emit, page: 1, replaceCache: false, showLoadingWhenEmpty: true);
  }

  Future<void> _onRefreshed(
    MoviesRefreshed event,
    Emitter<MoviesState> emit,
  ) async {
    await _load(emit, page: 1, replaceCache: true, showLoadingWhenEmpty: false);
  }

  Future<void> _onLoadMore(
    MoviesLoadMore event,
    Emitter<MoviesState> emit,
  ) async {
    final current = state;
    if (current is! MoviesSuccess ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.isOffline) {
      return;
    }

    if (!await _networkInfo.isConnected) {
      emit(current.copyWith(isOffline: true));
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await _getPopularMovies.fetch(page: nextPage);
      emit(
        current.copyWith(
          movies: [...current.movies, ...result.movies],
          currentPage: result.page,
          totalPages: result.totalPages,
          isLoadingMore: false,
          isOffline: false,
        ),
      );
    } catch (error) {
      emit(
        current.copyWith(
          isLoadingMore: false,
          isOffline: NetworkFailure.from(error).isOffline,
        ),
      );
    }
  }

  void _onViewModeChanged(
    MoviesViewModeChanged event,
    Emitter<MoviesState> emit,
  ) {
    final current = state;
    if (current is MoviesSuccess) {
      emit(current.copyWith(viewMode: event.viewMode));
    }
  }

  Future<void> _load(
    Emitter<MoviesState> emit, {
    required int page,
    required bool replaceCache,
    required bool showLoadingWhenEmpty,
  }) async {
    final cached = await _getPopularMovies.getCached();
    final viewMode = state is MoviesSuccess
        ? (state as MoviesSuccess).viewMode
        : MoviesViewMode.list;

    if (cached.isNotEmpty) {
      emit(
        MoviesSuccess(
          movies: cached,
          viewMode: viewMode,
          currentPage: _getPopularMovies.cachedPage,
          totalPages: _getPopularMovies.totalPages,
        ),
      );
    } else if (showLoadingWhenEmpty) {
      emit(const MoviesLoading());
    }

    if (!await _networkInfo.isConnected) {
      if (cached.isNotEmpty) {
        emit(
          MoviesSuccess(
            movies: cached,
            viewMode: viewMode,
            currentPage: _getPopularMovies.cachedPage,
            totalPages: _getPopularMovies.totalPages,
            isOffline: true,
          ),
        );
      } else {
        emit(
          const MoviesError(
            message:
                'You are offline and no saved movies were found. Connect to the internet and pull to refresh.',
            isOffline: true,
          ),
        );
      }
      return;
    }

    try {
      final result = await _getPopularMovies.fetch(
        page: page,
        replaceCache: replaceCache,
      );
      final movies = replaceCache || cached.isEmpty
          ? result.movies
          : await _getPopularMovies.getCached();
      emit(
        MoviesSuccess(
          movies: movies,
          viewMode: viewMode,
          currentPage: replaceCache || cached.isEmpty
              ? result.page
              : _getPopularMovies.cachedPage,
          totalPages: result.totalPages,
          isOffline: false,
        ),
      );
    } catch (error) {
      final failure = NetworkFailure.from(error);
      if (cached.isNotEmpty) {
        emit(
          MoviesSuccess(
            movies: cached,
            viewMode: viewMode,
            currentPage: _getPopularMovies.cachedPage,
            totalPages: _getPopularMovies.totalPages,
            isOffline: failure.isOffline,
          ),
        );
      } else {
        emit(
          MoviesError(
            message: failure.message,
            isOffline: failure.isOffline,
          ),
        );
      }
    }
  }
}
