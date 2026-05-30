import 'package:flutter/material.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/config/config_error_app.dart';

Future<void> main() async {
  final container = await AppBootstrap.initialize();

  if (container == null) {
    runApp(const ConfigErrorApp());
    return;
  }

  runApp(MovieExplorerApp(container: container));
}
