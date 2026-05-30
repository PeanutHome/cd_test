import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/popular_movies_sync.dart';
import '../../../domain/usecases/load_popular_movies.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc(this._loadPopularMovies) : super(const MoviesInitial()) {
    on<MoviesStarted>(_onStarted);
    on<MoviesRefreshed>(_onRefreshed);
    on<MoviesLoadMore>(_onLoadMore);
    on<MoviesViewModeChanged>(_onViewModeChanged);
  }

  final LoadPopularMovies _loadPopularMovies;

  Future<void> _onStarted(
    MoviesStarted event,
    Emitter<MoviesState> emit,
  ) async {
    final cached = await _loadPopularMovies.readCache();
    final viewMode = _viewModeFrom(state);

    if (cached.isNotEmpty) {
      emit(
        MoviesSuccess(
          movies: cached,
          viewMode: viewMode,
          currentPage: _loadPopularMovies.cachedPage,
          totalPages: _loadPopularMovies.totalPages,
        ),
      );
    } else {
      emit(const MoviesLoading());
    }

    final sync = await _loadPopularMovies.syncFirstPage(replaceCache: false);
    _emitSync(emit, sync, viewMode);
  }

  Future<void> _onRefreshed(
    MoviesRefreshed event,
    Emitter<MoviesState> emit,
  ) async {
    final viewMode = _viewModeFrom(state);
    emit(const MoviesLoading());

    final sync = await _loadPopularMovies.forceRefresh();
    _emitSync(emit, sync, viewMode);
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

    emit(current.copyWith(isLoadingMore: true));

    final sync = await _loadPopularMovies.syncNextPage(
      nextPage: current.currentPage + 1,
    );

    if (sync.failed) {
      emit(current.copyWith(isLoadingMore: false, isOffline: sync.isOffline));
      return;
    }

    emit(
      current.copyWith(
        movies: sync.movies,
        currentPage: sync.page,
        totalPages: sync.totalPages,
        isLoadingMore: false,
        isOffline: sync.isOffline,
      ),
    );
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

  MoviesViewMode _viewModeFrom(MoviesState state) {
    return state is MoviesSuccess ? state.viewMode : MoviesViewMode.list;
  }

  void _emitSync(
    Emitter<MoviesState> emit,
    PopularMoviesSync sync,
    MoviesViewMode viewMode,
  ) {
    if (sync.failed) {
      emit(MoviesError(message: sync.errorMessage!, isOffline: sync.isOffline));
      return;
    }

    emit(
      MoviesSuccess(
        movies: sync.movies,
        viewMode: viewMode,
        currentPage: sync.page,
        totalPages: sync.totalPages,
        isOffline: sync.isOffline,
      ),
    );
  }
}
