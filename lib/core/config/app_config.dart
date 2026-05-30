import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const tmdbImageCdn = 'https://image.tmdb.org/t/p';

  static const _defineApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const _defineBaseUrl = String.fromEnvironment('TMDB_BASE_URL');

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get baseUrl {
    if (_defineBaseUrl.isNotEmpty) return _defineBaseUrl.trim();
    final fromEnv = dotenv.env['TMDB_BASE_URL']?.trim() ?? '';
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://api.themoviedb.org/3';
  }

  static String get apiKey {
    if (_defineApiKey.isNotEmpty) return _defineApiKey.trim();
    return dotenv.env['TMDB_API_KEY']?.trim() ?? '';
  }

  static bool get isConfigured => apiKey.isNotEmpty;

  /// TMDB image paths look like `/abc.jpg`. CDN is public — not loaded from secrets.
  static String imageUrl(String? path, String size) {
    if (path == null) return '';

    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$tmdbImageCdn/$size$normalizedPath';
  }
}
