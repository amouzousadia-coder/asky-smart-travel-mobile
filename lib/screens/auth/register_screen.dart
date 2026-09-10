import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  DateTime? _birthDate;
  String _nationality = _nationalities.first;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  static const List<String> _nationalities = [
    'Togolaise',
    'Ghanéenne',
    'Béninoise',
    'Ivoirienne',
    'Sénégalaise',
    'Nigériane',
    'Camerounaise',
    'Gabonaise',
    'Kényane',
    'Autre',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                Text(
                  'Créer un compte',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Créez votre espace personnel pour retrouver vos voyages et profiter d’un accompagnement personnalisé.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                _RegisterFormCard(
                  formKey: _formKey,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  lastNameFocusNode: _lastNameFocusNode,
                  emailFocusNode: _emailFocusNode,
                  phoneFocusNode: _phoneFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  confirmPasswordFocusNode: _confirmPasswordFocusNode,
                  birthDate: _birthDate,
                  nationalities: _nationalities,
                  nationality: _nationality,
                  acceptedTerms: _acceptedTerms,
                  showTermsError: _showTermsError,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  isSubmitting: _isSubmitting,
                  onBirthDateTap: _selectBirthDate,
                  onNationalityChanged: (value) {
                    if (value == null) return;
                    setState(() => _nationality = value);
                  },
                  onTermsChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                      if (_acceptedTerms) _showTermsError = false;
                    });
                  },
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onToggleConfirmPassword: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
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

  Future<void> _selectBirthDate() async {
    final today = DateTime.now();
    final initialDate =
        _birthDate ?? DateTime(today.year - 18, today.month, today.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
    );

    if (selectedDate == null) return;

    setState(() => _birthDate = selectedDate);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) return;

    final formIsValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);

    if (!formIsValid || !_acceptedTerms) return;

    setState(() => _isSubmitting = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte de démonstration créé avec succès.'),
      ),
    );

    // TODO: Remplacer cette simulation par l'inscription via le backend Spring Boot.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }
}

class _RegisterFormCard extends StatelessWidget {
  const _RegisterFormCard({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.lastNameFocusNode,
    required this.emailFocusNode,
    required this.phoneFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.birthDate,
    required this.nationalities,
    required this.nationality,
    required this.acceptedTerms,
    required this.showTermsError,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.onBirthDateTap,
    required this.onNationalityChanged,
    required this.onTermsChanged,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode lastNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final DateTime? birthDate;
  final List<String> nationalities;
  final String nationality;
  final bool acceptedTerms;
  final bool showTermsError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final VoidCallback onBirthDateTap;
  final ValueChanged<String?> onNationalityChanged;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
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
      child: Material(
        color: Colors.transparent,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TextInputField(
                controller: firstNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => lastNameFocusNode.requestFocus(),
                validator: (value) =>
                    _requiredValidator(value, 'Veuillez saisir votre prénom.'),
              ),
              const SizedBox(height: AppSpacing.md),
              _TextInputField(
                controller: lastNameController,
                focusNode: lastNameFocusNode,
                label: 'Nom',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
                validator: (value) =>
                    _requiredValidator(value, 'Veuillez saisir votre nom.'),
              ),
              const SizedBox(height: AppSpacing.md),
              _TextInputField(
                controller: emailController,
                focusNode: emailFocusNode,
                label: 'Adresse e-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => phoneFocusNode.requestFocus(),
                validator: _emailValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              _TextInputField(
                controller: phoneController,
                focusNode: phoneFocusNode,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixText: '+228 ',
                onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                validator: (value) => _requiredValidator(
                  value,
                  'Veuillez saisir votre téléphone.',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _BirthDateField(date: birthDate, onTap: onBirthDateTap),
              const SizedBox(height: AppSpacing.md),
              _NationalityField(
                nationalities: nationalities,
                nationality: nationality,
                onChanged: onNationalityChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              _PasswordInputField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                label: 'Mot de passe',
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                onToggleVisibility: onTogglePassword,
                onFieldSubmitted: (_) =>
                    confirmPasswordFocusNode.requestFocus(),
                validator: _passwordValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              _PasswordInputField(
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocusNode,
                label: 'Confirmer le mot de passe',
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onToggleVisibility: onToggleConfirmPassword,
                onFieldSubmitted: (_) => onSubmit(),
                validator: (value) {
                  final confirmPassword = value ?? '';
                  if (confirmPassword.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe.';
                  }
                  if (confirmPassword != passwordController.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _TermsCheckbox(
                acceptedTerms: acceptedTerms,
                showError: showTermsError,
                onChanged: onTermsChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              _RegisterButton(isSubmitting: isSubmitting, onPressed: onSubmit),
              const SizedBox(height: AppSpacing.lg),
              const _LoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Veuillez saisir votre adresse e-mail.';

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Veuillez saisir une adresse e-mail valide.';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Veuillez saisir votre mot de passe.';
    if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    return null;
  }
}

class _TextInputField extends StatelessWidget {
  const _TextInputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.textInputAction,
    required this.validator,
    this.focusNode,
    this.keyboardType,
    this.prefixText,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? prefixText;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          prefixIcon: const Icon(Icons.cake_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: Text(
          date == null ? 'Sélectionner une date' : _formatLongDate(date!),
          style: TextStyle(
            color: date == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NationalityField extends StatelessWidget {
  const _NationalityField({
    required this.nationalities,
    required this.nationality,
    required this.onChanged,
  });

  final List<String> nationalities;
  final String nationality;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: nationality,
      items: nationalities.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Nationalité',
        prefixIcon: const Icon(Icons.flag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.obscureText,
    required this.textInputAction,
    required this.onToggleVisibility,
    required this.onFieldSubmitted,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool obscureText;
  final TextInputAction textInputAction;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: obscureText
              ? 'Afficher le mot de passe'
              : 'Masquer le mot de passe',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
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
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.acceptedTerms,
    required this.showError,
    required this.onChanged,
  });

  final bool acceptedTerms;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: acceptedTerms,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'J’accepte les conditions d’utilisation et la politique de confidentialité.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              'Veuillez accepter les conditions pour continuer.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.isSubmitting, required this.onPressed});

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
        isSubmitting ? 'Création...' : 'Créer mon compte',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Vous avez déjà un compte ?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}

String _formatLongDate(DateTime date) {
  const monthNames = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
}
