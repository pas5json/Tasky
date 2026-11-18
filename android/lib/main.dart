// Legacy entry point.
//
// All app code now lives in the project-root `lib/` folder. This file exists
// only so an older IDE run configuration that still points here launches the
// same, current app instead of a stale copy.
import 'package:flutter/material.dart';

import 'package:ags_flutter_starter/main.dart' as app;

void main() {
  runApp(const app.MyApp());
}
