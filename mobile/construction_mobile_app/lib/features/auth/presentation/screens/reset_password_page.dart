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

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordPage({super.key, this.token});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    final token = widget.token?.trim() ?? '';
    if (token.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Reset link is missing or invalid. Please request a new one.';
      });
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(
          token: token,
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage == null) {
      setState(() {
        _isLoading = false;
        _successMessage = AppLocalizations.of(context)!.resetPasswordSuccess;
      });
    } else if (state.status == AuthStatus.error) {
      setState(() {
        _isLoading = false;
        _errorMessage = AuthErrorMessages.userMessage(
          state.errorMessage,
          fallback:
              'Could not reset your password. Please request a new reset link.',
          context: 'reset',
        );
      });
    } else {
      setState(() => _isLoading = false);
    }
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
    final l10n = AppLocalizations.of(context)!;
    final message = _errorMessage ?? _successMessage;
    final messageType =
        _errorMessage != null ? AuthMessageType.error : AuthMessageType.success;

    return AuthResponsiveLayout(
      form: AuthCard(
        title: l10n.resetPassword,
        subtitle: l10n.resetPasswordSubtitle,
        message: message,
        messageType: messageType,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.newPassword,
                hint: '8+ chars, 1 uppercase, 1 number, 1 special (!@#\$%^&* etc)',
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
                text: l10n.resetPassword,
                isLoading: _isLoading,
                onPressed: _onSubmit,
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go(RouteNames.login),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    l10n.backToSignIn,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
