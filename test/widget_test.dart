// Standard Flutter layout: app code lives in lib/, package: imports resolve.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ags_flutter_starter/main.dart';
import 'package:ags_flutter_starter/screens/forgot_password_screen.dart';
import 'package:ags_flutter_starter/screens/login_screen.dart';
import 'package:ags_flutter_starter/screens/signup_screen.dart';
import 'package:ags_flutter_starter/team_crud_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Unit tests need a fake disk for shared_preferences.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login screen shows inline validation errors when empty',
      (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    // Submit the empty form.
    await tester.tap(find.text('Log in / Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email or phone'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Login rejects weak passwords with the same policy as Sign Up',
      (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Phone'),
        'veronica@example.com');
    // 3-char password: rejected on login exactly like on sign up.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'abc');
    await tester.tap(find.text('Log in / Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'),
        findsOneWidget);
    // The live requirements checklist shows which rules are unmet.
    expect(find.text('One uppercase letter (A-Z)'), findsOneWidget);
    expect(find.text(r'One special character (!@#$%...)'), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);

    // Fixing the password lets the login through.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.pumpAndSettle();
    // Checklist collapses once every rule is satisfied.
    expect(find.text('One uppercase letter (A-Z)'), findsNothing);

    await tester.tap(find.text('Log in / Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Valid login navigates to the dashboard with the username',
      (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email or Phone'),
        'veronica@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.tap(find.text('Log in / Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Logged In: veronica'), findsOneWidget);
  });

  testWidgets('Switch user returns to the welcome shell',
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

    // Log out from the dashboard app bar.
    await tester.tap(find.byTooltip('Switch User (Shell)'));
    await tester.pumpAndSettle();

    // Back on the welcome shell with the name prefilled.
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('Forgot Password validates the email inline', (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    // Empty submit -> inline error.
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address'), findsOneWidget);

    // Invalid format -> inline error, no snackbar sent.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your Email'), 'abc');
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email (e.g. name@example.com)'),
        findsOneWidget);

    // Valid email -> confirmation and back to login.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your Email'),
        'veronica@example.com');
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Reset instructions sent to veronica@example.com'),
        findsOneWidget);
  });

  testWidgets('Sign up screen validates all fields and passes data to menu',
      (tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    // Go to the Sign Up screen (link is at the bottom -> scroll to it first).
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);

    // Submit with everything empty -> inline errors under every field.
    await tester.ensureVisible(find.text('Sign Up').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email address'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(find.text('Please retype your password'), findsOneWidget);

    // Fill in invalid values first.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Ve');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'), 'not-an-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Retype Password'), '456');
    await tester.ensureVisible(find.text('Sign Up').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();

    expect(find.text('Name must be at least 3 characters'), findsOneWidget);
    expect(find.text('Please enter a valid email (e.g. name@example.com)'),
        findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    // Weak password: long enough, but no uppercase and no special character.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Retype Password'), 'password123');
    await tester.ensureVisible(find.text('Sign Up').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();

    expect(find.text('Add at least one uppercase letter (A-Z)'),
        findsOneWidget);
    // The live checklist flags the rules that are still unmet.
    expect(find.text('One uppercase letter (A-Z)'), findsOneWidget);
    expect(find.text(r'One special character (!@#$%...)'), findsOneWidget);

    // Now a strong password that passes every rule.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Veronica Tan');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'veronica@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Retype Password'), 'Password123!');
    await tester.pump();

    // The strength meter reacts live and rates it as Strong.
    expect(find.text('Strong'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign Up').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();

    // Registration data (name) is passed forward into the menu screen.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Logged In: Veronica'), findsOneWidget);
  });
}
