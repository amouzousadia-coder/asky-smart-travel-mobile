import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({this.hasLoyaltyAccount = true, super.key});

  final bool hasLoyaltyAccount;

  @override
  Widget build(BuildContext context) {
    final profile = _LoyaltyProfile.demo();
    final activities = _demoActivities();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('ASKY Club'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: hasLoyaltyAccount
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MemberCard(profile: profile),
                        const SizedBox(height: AppSpacing.md),
                        _TierProgressCard(profile: profile),
                        const SizedBox(height: AppSpacing.md),
                        _LoyaltyActivitySection(activities: activities),
                        const SizedBox(height: AppSpacing.md),
                        _MilesSummary(profile: profile),
                        const SizedBox(height: AppSpacing.md),
                        const _BenefitsCard(),
                        const SizedBox(height: AppSpacing.md),
                        const _UseMilesCard(),
                        const SizedBox(height: AppSpacing.md),
                        const _DemoLoyaltyDisclaimer(),
                        const SizedBox(height: AppSpacing.md),
                        const _EarnMilesCard(),
                      ],
                    )
                  : const _NoLoyaltyAccountState(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.profile});

  final _LoyaltyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24062B5B),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ASKY CLUB',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Icon(profile.tier.icon, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            profile.memberName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TierBadge(label: profile.tier.name),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.memberNumber,
            style: const TextStyle(color: AppColors.white, letterSpacing: 1),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${profile.availableMilesLabel} miles',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Membre depuis ${profile.memberSince}',
            style: const TextStyle(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _MilesSummary extends StatelessWidget {
  const _MilesSummary({required this.profile});

  final _LoyaltyProfile profile;

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'Mes miles',
      child: Column(
        children: [
          _MilesInfoTile(
            label: 'Miles disponibles',
            value: profile.availableMilesLabel,
            helper:
                'Utilisables pour de futurs avantages lorsque le programme réel sera connecté.',
          ),
          const Divider(color: AppColors.border),
          _MilesInfoTile(
            label: 'Miles statut',
            value: profile.statusMilesLabel,
            helper: 'Utilisés ici pour illustrer la progression de niveau.',
          ),
        ],
      ),
    );
  }
}

class _MilesInfoTile extends StatelessWidget {
  const _MilesInfoTile({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.stars_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(helper, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierProgressCard extends StatelessWidget {
  const _TierProgressCard({required this.profile});

  final _LoyaltyProfile profile;

  @override
  Widget build(BuildContext context) {
    final remaining = profile.nextTierThreshold - profile.statusMiles;

    return _LoyaltySection(
      title: 'Progression',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: 'Niveau actuel', value: profile.tier.name),
          _InfoLine(
            label: 'Niveau suivant de démonstration',
            value: profile.nextTier.name,
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: profile.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(AppRadius.small),
            backgroundColor: AppColors.border,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${profile.statusMilesLabel} / ${_formatMiles(profile.nextTierThreshold)} miles statut',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(profile.progress * 100).round()} %',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Plus que ${_formatMiles(remaining)} miles statut pour atteindre ${profile.nextTier.name}.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Ces seuils sont uniquement des données fictives du prototype.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'Mes avantages',
      child: Column(
        children: const [
          _BenefitTile(text: 'Accès à des offres personnalisées'),
          _BenefitTile(text: 'Priorité sur certaines communications'),
          _BenefitTile(text: 'Suivi simplifié des miles'),
          _BenefitTile(text: 'Avantages fidélité selon votre niveau'),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Les avantages réels dépendront des conditions officielles du programme.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _LoyaltyActivitySection extends StatelessWidget {
  const _LoyaltyActivitySection({required this.activities});

  final List<_LoyaltyActivity> activities;

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'Activité récente',
      child: Column(
        children: [
          for (final activity in activities) ...[
            _LoyaltyActivityTile(activity: activity),
            if (activity != activities.last)
              const Divider(color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _LoyaltyActivityTile extends StatelessWidget {
  const _LoyaltyActivityTile({required this.activity});

  final _LoyaltyActivity activity;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showActivityDetails(context, activity),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              activity.flightNumber == null
                  ? Icons.card_giftcard
                  : Icons.flight_takeoff,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (activity.route != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(activity.route!, style: AppTextStyles.body),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(activity.date, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${_formatMiles(activity.miles)} miles',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _ActivityStatusBadge(status: activity.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UseMilesCard extends StatelessWidget {
  const _UseMilesCard();

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'Utiliser mes miles',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Les options d’utilisation des miles seront disponibles lorsque le programme de fidélité réel sera connecté.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('loyalty-use-miles-button'),
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Utilisation des miles à venir.'),
                  ),
                ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.explore_outlined),
              label: const Text(
                'Découvrir',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnMilesCard extends StatelessWidget {
  const _EarnMilesCard();

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'Comment gagner des miles ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos voyages éligibles pourront alimenter votre compte fidélité lorsque les services ASKY Club seront connectés.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('loyalty-my-trips-button'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.myTrips),
              icon: const Icon(Icons.airplane_ticket_outlined),
              label: const Text('Voir mes voyages'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoLoyaltyAccountState extends StatelessWidget {
  const _NoLoyaltyAccountState();

  @override
  Widget build(BuildContext context) {
    return _LoyaltySection(
      title: 'ASKY Club',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link_off, color: AppColors.primary, size: 38),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Votre compte ASKY Club n’est pas encore lié.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Associez votre compte fidélité pour retrouver vos miles et vos avantages.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('loyalty-link-account-button'),
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Liaison ASKY Club à venir.')),
                ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.link),
              label: const Text('Lier mon compte'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoLoyaltyDisclaimer extends StatelessWidget {
  const _DemoLoyaltyDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.accent),
      ),
      child: const Text(
        'Données de démonstration pour le prototype ASKY Smart Travel.',
        style: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

class _LoyaltySection extends StatelessWidget {
  const _LoyaltySection({required this.title, required this.child});

  final String title;
  final Widget child;

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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActivityStatusBadge extends StatelessWidget {
  const _ActivityStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'À venir';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isPending ? AppColors.warningSurface : AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPending ? AppColors.warning : AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

void _showActivityDetails(BuildContext context, _LoyaltyActivity activity) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.title, style: AppTextStyles.screenTitle),
              const SizedBox(height: AppSpacing.md),
              _InfoLine(label: 'Type', value: activity.type),
              if (activity.flightNumber != null)
                _InfoLine(label: 'Vol', value: activity.flightNumber!),
              if (activity.route != null)
                _InfoLine(label: 'Trajet', value: activity.route!),
              _InfoLine(label: 'Date', value: activity.date),
              _InfoLine(
                label: 'Miles',
                value: '+${_formatMiles(activity.miles)} miles',
              ),
              _InfoLine(label: 'Statut', value: activity.status),
            ],
          ),
        ),
      );
    },
  );
}

class _LoyaltyProfile {
  const _LoyaltyProfile({
    required this.memberNumber,
    required this.memberName,
    required this.tier,
    required this.availableMiles,
    required this.statusMiles,
    required this.nextTier,
    required this.nextTierThreshold,
    required this.memberSince,
  });

  factory _LoyaltyProfile.demo() {
    // TODO backend: GET /api/loyalty/profile.
    // TODO backend: retrieve the linked account for the JWT passenger.
    // TODO backend: never accept an arbitrary passengerId from Flutter.
    // TODO backend: securely link an ASKY Club member number.
    // TODO backend: validate ownership of the loyalty account.
    // TODO backend: balances and tiers must come only from the official system.
    // TODO backend: never let Flutter modify the miles balance.
    // TODO backend: future sync with the official loyalty system.
    return _LoyaltyProfile(
      memberNumber: 'ASKY-CLUB-204815',
      memberName: 'Diane Amouzou',
      tier: _tiers[1],
      availableMiles: 12450,
      statusMiles: 8200,
      nextTier: _tiers[2],
      nextTierThreshold: 10000,
      memberSince: '2026',
    );
  }

  final String memberNumber;
  final String memberName;
  final _LoyaltyTier tier;
  final int availableMiles;
  final int statusMiles;
  final _LoyaltyTier nextTier;
  final int nextTierThreshold;
  final String memberSince;

  String get availableMilesLabel => _formatMiles(availableMiles);
  String get statusMilesLabel => _formatMiles(statusMiles);
  double get progress => (statusMiles / nextTierThreshold).clamp(0, 1);
}

class _LoyaltyActivity {
  const _LoyaltyActivity({
    required this.id,
    required this.title,
    this.flightNumber,
    this.route,
    required this.date,
    required this.miles,
    required this.status,
  });

  final String id;
  final String title;
  final String? flightNumber;
  final String? route;
  final String date;
  final int miles;
  final String status;

  String get type => flightNumber == null ? 'Bonus' : 'Vol';
}

class _LoyaltyTier {
  const _LoyaltyTier({
    required this.name,
    required this.minimumStatusMiles,
    required this.icon,
  });

  final String name;
  final int minimumStatusMiles;
  final IconData icon;
}

const _tiers = [
  _LoyaltyTier(
    name: 'Classic',
    minimumStatusMiles: 0,
    icon: Icons.person_outline,
  ),
  _LoyaltyTier(name: 'Silver', minimumStatusMiles: 5000, icon: Icons.star_half),
  _LoyaltyTier(name: 'Gold', minimumStatusMiles: 10000, icon: Icons.star),
  _LoyaltyTier(
    name: 'Platinum',
    minimumStatusMiles: 20000,
    icon: Icons.workspace_premium,
  ),
];

List<_LoyaltyActivity> _demoActivities() {
  // TODO backend: GET /api/loyalty/activities.
  // TODO backend: paginate loyalty history.
  // TODO backend: dates and miles must be calculated server-side.
  // TODO backend: never credit miles only from Flutter.
  return const [
    _LoyaltyActivity(
      id: '1',
      title: 'Vol KP 020',
      flightNumber: 'KP 020',
      route: 'Lomé → Accra',
      date: '12 sept. 2026',
      miles: 850,
      status: 'À venir',
    ),
    _LoyaltyActivity(
      id: '2',
      title: 'Vol KP 012',
      flightNumber: 'KP 012',
      route: 'Lomé → Cotonou',
      date: '20 août 2026',
      miles: 520,
      status: 'Crédités',
    ),
    _LoyaltyActivity(
      id: '3',
      title: 'Vol KP 018',
      flightNumber: 'KP 018',
      route: 'Lomé → Dakar',
      date: '5 juil. 2026',
      miles: 1450,
      status: 'Crédités',
    ),
    _LoyaltyActivity(
      id: '4',
      title: 'Bonus de bienvenue',
      date: '10 juin 2026',
      miles: 1000,
      status: 'Crédités',
    ),
  ];
}

String _formatMiles(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]} ',
  );
}
