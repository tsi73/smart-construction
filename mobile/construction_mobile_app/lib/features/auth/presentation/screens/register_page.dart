import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_responsive_layout.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/auth_error_messages.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    // Prevent double submit
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.loading) return;

    setState(() => _errorMessage = null);
    final phoneNumber = _phoneController.text.trim();

    await ref.read(authProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        );

    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.status == AuthStatus.unauthenticated ||
        state.status == AuthStatus.authenticated) {
      if (state.errorMessage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please sign in.'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(RouteNames.login);
        }
      }
    } else if (state.status == AuthStatus.error) {
      setState(() {
        _errorMessage = AuthErrorMessages.userMessage(
          state.errorMessage,
          fallback: AppLocalizations.of(context)!.registrationFailed,
          context: 'register',
        );
      });
    }
  }

  bool _isValidEthiopianPhone(String value) {
    if (value.isEmpty) return true;
    final compact = value.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^(\+251|0)?9\d{8}$').hasMatch(compact);
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    // Check for special characters using individual character checks to avoid regex escaping issues
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    bool hasSpecialChar = false;
    for (var char in specialChars.split('')) {
      if (value.contains(char)) {
        hasSpecialChar = true;
        break;
      }
    }
    if (!hasSpecialChar) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return AuthResponsiveLayout(
      form: AuthCard(
        title: l10n.createAccount,
        subtitle: l10n.signupSubtitle,
        message: _errorMessage,
        messageType: AuthMessageType.error,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.fullName,
                hint: l10n.fullName,
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.email,
                hint: 'name@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterEmail;
                  }
                  if (!value.contains('@')) return l10n.pleaseEnterValidEmail;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.phoneNumber,
                hint: '+251 912 345 678',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (!_isValidEthiopianPhone(value?.trim() ?? '')) {
                    return l10n.invalidPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.password,
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.confirmPassword,
                hint: '••••••••',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_reset_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseConfirmPassword;
                  }
                  if (value != _passwordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: l10n.createAccount,
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _onRegister,
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.secondaryTextFor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
