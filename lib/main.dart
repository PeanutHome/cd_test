import 'package:flutter/material.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/config/config_error_app.dart';

Future<void> main() async {
  final deps = await AppBootstrap.initialize();

  if (deps == null) {
    runApp(const ConfigErrorApp());
    return;
  }

  runApp(MovieExplorerApp(deps: deps));
}
