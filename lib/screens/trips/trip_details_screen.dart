import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = _TripDetailsData.fromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Mon voyage'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReferenceHeader(reference: trip.bookingReference),
                  const SizedBox(height: AppSpacing.md),
                  _TripHeaderCard(trip: trip),
                  const SizedBox(height: AppSpacing.md),
                  if (trip.isPast)
                    _PastTripSummary(trip: trip)
                  else ...[
                    const _TripJourneyProgress(),
                    const SizedBox(height: AppSpacing.md),
                    const _ChecklistSummary(),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _BookingCard(trip: trip),
                  const SizedBox(height: AppSpacing.md),
                  const _BaggageSummary(),
                  const SizedBox(height: AppSpacing.md),
                  const _UsefulInfoCard(),
                  const SizedBox(height: AppSpacing.md),
                  _TripActions(isPast: trip.isPast),
                  const SizedBox(height: AppSpacing.md),
                  _SmartTravelAssistantCard(trip: trip),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripDetailsData {
  const _TripDetailsData({
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
    required this.isPast,
  });

  factory _TripDetailsData.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const <String, Object?>{};

    return _TripDetailsData(
      bookingReference: _readString(values, 'bookingReference', 'ASKY7D2'),
      flightNumber: _readString(values, 'flightNumber', 'KP 020'),
      departureCity: _readString(values, 'departureCity', 'Lomé'),
      departureCode: _readString(values, 'departureCode', 'LFW'),
      destinationCity: _readString(values, 'destinationCity', 'Accra'),
      destinationCode: _readString(values, 'destinationCode', 'ACC'),
      departureDate: _readString(values, 'departureDate', '12 septembre 2026'),
      departureTime: _readString(values, 'departureTime', '08:30'),
      arrivalTime: _readString(values, 'arrivalTime', '09:20'),
      status: _readString(values, 'status', 'À l’heure'),
      isPast: values['isPast'] == true,
    );
  }

  final String bookingReference;
  final String flightNumber;
  final String departureCity;
  final String departureCode;
  final String destinationCity;
  final String destinationCode;
  final String departureDate;
  final String departureTime;
  final String arrivalTime;
  final String status;
  final bool isPast;

  static String _readString(
    Map<dynamic, dynamic> values,
    String key,
    String fallback,
  ) {
    final value = values[key];
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }
}

class _ReferenceHeader extends StatelessWidget {
  const _ReferenceHeader({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Référence', style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xs),
        Text(
          reference,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TripHeaderCard extends StatelessWidget {
  const _TripHeaderCard({required this.trip});

  final _TripDetailsData trip;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ASKY',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                trip.flightNumber,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _AirportColumn(
                  code: trip.departureCode,
                  city: trip.departureCity,
                  time: trip.departureTime,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward, color: AppColors.secondary),
              ),
              Expanded(
                child: _AirportColumn(
                  code: trip.destinationCode,
                  city: trip.destinationCity,
                  time: trip.arrivalTime,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _IconText(icon: Icons.calendar_today, label: trip.departureDate),
              _StatusBadge(status: trip.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirportColumn extends StatelessWidget {
  const _AirportColumn({
    required this.code,
    required this.city,
    required this.time,
    this.alignEnd = false,
  });

  final String code;
  final String city;
  final String time;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          code,
          textAlign: textAlign,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(city, textAlign: textAlign, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xs),
        Text(
          time,
          textAlign: textAlign,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TripJourneyProgress extends StatelessWidget {
  const _TripJourneyProgress();

  static const steps = [
    _JourneyStep('Réservation', _JourneyStepState.done),
    _JourneyStep('Préparation', _JourneyStepState.active),
    _JourneyStep('Enregistrement', _JourneyStepState.upcoming),
    _JourneyStep('Embarquement', _JourneyStepState.upcoming),
    _JourneyStep('Voyage', _JourneyStepState.upcoming),
    _JourneyStep('Arrivée', _JourneyStepState.upcoming),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Votre parcours',
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            _JourneyStepTile(step: steps[index]),
            if (index < steps.length - 1)
              const Divider(height: AppSpacing.lg, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _PastTripSummary extends StatelessWidget {
  const _PastTripSummary({required this.trip});

  final _TripDetailsData trip;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Voyage terminé',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Merci d’avoir voyagé avec nous.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${trip.departureCity} vers ${trip.destinationCity} - ${trip.departureDate}',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

enum _JourneyStepState { done, active, upcoming }

class _JourneyStep {
  const _JourneyStep(this.label, this.state);

  final String label;
  final _JourneyStepState state;
}

class _JourneyStepTile extends StatelessWidget {
  const _JourneyStepTile({required this.step});

  final _JourneyStep step;

  @override
  Widget build(BuildContext context) {
    final icon = switch (step.state) {
      _JourneyStepState.done => Icons.check_circle,
      _JourneyStepState.active => Icons.radio_button_checked,
      _JourneyStepState.upcoming => Icons.radio_button_unchecked,
    };
    final color = switch (step.state) {
      _JourneyStepState.done => AppColors.secondary,
      _JourneyStepState.active => AppColors.accent,
      _JourneyStepState.upcoming => AppColors.textSecondary,
    };

    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            step.label,
            style: TextStyle(
              color: step.state == _JourneyStepState.upcoming
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistSummary extends StatelessWidget {
  const _ChecklistSummary();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'À faire avant le départ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChecklistItem(label: 'Réservation confirmée', done: true),
          const _ChecklistItem(label: 'Vérifier les documents de voyage'),
          const _ChecklistItem(label: 'Préparer les bagages'),
          const _ChecklistItem(label: 'Faire l’enregistrement'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 8,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  backgroundColor: AppColors.border,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '25 %',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '1 sur 4 terminé',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _FullWidthButton(
            label: 'Voir la checklist',
            icon: Icons.fact_check_outlined,
            routeName: AppRoutes.tripChecklist,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, this.done = false});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.secondary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.trip});

  final _TripDetailsData trip;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ma réservation',
      child: Column(
        children: [
          _DetailRow(label: 'Référence', value: trip.bookingReference),
          const _DetailRow(label: 'Passager', value: 'Diane Amouzou'),
          const _DetailRow(label: 'Classe', value: 'Economy'),
          const _DetailRow(label: 'Statut', value: 'À l’heure'),
          const _DetailRow(
            label: 'Billet électronique',
            value: 'ETKT 032-1234567890',
            helper: 'Numéro fictif de démonstration.',
          ),
        ],
      ),
    );
  }
}

class _BaggageSummary extends StatelessWidget {
  const _BaggageSummary();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Mes bagages',
      child: Column(
        children: const [
          _DetailRow(label: 'Cabine', value: '1 x 8 kg'),
          _DetailRow(label: 'Soute', value: '1 x 23 kg'),
          _DetailRow(label: 'Statut', value: 'Inclus dans le tarif'),
          SizedBox(height: AppSpacing.sm),
          _FullWidthButton(
            label: 'Voir mes bagages',
            icon: Icons.luggage_outlined,
            routeName: AppRoutes.baggage,
          ),
        ],
      ),
    );
  }
}

class _UsefulInfoCard extends StatelessWidget {
  const _UsefulInfoCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informations utiles',
      child: Column(
        children: const [
          _InfoTile(
            icon: Icons.schedule,
            text: 'Arrivez à l’aéroport au moins 2 heures avant votre départ.',
          ),
          SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.assignment_turned_in_outlined,
            text:
                'Vérifiez vos documents de voyage avant de vous rendre à l’aéroport.',
          ),
        ],
      ),
    );
  }
}

class _TripActions extends StatelessWidget {
  const _TripActions({required this.isPast});

  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (!isPast)
        const _TripAction(
          label: 'Checklist',
          icon: Icons.fact_check_outlined,
          routeName: AppRoutes.tripChecklist,
        ),
      const _TripAction(
        label: 'Bagages',
        icon: Icons.luggage_outlined,
        routeName: AppRoutes.baggage,
      ),
      const _TripAction(
        label: 'Assistant',
        icon: Icons.smart_toy_outlined,
        routeName: AppRoutes.assistant,
      ),
      const _TripAction(
        label: 'Notifications',
        icon: Icons.notifications_none,
        routeName: AppRoutes.notifications,
      ),
    ];

    return _SectionCard(
      title: 'Actions',
      child: GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisExtent: 112,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemBuilder: (context, index) => actions[index],
      ),
    );
  }
}

class _SmartTravelAssistantCard extends StatelessWidget {
  const _SmartTravelAssistantCard({required this.trip});

  final _TripDetailsData trip;

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
            color: Color(0x14062B5B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Besoin d’aide pour ce voyage ?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Demandez à l’assistant ASKY Smart Travel ce qu’il vous reste à faire, les règles bagages ou les informations concernant votre voyage.',
            style: TextStyle(color: AppColors.white, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.assistant,
              arguments: {
                'bookingReference': trip.bookingReference,
                'flightNumber': trip.flightNumber,
                'departureCity': trip.departureCity,
                'destinationCity': trip.destinationCity,
              },
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text(
              'Demander à l’assistant',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors(this.background, this.foreground);

  factory _StatusColors.fromStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('annul')) {
      return const _StatusColors(Color(0xFFFFEBEE), Color(0xFFC62828));
    }
    if (normalized.contains('retard')) {
      return const _StatusColors(Color(0xFFFFF4E5), Color(0xFFB35A00));
    }
    if (normalized.contains('termin')) {
      return const _StatusColors(Color(0xFFF0F2F5), Color(0xFF475467));
    }
    if (normalized.contains('embarquement')) {
      return const _StatusColors(Color(0xFFECEBFF), Color(0xFF4A42A8));
    }
    if (normalized.contains('vol')) {
      return const _StatusColors(Color(0xFFEAF7FF), Color(0xFF096B88));
    }
    return const _StatusColors(Color(0xFFE7F7EF), Color(0xFF177245));
  }

  final Color background;
  final Color foreground;
}

class _TripAction extends StatelessWidget {
  const _TripAction({
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
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => Navigator.pushNamed(context, routeName),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.helper});

  final String label;
  final String value;
  final String? helper;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (helper != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    helper!,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title});

  final String? title;
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
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
