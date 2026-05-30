import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/get_movie_detail.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../widgets/movie_tile.dart';
import '../widgets/offline_banner.dart';
import 'movie_detail_page.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key, required this.getMovieDetail});

  final GetMovieDetailUseCase getMovieDetail;

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = context.read<MoviesBloc>().state;
    if (state is! MoviesSuccess || state.isOffline) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= maxScroll - 200) {
      context.read<MoviesBloc>().add(const MoviesLoadMore());
    }
  }

  void _openDetail(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailPage(
          movie: movie,
          getMovieDetail: widget.getMovieDetail,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<MoviesBloc>().add(const MoviesRefreshed());
    await context.read<MoviesBloc>().stream.firstWhere(
          (state) => state is! MoviesLoading && state is! MoviesInitial,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.accent,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(state),
                if (state is MoviesSuccess && state.isOffline)
                  const SliverToBoxAdapter(child: OfflineBanner()),
                if (state is MoviesInitial || state is MoviesLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  )
                else if (state is MoviesError)
                  SliverFillRemaining(
                    child: OfflineEmptyState(
                      message: state.message,
                      isOffline: state.isOffline,
                    ),
                  )
                else if (state is MoviesSuccess)
                  state.viewMode == MoviesViewMode.list
                      ? _buildList(state)
                      : _buildGrid(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(MoviesState state) {
    final viewMode =
        state is MoviesSuccess ? state.viewMode : MoviesViewMode.list;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: const Text(
          'Popular Movies',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.background,
                AppTheme.surface,
                AppTheme.background,
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (state is MoviesSuccess)
          IconButton(
            tooltip: viewMode == MoviesViewMode.list ? 'Grid view' : 'List view',
            icon: Icon(
              viewMode == MoviesViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            onPressed: () {
              context.read<MoviesBloc>().add(
                    MoviesViewModeChanged(
                      viewMode == MoviesViewMode.list
                          ? MoviesViewMode.grid
                          : MoviesViewMode.list,
                    ),
                  );
            },
          ),
      ],
    );
  }

  Widget _buildList(MoviesSuccess state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= state.movies.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            );
          }

          final movie = state.movies[index];
          return MovieListTile(movie: movie, onTap: () => _openDetail(movie));
        },
        childCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildGrid(MoviesSuccess state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.movies.length) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              );
            }

            final movie = state.movies[index];
            return MovieGridTile(movie: movie, onTap: () => _openDetail(movie));
          },
          childCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}
