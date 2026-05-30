# Movie Explorer

Offline-first Flutter app that loads popular movies from [TMDB](https://www.themoviedb.org/).

## Setup

1. Get a free **TMDB v3 API key** from [TMDB settings](https://www.themoviedb.org/settings/api).
2. Copy the env template and add your key:

```bash
cp .env.example .env
# Edit .env and set TMDB_API_KEY=your_key_here
```

3. Install and generate code:

```bash
flutter pub get
dart run build_runner build
flutter run
```

The `.env` file is **gitignored**. Only `.env.example` is committed — your real key stays on your machine.

Alternative for CI/release builds:

```bash
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

## Architecture

- **Domain**: entities, repository contracts, use cases (pure Dart)
- **Data**: Retrofit API, Hive cache, repository implementation
- **Presentation**: BLoC + Material UI (list/grid toggle, pagination, pull-to-refresh)
