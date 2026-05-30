import 'package:flutter/material.dart';

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Missing API key',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Copy .env.example to .env\n'
                  '2. Paste your TMDB v3 API key into TMDB_API_KEY\n'
                  '3. Restart the app',
                ),
                SizedBox(height: 12),
                Text(
                  'The key is read from the local .env file only. '
                  'It is gitignored and never committed to source code.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
