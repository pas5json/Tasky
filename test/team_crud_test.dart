import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ags_flutter_starter/main.dart';
import 'package:ags_flutter_starter/screens/login_screen.dart';
import 'package:ags_flutter_starter/team_crud_template.dart';

void main() {
  setUp(() {
    // Each test starts with a fresh "disk" for SharedPreferences.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App opens on the Welcome shell', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Enter App'), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('Welcome shell rejects an empty name', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter App'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name to proceed.'), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('Welcome shell saves the name and opens the dashboard',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Student / User Name'), 'Gavenzzo');
    await tester.pumpAndSettle();
    // The button now offers to continue with the typed name.
    await tester.tap(find.text('Continue as Gavenzzo'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Logged In: Gavenzzo'), findsOneWidget);

    // Week 14: the name really landed on "disk".
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_name'), 'Gavenzzo');
  });

  testWidgets('Restart remembers the name and prefills the shell',
      (tester) async {
    SharedPreferences.setMockInitialValues({'user_name': 'Alex'});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The saved name is shown, and can still be replaced by another one.
    expect(find.text('Alex'), findsOneWidget);
    await tester.tap(find.text('Continue as Alex'));
    await tester.pumpAndSettle();

    expect(find.text('Logged In: Alex'), findsOneWidget);
  });

  testWidgets('Already logged in: restart reopens the dashboard directly',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'user_name': 'Alex', 'is_logged_in': true});

    await tester.pumpWidget(MyApp(home: await resolveStartScreen()));
    await tester.pumpAndSettle();

    // No name prompt on the second launch — straight into Alex's dashboard.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Logged In: Alex'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
  });

  testWidgets('Switch clears the login flag so the shell returns on restart',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'user_name': 'Alex', 'is_logged_in': true});

    await tester.pumpWidget(MyApp(home: await resolveStartScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in'), isFalse);
  });

  testWidgets('Switch user reopens the shell with the name prefilled',
      (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    // Previous login name is still there, ready to be edited.
    expect(find.text('Gavenzzo'), findsOneWidget);
    expect(find.text('Continue as Gavenzzo'), findsOneWidget);
  });

  testWidgets('E-mail + password login also lands on the dashboard',
      (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Phone'),
        'gavenzzo@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.tap(find.text('Log in / Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Logged In: gavenzzo'), findsOneWidget);
  });

  testWidgets('Dashboard shows chips, starter items and formatted dates',
      (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    // Category ChoiceChips from the customization zone.
    expect(find.widgetWithText(ChoiceChip, 'General'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Priority'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Review'), findsOneWidget);

    // Filter chips.
    expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Active'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Completed'), findsOneWidget);

    // Starter items are present.
    expect(find.text('Review Flutter sprint slides'), findsOneWidget);
    expect(find.text('Prepare team project demo'), findsOneWidget);

    // intl-formatted date (d MMM yyyy) is rendered for the selected day.
    final formatted = DateFormat('d MMM yyyy').format(DateTime.now());
    expect(find.text(formatted), findsWidgets);
  });

  testWidgets('Bell opens a list of the incomplete tasks', (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Incomplete Tasks (2)'), findsOneWidget);
    expect(find.text('Review Flutter sprint slides'), findsWidgets);
    expect(find.text('Prepare team project demo'), findsWidgets);
  });

  testWidgets('Dashboard rejects a blank item with a SnackBar', (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    final before = find.byType(ListTile).evaluate().length;

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Task'));
    await tester.pump();

    expect(find.text('Please enter a valid Task name!'), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, before);
  });

  testWidgets('Week 15 Create: adding an item appends it to the list',
      (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Enter a new task...'),
        'Submit sprint 3');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Submit sprint 3'), findsOneWidget);
  });

  testWidgets('Week 15 Delete: trash icon removes the tapped row',
      (tester) async {
    await tester.pumpWidget(
        const MyApp(home: DashboardScreen(initialUserName: 'Gavenzzo')));
    await tester.pumpAndSettle();

    const removed = 'Review Flutter sprint slides';
    expect(find.text(removed), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text(removed), findsNothing);
    expect(find.text('Prepare team project demo'), findsOneWidget);
  });
}
