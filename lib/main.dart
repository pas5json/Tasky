import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ags_flutter_starter/team_crud_template.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(home: await resolveStartScreen()));
}

/// Decides the first screen shown when the app opens.
///
/// Week 14 storage: if the last session was logged in, the saved name is
/// reused and the dashboard opens straight away (no name prompt again).
/// Otherwise the Tier 1 shell is shown, prefilled with the last name.
Future<Widget> resolveStartScreen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(loggedInKey) ?? false;
    final savedName = prefs.getString(userNameKey)?.trim();
    if (isLoggedIn && savedName != null && savedName.isNotEmpty) {
      return DashboardScreen(initialUserName: savedName);
    }
  } catch (_) {}
  return const WelcomeScreen();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.black,
      ),
      home: home ?? const WelcomeScreen(),
    );
  }
}
