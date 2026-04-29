import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../shell/app_shell.dart';
import 'signup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    await _submit(
      action: () => _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    await _submit(
      action: _authService.signInWithGoogle,
    );
  }

  Future<void> _submit({
    required Future<UserCredential?> Function() action,
  }) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final result = await action();

      // User cancelled Google sign-in
      if (result == null) {
        if (mounted) {
          setState(() {
            _errorText = 'Google sign-in was cancelled.';
          });
        }
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AppShell(),
        ),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorText = _friendlyAuthError(e);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorText = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      default:
        return e.message ?? 'Unable to sign in right now.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFEBD1),
                Color(0xFFFFE4C4),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 345,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.1,
                          color: Color(0xFFC27A2B),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      const Text(
                        'Clarity for your skin.\nConfidence for your care.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFFD4915D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 48),

                      _AuthInputField(
                        controller: _emailController,
                        hintText: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email is required.';
                          }

                          if (!email.contains('@')) {
                            return 'Enter a valid email.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      _AuthInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Password is required.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      if (_errorText != null) ...[
                        Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      _PrimaryAuthButton(
                        label: 'Sign In',
                        loading: _isLoading,
                        onPressed:
                        _isLoading ? null : _handleEmailSignIn,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _AuthDivider(),

                      const SizedBox(height: AppSpacing.lg),

                      _SecondaryAuthButton(
                        label: 'Continue with Google',
                        onPressed:
                        _isLoading ? null : _handleGoogleSignIn,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A7569),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const SignUpScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                              const Color(0xFFA46A43),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFFB89B88),
        ),
        filled: true,
        fillColor: const Color(0xCCFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0x99FFFFFF),
            width: 0.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB8774A),
            Color(0xFFA46A43),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33A46A43),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x33A46A43),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAuthButton extends StatelessWidget {
  const _SecondaryAuthButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          56,
        ),
        backgroundColor: const Color(0xCCFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(
          color: Color(0x99FFFFFF),
          width: 0.6,
        ),
        foregroundColor: const Color(0xFF5A4A42),
      ),
      icon: SvgPicture.asset(
        'assets/auth/google.svg',
        width: 20,
        height: 20,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0x4DD4915D),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB89B88),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0x4DD4915D),
          ),
        ),
      ],
    );
  }
}