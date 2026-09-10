import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({this.showDemoTrip = true, super.key});

  final bool showDemoTrip;

  @override
  Widget build(BuildContext context) {
    final passenger = _PassengerPreview.demo();
    final trip = showDemoTrip ? _TripPreview.demo() : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Center(child: Text('FR')),
          ),
        ],
      ),
      body: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PassengerHeader(passenger: passenger),
                const SizedBox(height: AppSpacing.xl),
                if (trip == null)
                  const _NoTripCard()
                else ...[
                  _SectionTitle(
                    title: 'Votre prochain voyage',
                    actionLabel: 'Voir tous mes voyages',
                    onActionTap: () =>
                        Navigator.pushNamed(context, AppRoutes.myTrips),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _NextTripCard(trip: trip),
                  const SizedBox(height: AppSpacing.xl),
                  _ChecklistPreviewCard(trip: trip),
                ],
                const SizedBox(height: AppSpacing.xl),
                const _QuickActionsSection(),
                const SizedBox(height: AppSpacing.xl),
                const _SmartTravelCard(),
                const SizedBox(height: AppSpacing.md),
                _TravelTipCard(trip: trip ?? _TripPreview.demo()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PassengerPreview {
  const _PassengerPreview({
    required this.firstName,
    required this.notificationCount,
  });

  final String firstName;
  final int notificationCount;

  factory _PassengerPreview.demo() {
    return const _PassengerPreview(firstName: 'Diane', notificationCount: 2);
  }
}

class _TripPreview {
  const _TripPreview({
    required this.bookingReference,
    required this.flightNumber,
    required this.departureCity,
    required this.departureCode,
    required this.destinationCity,
    required this.destinationCode,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.countdownLabel,
  });

  final String bookingReference;
  final String flightNumber;
  final String departureCity;
  final String departureCode;
  final String destinationCity;
  final String destinationCode;
  final DateTime departureDate;
  final String departureTime;
  final String arrivalTime;
  final String status;
  final String countdownLabel;

  factory _TripPreview.demo() {
    return _TripPreview(
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Accra',
      destinationCode: 'ACC',
      departureDate: DateTime(2026, 9, 12),
      departureTime: '08:30',
      arrivalTime: '09:20',
      status: 'À l’heure',
      countdownLabel: 'Départ dans 2 jours',
    );
  }

  Map<String, Object?> toArguments() {
    return {
      'bookingReference': bookingReference,
      'flightNumber': flightNumber,
      'departureCity': departureCity,
      'departureCode': departureCode,
      'destinationCity': destinationCity,
      'destinationCode': destinationCode,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'status': status,
    };
  }
}

class _PassengerHeader extends StatelessWidget {
  const _PassengerHeader({required this.passenger});

  final _PassengerPreview passenger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon espace', style: AppTextStyles.overline),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bonjour, ${passenger.firstName}',
                style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Prête pour votre prochain voyage ?',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        _NotificationButton(count: passenger.notificationCount),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filled(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.assistant,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _NextTripCard extends StatelessWidget {
  const _NextTripCard({required this.trip});

  final _TripPreview trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'PROCHAIN VOYAGE · ${trip.flightNumber}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  trip.countdownLabel.replaceFirst('Départ dans ', 'J - '),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TripRoute(trip: trip),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusBadge(label: trip.status),
                    Text(
                      'Réf. ${trip.bookingReference}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Départ ${trip.departureTime} · Arrivée ${trip.arrivalTime}',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl, color: AppColors.border),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Préparation du voyage',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '1 / 4',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: const LinearProgressIndicator(
                    value: 0.25,
                    minHeight: 8,
                    backgroundColor: AppColors.surface,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.tripDetails,
                      arguments: trip.toArguments(),
                    ),
                    child: const Text('Voir mon voyage'),
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            child: Wrap(
              children: [
                Text(_formatLongDate(trip.departureDate)),
                Text(trip.countdownLabel),
                const Text('Réservé'),
                const Text('Préparation'),
                const Text('Enregistrement'),
                const Text('Embarquement'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripRoute extends StatelessWidget {
  const _TripRoute({required this.trip});

  final _TripPreview trip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AirportBlock(
            city: trip.departureCity,
            code: trip.departureCode,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Icon(Icons.arrow_forward, color: AppColors.secondary),
        ),
        Expanded(
          child: _AirportBlock(
            city: trip.destinationCity,
            code: trip.destinationCode,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _AirportBlock extends StatelessWidget {
  const _AirportBlock({
    required this.city,
    required this.code,
    this.alignEnd = false,
  });

  final String city;
  final String code;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          code,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ChecklistPreviewCard extends StatelessWidget {
  const _ChecklistPreviewCard({required this.trip});

  final _TripPreview trip;

  @override
  Widget build(BuildContext context) {
    const completedTasks = 1;
    const totalTasks = 4;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'À faire avant le départ',
            actionLabel: 'Voir ma checklist',
            onActionTap: () => Navigator.pushNamed(
              context,
              AppRoutes.tripChecklist,
              arguments: trip.toArguments(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _ChecklistTask(label: 'Réservation confirmée', completed: true),
          const _ChecklistTask(label: 'Vérifier les documents de voyage'),
          const _ChecklistTask(label: 'Préparer les bagages'),
          const _ChecklistTask(label: 'Faire l’enregistrement'),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '1 sur 4 terminé',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: const LinearProgressIndicator(
              value: completedTasks / totalTasks,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTask extends StatelessWidget {
  const _ChecklistTask({required this.label, this.completed = false});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: completed
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.78,
          children: const [
            _QuickAction(
              label: 'Mes voyages',
              icon: Icons.work_outline,
              routeName: AppRoutes.myTrips,
            ),
            _QuickAction(
              label: 'Statut du vol',
              icon: Icons.flight_land_outlined,
              routeName: AppRoutes.flightStatus,
            ),
            _QuickAction(
              label: 'Assistant',
              icon: Icons.auto_awesome,
              routeName: AppRoutes.assistant,
            ),
            _QuickAction(
              label: 'Bagages',
              icon: Icons.luggage_outlined,
              routeName: AppRoutes.baggage,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartTravelCard extends StatelessWidget {
  const _SmartTravelCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Travel',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Votre assistant de voyage',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Besoin d’aide pour préparer votre voyage, comprendre les règles bagages ou retrouver une information ?',
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.assistant),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text(
                    'Demander à l’assistant',
                    style: TextStyle(fontWeight: FontWeight.w900),
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

class _TravelTipCard extends StatelessWidget {
  const _TravelTipCard({required this.trip});

  final _TripPreview trip;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil pour votre voyage',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Votre vol pour ${trip.destinationCity} part à ${trip.departureTime}. Prévoyez d’arriver à l’aéroport au moins 2 heures avant le départ.',
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTripCard extends StatelessWidget {
  const _NoTripCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_outlined,
            color: AppColors.secondary,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun voyage à venir',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Prêt à découvrir votre prochaine destination ?',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.searchFlight),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Rechercher un vol',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

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
