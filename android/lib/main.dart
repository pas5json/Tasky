// Legacy entry point kept only for an older IDE run configuration that still
// points at android/lib/main.dart. All app code lives in the project-root
// `lib/` folder, so this delegates to that real entry point instead of
// rebuilding the app from scratch — that way the saved session and the
// "logged in" flag are honoured exactly as in `flutter run`.
import 'package:ags_flutter_starter/main.dart' as app;

void main() => app.main();
