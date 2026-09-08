import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flight = _FlightDetails.fromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Détail du vol'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
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
                _FlightSummaryCard(flight: flight),
                const SizedBox(height: AppSpacing.md),
                _TripTimelineCard(flight: flight),
                const SizedBox(height: AppSpacing.md),
                _FareCard(flight: flight),
                const SizedBox(height: AppSpacing.md),
                const _BaggageCard(),
                const SizedBox(height: AppSpacing.md),
                const _ServicesCard(),
                const SizedBox(height: AppSpacing.md),
                const _ConditionsCard(),
                const SizedBox(height: AppSpacing.lg),
                _ContinueButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Étape de réservation à venir.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlightDetails {
  const _FlightDetails({
    required this.airline,
    required this.flightNumber,
    required this.departureCode,
    required this.departureCity,
    required this.departureTime,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.isDirect,
    required this.date,
    required this.travelClass,
  });

  final String airline;
  final String flightNumber;
  final String departureCode;
  final String departureCity;
  final String departureTime;
  final String arrivalCode;
  final String arrivalCity;
  final String arrivalTime;
  final String duration;
  final int price;
  final bool isDirect;
  final DateTime date;
  final String travelClass;

  factory _FlightDetails.fromRouteArguments(Object? arguments) {
    if (arguments is! Map) return _FlightDetails.demo();

    final criteria = arguments['criteria'];
    final criteriaMap = criteria is Map ? criteria : const {};

    return _FlightDetails(
      airline: _readString(arguments, 'airline', 'ASKY'),
      flightNumber: _readString(arguments, 'flightNumber', 'KP 020'),
      departureCode: _readString(arguments, 'departureCode', 'LFW'),
      departureCity: _readString(criteriaMap, 'departureCity', 'Lomé'),
      departureTime: _readString(arguments, 'departureTime', '08:30'),
      arrivalCode: _readString(arguments, 'arrivalCode', 'ACC'),
      arrivalCity: _readString(criteriaMap, 'destinationCity', 'Accra'),
      arrivalTime: _readString(arguments, 'arrivalTime', '09:20'),
      duration: _readString(arguments, 'duration', '0h50'),
      price: _readInt(arguments, 'price', 306800),
      isDirect: _readBool(arguments, 'isDirect', true),
      date: _readDate(criteriaMap['departureDate'], DateTime(2026, 9, 12)),
      travelClass: _readString(criteriaMap, 'travelClass', 'Économique'),
    );
  }

  factory _FlightDetails.demo() {
    return _FlightDetails(
      airline: 'ASKY',
      flightNumber: 'KP 020',
      departureCode: 'LFW',
      departureCity: 'Lomé',
      departureTime: '08:30',
      arrivalCode: 'ACC',
      arrivalCity: 'Accra',
      arrivalTime: '09:20',
      duration: '0h50',
      price: 306800,
      isDirect: true,
      date: DateTime(2026, 9, 12),
      travelClass: 'Économique',
    );
  }

  String get status => isDirect ? 'Direct' : 'Avec escale';

  static String _readString(
    Map<dynamic, dynamic> arguments,
    String key,
    String fallback,
  ) {
    final value = arguments[key];
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static int _readInt(
    Map<dynamic, dynamic> arguments,
    String key,
    int fallback,
  ) {
    final value = arguments[key];
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _readBool(
    Map<dynamic, dynamic> arguments,
    String key,
    bool fallback,
  ) {
    final value = arguments[key];
    if (value is bool) return value;
    return fallback;
  }

  static DateTime _readDate(Object? value, DateTime fallback) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? fallback;
    return fallback;
  }
}

class _FlightSummaryCard extends StatelessWidget {
  const _FlightSummaryCard({required this.flight});

  final _FlightDetails flight;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  flight.airline,
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                ),
              ),
              Text(
                flight.flightNumber,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _AirportSummary(
                  code: flight.departureCode,
                  city: flight.departureCity,
                  time: flight.departureTime,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(Icons.arrow_forward, color: AppColors.secondary),
              ),
              Expanded(
                child: _AirportSummary(
                  code: flight.arrivalCode,
                  city: flight.arrivalCity,
                  time: flight.arrivalTime,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Durée', value: flight.duration),
          _InfoRow(label: 'Statut', value: flight.status),
          _InfoRow(label: 'Date', value: _formatLongDate(flight.date)),
        ],
      ),
    );
  }
}

class _AirportSummary extends StatelessWidget {
  const _AirportSummary({
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
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          time,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TripTimelineCard extends StatelessWidget {
  const _TripTimelineCard({required this.flight});

  final _FlightDetails flight;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline du trajet',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VerticalTimeline(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: [
                _TimelineStop(
                  city: flight.departureCity,
                  code: flight.departureCode,
                  time: flight.departureTime,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        flight.duration,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _TimelineStop(
                  city: flight.arrivalCity,
                  code: flight.arrivalCode,
                  time: flight.arrivalTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalTimeline extends StatelessWidget {
  const _VerticalTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TimelineDot(),
        Container(width: 2, height: 84, color: AppColors.border),
        const _TimelineDot(),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TimelineStop extends StatelessWidget {
  const _TimelineStop({
    required this.city,
    required this.code,
    required this.time,
  });

  final String city;
  final String code;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$city ($code)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FareCard extends StatelessWidget {
  const _FareCard({required this.flight});

  final _FlightDetails flight;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Votre tarif',
      child: Column(
        children: [
          _InfoRow(label: 'Classe', value: flight.travelClass),
          _InfoRow(label: 'Prix', value: _formatPrice(flight.price)),
          const _InfoRow(label: 'Taxes', value: 'Incluses'),
          const _InfoRow(label: 'Type', value: 'Tarif standard'),
        ],
      ),
    );
  }
}

class _BaggageCard extends StatelessWidget {
  const _BaggageCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Bagages inclus',
      child: Column(
        children: [
          _IconLine(icon: Icons.work_outline, text: '1 bagage cabine'),
          _IconLine(icon: Icons.luggage_outlined, text: '1 bagage en soute'),
          _IconLine(icon: Icons.scale_outlined, text: 'Poids autorisé : 23 kg'),
          _IconLine(
            icon: Icons.backpack_outlined,
            text: 'Bagage cabine : 8 kg',
          ),
        ],
      ),
    );
  }
}

class _ServicesCard extends StatelessWidget {
  const _ServicesCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Services',
      child: Column(
        children: [
          _IconLine(
            icon: Icons.airline_seat_recline_normal_outlined,
            text: 'Sélection du siège',
          ),
          _IconLine(icon: Icons.restaurant_outlined, text: 'Repas'),
          _IconLine(
            icon: Icons.add_business_outlined,
            text: 'Bagage supplémentaire',
          ),
          _IconLine(
            icon: Icons.accessible_forward_outlined,
            text: 'Assistance spéciale',
          ),
        ],
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Conditions',
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: AppSpacing.sm),
        title: Text(
          'Voir les conditions du tarif',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          _BulletText('Modification possible selon conditions.'),
          _BulletText('Remboursement selon le tarif.'),
          _BulletText('Restrictions éventuelles applicables.'),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: const Text(
          'Continuer',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.screenTitle.copyWith(fontSize: 18)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

String _formatPrice(int price) {
  final chars = price.toString().split('').reversed.toList();
  final buffer = StringBuffer();

  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) buffer.write(' ');
    buffer.write(chars[index]);
  }

  return 'XOF ${buffer.toString().split('').reversed.join()}';
}
