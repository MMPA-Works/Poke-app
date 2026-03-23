import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.registerPlayer(
        _nameController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8F7EF);
    const surfaceColor = Color(0xFFF7F6EE);
    const borderColor = Color(0xFFC6C9BA);
    const iconColor = Color(0xFF4F554A);
    const accentColor = Color(0xFF56B94F);
    const textColor = Color(0xFF262A24);
    const mutedGreen = Color(0xFF6F8D65);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        const _MonsterBallLogo(accentColor: accentColor),
                        const SizedBox(height: 18),
                        Text(
                          'Player Register',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 31,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _RegisterInput(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.badge,
                          textInputAction: TextInputAction.next,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          iconColor: iconColor,
                        ),
                        const SizedBox(height: 16),
                        _RegisterInput(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.person,
                          textInputAction: TextInputAction.next,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          iconColor: iconColor,
                        ),
                        const SizedBox(height: 16),
                        _RegisterInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            splashRadius: 20,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: iconColor,
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _isLoading ? null : _register(),
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          iconColor: iconColor,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style:
                                ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: surfaceColor,
                                  foregroundColor: mutedGreen,
                                  disabledBackgroundColor: surfaceColor,
                                  disabledForegroundColor: mutedGreen
                                      .withValues(alpha: 0.7),
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.08,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ).copyWith(
                                  shadowColor: WidgetStatePropertyAll(
                                    Colors.black.withValues(alpha: 0.08),
                                  ),
                                  elevation: const WidgetStatePropertyAll(0),
                                  overlayColor: WidgetStatePropertyAll(
                                    mutedGreen.withValues(alpha: 0.06),
                                  ),
                                ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: mutedGreen,
                                      valueColor: const AlwaysStoppedAnimation(
                                        mutedGreen,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: mutedGreen,
                                        ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: mutedGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: mutedGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              children: const [
                                TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterInput extends StatelessWidget {
  const _RegisterInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.surfaceColor,
    required this.borderColor,
    required this.iconColor,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Color surfaceColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF868B80),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: surfaceColor,
          prefixIcon: Icon(prefixIcon, color: iconColor),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8CAB7F), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _MonsterBallLogo extends StatelessWidget {
  const _MonsterBallLogo({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 6),
            ),
          ),
          Container(
            width: 54,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: accentColor, width: 6),
            ),
          ),
        ],
      ),
    );
  }
}
