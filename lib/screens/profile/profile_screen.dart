import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _PassengerProfile _profile = _PassengerProfile.demo();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editProfile() async {
    final updatedProfile = await showModalBottomSheet<_PassengerProfile>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(profile: _profile),
    );

    if (updatedProfile == null || !mounted) return;

    // TODO backend: PUT /api/profile.
    // TODO backend: validate email and phone server-side.
    setState(() => _profile = updatedProfile);
    _showSnackBar('Profil mis à jour.');
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => const _LogoutDialog(),
    );

    if (shouldLogout != true || !mounted) return;

    // TODO backend/auth: invalidate token if required.
    Navigator.pushNamed(context, AppRoutes.login);
  }

  Future<void> _confirmAccountDeletion() async {
    // TODO backend: secure account deletion with identity verification.
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text(
            'Cette fonctionnalité sera disponible avec la gestion sécurisée du compte côté serveur.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: widget.showAppBar
          ? AppBar(
              leading: IconButton(
                tooltip: 'Retour',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: const Text('Profil'),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(profile: _profile),
                  const SizedBox(height: AppSpacing.md),
                  _PersonalInfoSection(profile: _profile, onEdit: _editProfile),
                  const SizedBox(height: AppSpacing.md),
                  _TravelPreferencesCard(
                    profile: _profile,
                    onSeatChanged: (value) {
                      setState(() {
                        _profile = _profile.copyWith(seatPreference: value);
                      });
                    },
                    onMealChanged: (value) {
                      setState(() {
                        _profile = _profile.copyWith(mealPreference: value);
                      });
                    },
                    onNotificationsChanged: (value) {
                      setState(() {
                        _profile = _profile.copyWith(
                          notificationsEnabled: value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _TravelDocumentsCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _LoyaltyCard(),
                  const SizedBox(height: AppSpacing.md),
                  _NotificationsSection(profile: _profile),
                  const SizedBox(height: AppSpacing.md),
                  const _AssistanceSection(),
                  const SizedBox(height: AppSpacing.md),
                  _SecuritySection(
                    onPasswordTap: () {
                      // TODO backend/auth: secure password change flow.
                      _showSnackBar('Modification du mot de passe à venir.');
                    },
                    onLogoutTap: _confirmLogout,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      key: const Key('profile-delete-account-button'),
                      onPressed: _confirmAccountDeletion,
                      child: const Text('Supprimer mon compte'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final _PassengerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F102033),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFF0E7E4),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E7E4),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: const Text(
                    'ASKY CLUB · SILVER',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({required this.profile, required this.onEdit});

  final _PassengerProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Informations personnelles',
      trailing: TextButton.icon(
        key: const Key('profile-edit-button'),
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Modifier'),
      ),
      child: Column(
        children: [
          _ProfileInfoTile(label: 'Prénom', value: profile.firstName),
          _ProfileInfoTile(label: 'Nom', value: profile.lastName),
          _ProfileInfoTile(label: 'Email', value: profile.email),
          _ProfileInfoTile(label: 'Téléphone', value: profile.phone),
          _ProfileInfoTile(
            label: 'Date de naissance',
            value: profile.birthDate,
          ),
          _ProfileInfoTile(label: 'Nationalité', value: profile.nationality),
          _ProfileInfoTile(label: 'Pays de résidence', value: profile.country),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'La modification de l’adresse email nécessitera une vérification.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TravelPreferencesCard extends StatelessWidget {
  const _TravelPreferencesCard({
    required this.profile,
    required this.onSeatChanged,
    required this.onMealChanged,
    required this.onNotificationsChanged,
  });

  final _PassengerProfile profile;
  final ValueChanged<String> onSeatChanged;
  final ValueChanged<String> onMealChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Préférences de voyage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileInfoTile(
            label: 'Langue de l’application',
            value: profile.language,
          ),
          DropdownButtonFormField<String>(
            key: const Key('profile-seat-field'),
            initialValue: profile.seatPreference,
            decoration: const InputDecoration(labelText: 'Préférence de siège'),
            items: const [
              DropdownMenuItem(value: 'Hublot', child: Text('Hublot')),
              DropdownMenuItem(value: 'Couloir', child: Text('Couloir')),
              DropdownMenuItem(
                value: 'Indifférent',
                child: Text('Indifférent'),
              ),
            ],
            onChanged: (value) {
              if (value != null) onSeatChanged(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: const Key('profile-meal-field'),
            initialValue: profile.mealPreference,
            decoration: const InputDecoration(labelText: 'Repas spécial'),
            items: const [
              DropdownMenuItem(value: 'Aucun', child: Text('Aucun')),
              DropdownMenuItem(value: 'Végétarien', child: Text('Végétarien')),
              DropdownMenuItem(
                value: 'Sans gluten',
                child: Text('Sans gluten'),
              ),
              DropdownMenuItem(value: 'Autre', child: Text('Autre')),
            ],
            onChanged: (value) {
              if (value != null) onMealChanged(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              key: const Key('profile-notifications-switch'),
              contentPadding: EdgeInsets.zero,
              value: profile.notificationsEnabled,
              title: const Text('Notifications'),
              subtitle: Text(
                profile.notificationsEnabled ? 'Activées' : 'Désactivées',
              ),
              onChanged: onNotificationsChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Ces préférences ne constituent pas une réservation de service.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TravelDocumentsCard extends StatelessWidget {
  const _TravelDocumentsCard();

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Documents de voyage',
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passeport',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text('Non renseigné', style: AppTextStyles.body),
              ],
            ),
          ),
          OutlinedButton(
            key: const Key('profile-document-add-button'),
            onPressed: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Gestion des documents à venir.')),
              ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard();

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'ASKY Club',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultez votre compte fidélité et vos avantages.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('profile-loyalty-button'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.loyalty),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.card_membership_outlined),
              label: const Text(
                'Voir ASKY Club',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.profile});

  final _PassengerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileInfoTile(
            label: 'Statut',
            value: profile.notificationsEnabled ? 'Activées' : 'Désactivées',
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('profile-notifications-button'),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Voir mes notifications'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistanceSection extends StatelessWidget {
  const _AssistanceSection();

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Aide et assistance',
      child: Column(
        children: [
          _FullWidthActionButton(
            key: const Key('profile-support-button'),
            icon: Icons.support_agent,
            label: 'Contacter l’assistance',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.support),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FullWidthActionButton(
            key: const Key('profile-my-requests-button'),
            icon: Icons.list_alt_outlined,
            label: 'Mes demandes',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myRequests),
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.onPasswordTap,
    required this.onLogoutTap,
  });

  final VoidCallback onPasswordTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Sécurité',
      child: Column(
        children: [
          _FullWidthActionButton(
            key: const Key('profile-password-button'),
            icon: Icons.lock_outline,
            label: 'Modifier le mot de passe',
            onPressed: onPasswordTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          _FullWidthActionButton(
            key: const Key('profile-logout-button'),
            icon: Icons.logout,
            label: 'Déconnexion',
            onPressed: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final _PassengerProfile profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _nationalityController = TextEditingController(
      text: widget.profile.nationality,
    );
    _countryController = TextEditingController(text: widget.profile.country);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _save() {
    // TODO backend: GET /api/profile should provide the source profile.
    // TODO backend: identity must come from JWT, never an arbitrary passengerId.
    // TODO backend: email change requires verification before applying.
    Navigator.pop(
      context,
      widget.profile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        nationality: _nationalityController.text.trim(),
        country: _countryController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifier le profil',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('profile-first-name-field'),
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('profile-last-name-field'),
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('profile-phone-field'),
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('profile-nationality-field'),
                controller: _nationalityController,
                decoration: const InputDecoration(labelText: 'Nationalité'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('profile-country-field'),
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Pays de résidence',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'La modification de l’adresse email nécessitera une vérification.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('profile-save-button'),
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text('Enregistrer'),
                    ),
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

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Se déconnecter ?'),
      content: const Text(
        'Voulez-vous vraiment vous déconnecter de votre compte ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('profile-confirm-logout-button'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F102033),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullWidthActionButton extends StatelessWidget {
  const _FullWidthActionButton({
    required super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _PassengerProfile {
  const _PassengerProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.nationality,
    required this.country,
    required this.language,
    required this.seatPreference,
    required this.mealPreference,
    required this.notificationsEnabled,
  });

  factory _PassengerProfile.demo() {
    // TODO backend: GET /api/profile.
    // TODO backend: never expose another passenger's data.
    // TODO backend: protect sensitive personal data with encryption/access rules.
    // TODO backend: manage privacy consents.
    return const _PassengerProfile(
      firstName: 'Diane',
      lastName: 'Amouzou',
      email: 'diane.amouzou@example.com',
      phone: '+228 90 00 00 00',
      birthDate: '18 août 2003',
      nationality: 'Togolaise',
      country: 'Togo',
      language: 'Français',
      seatPreference: 'Hublot',
      mealPreference: 'Aucun',
      notificationsEnabled: true,
    );
  }

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String birthDate;
  final String nationality;
  final String country;
  final String language;
  final String seatPreference;
  final String mealPreference;
  final bool notificationsEnabled;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  _PassengerProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? birthDate,
    String? nationality,
    String? country,
    String? language,
    String? seatPreference,
    String? mealPreference,
    bool? notificationsEnabled,
  }) {
    return _PassengerProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      country: country ?? this.country,
      language: language ?? this.language,
      seatPreference: seatPreference ?? this.seatPreference,
      mealPreference: mealPreference ?? this.mealPreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
