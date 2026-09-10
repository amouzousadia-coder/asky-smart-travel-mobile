import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _isConfirmationVisible = false;
  bool _isResending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SecurityIllustration(),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Mot de passe oublié ?',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Saisissez l’adresse e-mail associée à votre compte. Nous vous enverrons les instructions pour réinitialiser votre mot de passe.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_isConfirmationVisible)
                  _ConfirmationCard(
                    isResending: _isResending,
                    onBackToLogin: _goToLogin,
                    onResend: _resendInstructions,
                  )
                else
                  _ForgotPasswordFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    isSubmitting: _isSubmitting,
                    onSubmit: _submit,
                    onBackToLogin: _goToLogin,
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

    // TODO: Remplacer cette simulation par l'endpoint Spring Boot forgot-password.
    // TODO: Le backend devra générer un token de réinitialisation à durée limitée.
    // TODO: Ne jamais révéler côté client ou API si l'adresse e-mail existe.
    // TODO: Ajouter du rate limiting côté backend pour limiter les abus.
    // TODO: Invalider le token de réinitialisation après son utilisation.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isConfirmationVisible = true;
    });
  }

  Future<void> _resendInstructions() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Instructions renvoyées.')));

    setState(() => _isResending = false);
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

class _SecurityIllustration extends StatelessWidget {
  const _SecurityIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 86,
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
        child: const Icon(
          Icons.mark_email_unread_outlined,
          color: AppColors.primary,
          size: 40,
        ),
      ),
    );
  }
}

class _ForgotPasswordFormCard extends StatelessWidget {
  const _ForgotPasswordFormCard({
    required this.formKey,
    required this.emailController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return _AuthCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => onSubmit(),
              validator: _validateEmail,
              decoration: InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PrimaryButton(
              label: isSubmitting ? 'Envoi...' : 'Envoyer les instructions',
              onPressed: isSubmitting ? null : onSubmit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onBackToLogin,
              child: const Text('Retour à la connexion'),
            ),
          ],
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

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.isResending,
    required this.onBackToLogin,
    required this.onResend,
  });

  final bool isResending;
  final VoidCallback onBackToLogin;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return _AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.secondary,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vérifiez votre boîte mail',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Si un compte est associé à cette adresse, vous recevrez les instructions nécessaires pour réinitialiser votre mot de passe.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PrimaryButton(
            label: 'Retour à la connexion',
            onPressed: onBackToLogin,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Vous n’avez rien reçu ?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: isResending ? null : onResend,
                child: Text(isResending ? 'Renvoi...' : 'Renvoyer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
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
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}
