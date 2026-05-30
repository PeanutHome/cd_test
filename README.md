# Movie Explorer

Offline-first Flutter app for the TMDB coding assessment.

## Setup

```bash
cp .env.example .env
# set TMDB_API_KEY in .env

flutter pub get
dart run build_runner build
flutter run
```

## Architecture

- **Domain** — entities, `MoviesRepository` contract, `LoadPopularMovies` use case (cache/network policy)
- **Data** — Retrofit API, typed Hive cache (`CachedPopularMovies`), `MoviesRepositoryImpl`
- **Presentation** — BLoC + list/detail screens

## Tests

```bash
flutter test
```
