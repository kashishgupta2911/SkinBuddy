import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../shell/app_shell.dart';
import 'login_screen.dart';

const List<String> _ageRanges = [
  'Under 18',
  '18-29',
  '30-39',
  '40-49',
  '50-59',
  '60-69',
  '70-79',
  '80+',
];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorText;
  String? _ageRange;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ageRange == null) {
      setState(() {
        _errorText = 'Please select your age range.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await _authService.createUserWithEmailAndPassword(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        ageRange: _ageRange!,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = _friendlyAuthError(e);
      });
    } catch (_) {
      setState(() {
        _errorText = 'Unable to create your account right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await _authService.signInWithGoogle();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = _friendlyAuthError(e);
      });
    } catch (_) {
      setState(() {
        _errorText = 'Unable to continue with Google.';
      });
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
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Use a stronger password (at least 6 characters).';
      default:
        return e.message ?? 'Unable to create account right now.';
    }
  }

  Widget _buildUnder18Disclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8D0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB8703A).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB8703A),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A4A42),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Age Notice: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'This tool is currently designed for adult skin conditions (18+). '
                        'For children and teenagers, professional medical evaluation is recommended.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x99FFFFFF),
          width: 0.6,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _ageRange,
          hint: const Text(
            'Select age range',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFB89B88),
              fontWeight: FontWeight.w400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFA46A43),
          ),
          items: _ageRanges.map((range) {
            return DropdownMenuItem<String>(
              value: range,
              child: Text(
                range,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5A4A42),
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _ageRange = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Join SkinBuddy',
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
                        'Helpful support for your skin.\nConfidence for your care.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFFD4915D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _firstNameController,
                              hintText: 'First name',
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InputField(
                              controller: _lastNameController,
                              hintText: 'Last name',
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      _InputField(
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

                      _buildAgeRangeField(),

                      if (_ageRange == 'Under 18') ...[
                        const SizedBox(height: AppSpacing.sm),
                        _buildUnder18Disclaimer(),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      _InputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return 'Minimum 6 characters.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      _InputField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm password',
                        obscureText: true,
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Confirm your password.';
                          }

                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
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

                      _PrimaryButton(
                        label: 'Create Account',
                        loading: _isLoading,
                        onPressed:
                        _isLoading ? null : _handleCreateAccount,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _OrDivider(),

                      const SizedBox(height: AppSpacing.lg),

                      OutlinedButton.icon(
                        onPressed:
                        _isLoading ? null : _handleGoogleSignIn,
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
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A7569),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.of(context)
                                  .pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const LoginScreen(),
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
                              'Login',
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

class _InputField extends StatelessWidget {
  const _InputField({
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

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