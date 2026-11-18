import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final void Function(String name, String email) onAccountCreated;

  const SignUpScreen({super.key, required this.onAccountCreated});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- Shared strong-password helpers (same rules as LoginScreen) ---------

  static bool _hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);
  static bool _hasLowercase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);
  static bool _hasDigit(String password) => RegExp(r'[0-9]').hasMatch(password);
  static bool _hasSpecialCharacter(String password) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  /// Password policy used by BOTH the Sign Up and Login screens:
  /// at least 8 characters with an uppercase letter, a lowercase letter,
  /// a number, and a special character.
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

  static int _strengthScore(String password) {
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (_hasUppercase(password) && _hasLowercase(password)) score++;
    if (_hasDigit(password)) score++;
    if (_hasSpecialCharacter(password)) score++;
    return score;
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Please enter your full name';
    }
    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email (e.g. name@example.com)';
    }
    return null;
  }

  String? _validateRetypePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please retype your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _retypePasswordController;
  bool _obscurePassword = true;
  bool _obscureRetype = true;

  /// Lifecycle: create all four text controllers before the first build.
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _retypePasswordController = TextEditingController();
  }

  /// Lifecycle: release the controllers when this screen leaves the tree.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }



  /// Live feedback under the password field: a strength meter plus a
  /// requirements checklist that ticks off each rule as the user types.
  Widget _buildPasswordStrengthAndChecklist() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    final score = _strengthScore(password);
    String strengthLabel;
    Color strengthColor;
    if (score <= 1) {
      strengthLabel = 'Weak';
      strengthColor = const Color(0xFFEF9A9A);
    } else if (score == 2) {
      strengthLabel = 'Fair';
      strengthColor = const Color(0xFFFFCC80);
    } else if (score == 3) {
      strengthLabel = 'Good';
      strengthColor = const Color(0xFFFFF59D);
    } else {
      strengthLabel = 'Strong';
      strengthColor = const Color(0xFFA5D6A7);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index == 4 ? 8 : 4),
                        decoration: BoxDecoration(
                          color:
                              index < score ? strengthColor : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                strengthLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    widget.onAccountCreated(
      _nameController.text.trim(),
      _emailController.text.trim(),
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
            constraints: BoxConstraints(maxWidth: isWide ? 480 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 24,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Let's Create Your Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      autocorrect: false,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Full Name', Icons.person),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Email Address', Icons.email),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      onChanged: (_) => setState(() {}),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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
                    _buildPasswordStrengthAndChecklist(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _retypePasswordController,
                      validator: _validateRetypePassword,
                      obscureText: _obscureRetype,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          'Retype Password', Icons.lock_rounded)
                          .copyWith(
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureRetype = !_obscureRetype),
                          icon: Icon(
                            _obscureRetype
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFB8E6DC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF3FA499),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Have an account? ',
                            style: TextStyle(
                                color: Color(0xFFB8E6DC), fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFFD4A574),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
