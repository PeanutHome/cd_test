import '../entities/movie_detail.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetailUseCase {
  const GetMovieDetailUseCase(this._repository);

  final MovieRepository _repository;

  Future<MovieDetail> call(int id) => _repository.getMovieDetail(id);
}
