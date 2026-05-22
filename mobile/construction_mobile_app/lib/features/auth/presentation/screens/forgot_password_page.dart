import 'dart:async';
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

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  bool _linkSent = false;
  Timer? _resendTimer;
  int _resendCountdown = 60;

  @override
  void dispose() {
    _emailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    await ref.read(authProvider.notifier).forgotPassword(
          _emailController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage == null) {
      setState(() {
        _successMessage = 'Reset link sent! Check your inbox and spam folder.';
        _linkSent = true;
      });
      _startResendCooldown();
    } else if (state.status == AuthStatus.error) {
      setState(() {
        _errorMessage = AuthErrorMessages.userMessage(
          state.errorMessage,
          fallback:
              'Failed to send reset link. Please check your email and try again.',
          context: 'forgot',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = authState.status == AuthStatus.loading;

    return AuthResponsiveLayout(
      form: AuthCard(
        title: l10n.forgotPassword,
        subtitle: l10n.forgotPasswordSubtitle,
        message: _errorMessage ?? _successMessage,
        messageType: _errorMessage != null
            ? AuthMessageType.error
            : AuthMessageType.success,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: l10n.sendResetLink,
                isLoading: isLoading,
                onPressed: isLoading ? null : _onSubmit,
              ),
              if (_linkSent) ...[
                const SizedBox(height: AppSpacing.lg),
                if (_resendCountdown > 0)
                  Center(
                    child: Text(
                      'Resend in ${_resendCountdown}s',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.secondaryTextFor(
                          Theme.of(context).brightness,
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : _onSubmit,
                      child: Text(
                        'Resend Link',
                        style: AppTextStyles.label.copyWith(
                          color: isLoading
                              ? AppColors.secondaryTextFor(
                                  Theme.of(context).brightness,
                                )
                              : AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (context.mounted) {
                        context.go(RouteNames.login);
                      }
                    });
                  },
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
