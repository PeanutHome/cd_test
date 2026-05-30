import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../domain/entities/cast_member.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/get_movie_detail.dart';
import '../bloc/detail/movie_detail_bloc.dart';
import '../bloc/detail/movie_detail_event.dart';
import '../bloc/detail/movie_detail_state.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.getMovieDetail,
  });

  final Movie movie;
  final GetMovieDetailUseCase getMovieDetail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MovieDetailBloc(getMovieDetail)..add(MovieDetailStarted(movie.id)),
      child: _MovieDetailView(movie: movie),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailBloc, MovieDetailState>(
      builder: (context, state) {
        final loading = state is MovieDetailLoading;
        final detail = state is MovieDetailSuccess ? state.detail : null;
        final apiError = state is MovieDetailError ? state.message : null;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: _DetailBody(
            title: detail?.title ?? movie.title,
            overview: detail?.overview ?? movie.overview,
            rating: detail?.voteAverage ?? movie.voteAverage,
            releaseDate: detail?.releaseDate ?? movie.releaseDate,
            backdropPath: detail?.backdropPath ?? movie.backdropPath,
            posterPath: detail?.posterPath ?? movie.posterPath,
            genres: detail?.genres ?? const [],
            cast: detail?.cast ?? const [],
            runtime: detail?.runtime,
            loading: loading,
            apiError: apiError,
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.title,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.backdropPath,
    required this.posterPath,
    required this.genres,
    required this.cast,
    required this.runtime,
    required this.loading,
    this.apiError,
  });

  final String title;
  final String overview;
  final double rating;
  final String? releaseDate;
  final String? backdropPath;
  final String? posterPath;
  final List<String> genres;
  final List<CastMember> cast;
  final int? runtime;
  final bool loading;
  final String? apiError;

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: MovieImage(
                        path: backdropPath,
                        size: 'w780',
                        fit: BoxFit.cover,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            AppTheme.background,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: -36,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MovieImage(
                        path: posterPath,
                        size: 'w342',
                        width: 96,
                        height: 144,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RatingBadge(rating: rating),
                    if (releaseDate != null && releaseDate!.isNotEmpty)
                      _MetaChip(releaseDate!),
                    if (runtime != null) _MetaChip(_formatRuntime(runtime)),
                  ],
                ),
                if (loading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(color: AppTheme.accent),
                ],
                if (apiError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Could not load full details. Check your connection or API key.',
                      style: TextStyle(color: Colors.red.shade100, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const SectionTitle('Genres'),
                const SizedBox(height: 10),
                _GenresSection(loading: loading, genres: genres),
                const SizedBox(height: 24),
                const SectionTitle('Overview'),
                const SizedBox(height: 10),
                Text(
                  overview.isEmpty ? 'No overview available.' : overview,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Cast'),
                const SizedBox(height: 12),
                _CastSection(loading: loading, cast: cast),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}

class _GenresSection extends StatelessWidget {
  const _GenresSection({required this.loading, required this.genres});

  final bool loading;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    if (loading && genres.isEmpty) {
      return const SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
          ),
        ),
      );
    }

    if (genres.isEmpty) {
      return const Text('No genres available.', style: TextStyle(color: AppTheme.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) => Chip(label: Text(genre))).toList(),
    );
  }
}

class _CastSection extends StatelessWidget {
  const _CastSection({required this.loading, required this.cast});

  final bool loading;
  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    if (loading && cast.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
        ),
      );
    }

    if (cast.isEmpty) {
      return const Text('No cast information available.', style: TextStyle(color: AppTheme.textMuted));
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: 100,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MovieImage(
                    path: member.profilePath,
                    size: 'w185',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
                ),
                Text(
                  member.character,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
