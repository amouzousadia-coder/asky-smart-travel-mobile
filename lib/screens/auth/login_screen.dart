import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      body: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canGoBack) ...[
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const _LoginBrandHeader(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Bienvenue',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connectez-vous pour retrouver vos voyages et profiter de votre espace personnel.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                _LoginFormCard(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  passwordFocusNode: _passwordFocusNode,
                  obscurePassword: _obscurePassword,
                  isSubmitting: _isSubmitting,
                  onTogglePasswordVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion de démonstration réussie.')),
    );

    // TODO: Remplacer cette simulation par l'appel au backend Spring Boot/JWT.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }
}

class _LoginBrandHeader extends StatelessWidget {
  const _LoginBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: const Icon(
            Icons.flight_takeoff,
            color: AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'ASKY Smart Travel',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
          ),
        ),
      ],
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EmailField(
              controller: emailController,
              onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.md),
            _PasswordField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscurePassword: obscurePassword,
              onToggleVisibility: onTogglePasswordVisibility,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.forgotPassword),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _LoginButton(isSubmitting: isSubmitting, onPressed: onSubmit),
            const SizedBox(height: AppSpacing.lg),
            const _RegisterPrompt(),
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.onFieldSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onFieldSubmitted: onFieldSubmitted,
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'Adresse e-mail',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Veuillez saisir votre adresse e-mail.';

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Veuillez saisir une adresse e-mail valide.';
    }

    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: onFieldSubmitted,
      validator: _validatePassword,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: obscurePassword
              ? 'Afficher le mot de passe'
              : 'Masquer le mot de passe',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Veuillez saisir votre mot de passe.';
    return null;
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isSubmitting, required this.onPressed});

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.55),
        disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.65),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Text(
        isSubmitting ? 'Connexion...' : 'Se connecter',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Vous n’avez pas encore de compte ?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}
