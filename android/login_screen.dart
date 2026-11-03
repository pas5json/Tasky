import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'tasks_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Same strong-password helpers/policy as SignUpScreen -----------------

  static bool _hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);
  static bool _hasLowercase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);
  static bool _hasDigit(String password) => RegExp(r'[0-9]').hasMatch(password);
  static bool _hasSpecialCharacter(String password) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  /// Identical policy to the Sign Up screen: at least 8 characters with an
  /// uppercase letter, a lowercase letter, a number, and a special character.
  static String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_hasUppercase(password)) {
      return 'Add at least one uppercase letter (A-Z)';
    }
    if (!_hasLowercase(password)) {
      return 'Add at least one lowercase letter (a-z)';
    }
    if (!_hasDigit(password)) {
      return 'Add at least one number (0-9)';
    }
    if (!_hasSpecialCharacter(password)) {
      return r'Add at least one special character (!@#$%...)';
    }
    return null;
  }

  /// Every password rule with whether [password] satisfies it — drives the
  /// live requirements checklist under the password field.
  static List<MapEntry<String, bool>> _passwordRules(String password) => [
        MapEntry('At least 8 characters', password.length >= 8),
        MapEntry('One uppercase letter (A-Z)', _hasUppercase(password)),
        MapEntry('One lowercase letter (a-z)', _hasLowercase(password)),
        MapEntry('One number (0-9)', _hasDigit(password)),
        MapEntry(
            r'One special character (!@#$%...)', _hasSpecialCharacter(password)),
      ];

  String? _validateEmail(String? value) {
    final identifier = value?.trim() ?? '';
    if (identifier.isEmpty) {
      return 'Please enter your email or phone';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    final phoneRegex = RegExp(r'^\+?\d{9,15}$');
    if (!emailRegex.hasMatch(identifier) && !phoneRegex.hasMatch(identifier)) {
      return 'Enter a valid email or phone number';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  /// Lifecycle: create both text controllers before the first build.
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  /// Lifecycle: release the controllers when this screen leaves the tree.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TasksScreen(
          username: _emailController.text.trim(),
          isLoggedIn: true,
        ),
      ),
    );
  }

  /// Live requirements checklist under the login password field, mirroring
  /// the Sign Up policy. Fades in once the user starts typing; a green tick
  /// means that rule is satisfied. Once every rule passes, it collapses away.
  Widget _buildPasswordChecklist() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    final allMet = _passwordRules(password).every((rule) => rule.value);
    if (allMet) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._passwordRules(password).map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    rule.value
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14,
                    color: rule.value
                        ? const Color(0xFFB8E6DC)
                        : Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rule.key,
                      style: TextStyle(
                        fontSize: 11,
                        color: rule.value
                            ? const Color(0xFFB8E6DC)
                            : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB8E6DC)),
      prefixIcon: Icon(icon, color: const Color(0xFFB8E6DC)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB8E6DC), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB8E6DC), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF3FA499),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 420 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 24,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8E6DC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Color(0xFF3FA499),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tasky',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4A574),
                      ),
                    ),
                    const Text(
                      'TO-DO-LIST APP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB8E6DC),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Email or Phone', Icons.person),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      onChanged: (_) => setState(() {}),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Password', Icons.lock)
                          .copyWith(
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFB8E6DC),
                          ),
                        ),
                      ),
                    ),
                    _buildPasswordChecklist(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFFB8E6DC),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFB8E6DC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8E6DC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Log in / Sign up',
                          style: TextStyle(
                            color: Color(0xFF3FA499),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFB8E6DC)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or',
                              style: TextStyle(
                                  color: Color(0xFFB8E6DC).withValues(alpha: 0.9))),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFB8E6DC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TasksScreen(isLoggedIn: false),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Color(0xFFB8E6DC), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continue without an account',
                          style: TextStyle(
                            color: Color(0xFFB8E6DC),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Color(0xFFB8E6DC), fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(
                                    onAccountCreated: (name, email) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TasksScreen(
                                            username: name,
                                            isLoggedIn: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFFD4A574),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFD4A574),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
