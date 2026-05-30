import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_movie_detail.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc(this._getMovieDetail) : super(const MovieDetailInitial()) {
    on<MovieDetailStarted>(_onStarted);
  }

  final GetMovieDetailUseCase _getMovieDetail;

  Future<void> _onStarted(
    MovieDetailStarted event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(const MovieDetailLoading());
    try {
      final detail = await _getMovieDetail(event.movieId);
      emit(MovieDetailSuccess(detail));
    } catch (error) {
      emit(MovieDetailError(error.toString()));
    }
  }
}
