import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../../../settings/presentation/controllers/settings_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _hasNavigated = false;
    });

    if (kDebugMode) {
      debugPrint(
          'LoginPage: Calling login for ${_emailController.text.trim()}');
    }

    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    // Error handling is done via listener, but we also set error message for UI
    final state = ref.read(authProvider);
    if (state.status == AuthStatus.error) {
      if (kDebugMode) {
        debugPrint('LoginPage: Login failed with error: ${state.errorMessage}');
      }
      setState(() {
        _errorMessage = AuthErrorMessages.userMessage(
          state.errorMessage,
          fallback:
              'Login failed. Please check your email and password and try again.',
          context: 'login',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final settings = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    // Listen for auth state changes and navigate when authenticated
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated &&
          !_hasNavigated) {
        if (kDebugMode) {
          debugPrint(
              'LoginPage: Auth state changed to authenticated, navigating to projects');
          debugPrint(
              'LoginPage: Previous state: ${previous?.status}, Next state: ${next.status}');
        }
        _hasNavigated = true;
        if (context.mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              debugPrint('LoginPage: Navigating to: ${RouteNames.projects}');
              context.go(RouteNames.projects);
            }
          });
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          AuthResponsiveLayout(
            form: AuthCard(
              title: l10n.welcomeBack,
              subtitle: l10n.loginSubtitle,
              message: _errorMessage,
              messageType: AuthMessageType.error,
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
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.password,
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterPassword;
                        }
                        if (value.length < 6) return l10n.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go(RouteNames.forgotPassword),
                        child: Text(
                          l10n.forgotPassword,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: l10n.signIn,
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: _onLogin,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.secondaryTextFor(
                              Theme.of(context).brightness,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteNames.register),
                          child: Text(l10n.signUp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Language dropdown at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.lg,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: settings.locale,
                    icon: const Icon(Icons.language, size: 20),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryTextFor(Theme.of(context).brightness),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('am'),
                        child: Text('አማርኛ'),
                      ),
                    ],
                    onChanged: (Locale? newLocale) async {
                      if (newLocale != null) {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(settingsControllerProvider.notifier).setLocale(newLocale);
                        final languageName = newLocale.languageCode == 'en' ? 'English' : 'አማርኛ';
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.languageChanged(languageName)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
