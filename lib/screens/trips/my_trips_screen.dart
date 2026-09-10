import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

enum _TripsTab {
  upcoming('À venir'),
  past('Passés');

  const _TripsTab(this.label);

  final String label;
}

enum _TripStatus {
  confirmed('Confirmé', Color(0xFFEAF3FF), Color(0xFF0957A5)),
  onTime('À l’heure', Color(0xFFE7F7EF), Color(0xFF177245)),
  delayed('Retardé', Color(0xFFFFF4E5), Color(0xFFB35A00)),
  boarding('Embarquement', Color(0xFFECEBFF), Color(0xFF4A42A8)),
  inFlight('En vol', Color(0xFFEAF7FF), Color(0xFF096B88)),
  completed('Terminé', Color(0xFFF0F2F5), Color(0xFF475467)),
  canceled('Annulé', Color(0xFFFFEBEE), Color(0xFFC62828));

  const _TripStatus(this.label, this.backgroundColor, this.textColor);

  final String label;
  final Color backgroundColor;
  final Color textColor;

  bool get isSupported => switch (this) {
    _TripStatus.confirmed => true,
    _TripStatus.onTime => true,
    _TripStatus.delayed => true,
    _TripStatus.boarding => true,
    _TripStatus.inFlight => true,
    _TripStatus.completed => true,
    _TripStatus.canceled => true,
  };
}

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({
    this.showAppBar = true,
    this.showDemoTrips = true,
    super.key,
  });

  final bool showAppBar;
  final bool showDemoTrips;

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  _TripsTab _selectedTab = _TripsTab.upcoming;

  List<_TripItem> get _upcomingTrips {
    if (!widget.showDemoTrips) return const [];
    return _TripItem.demoUpcomingTrips;
  }

  List<_TripItem> get _pastTrips {
    if (!widget.showDemoTrips) return const [];
    return _TripItem.demoPastTrips;
  }

  @override
  Widget build(BuildContext context) {
    final trips = _selectedTab == _TripsTab.upcoming
        ? _upcomingTrips
        : _pastTrips;
    final content = ColoredBox(
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
              if (!widget.showAppBar) ...[
                Text('Mes voyages', style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                'Retrouvez et suivez tous vos voyages ASKY.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TripsTabSelector(
                selectedTab: _selectedTab,
                upcomingCount: _upcomingTrips.length,
                pastCount: _pastTrips.length,
                onChanged: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (trips.isEmpty)
                _EmptyTripsState(tab: _selectedTab)
              else
                ...trips.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TripCard(
                      trip: entry.value,
                      highlight:
                          _selectedTab == _TripsTab.upcoming && entry.key == 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!widget.showAppBar) return content;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mes voyages'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: content,
    );
  }
}

class _TripItem {
  const _TripItem({
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
    this.countdownLabel,
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
  final _TripStatus status;
  final bool isPast;
  final String? countdownLabel;

  static final List<_TripItem> demoUpcomingTrips = [
    _TripItem(
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Accra',
      destinationCode: 'ACC',
      departureDate: DateTime(2026, 9, 12),
      departureTime: '08:30',
      arrivalTime: '09:20',
      status: _TripStatus.onTime,
      isPast: false,
      countdownLabel: 'Dans 2 jours',
    ),
    _TripItem(
      bookingReference: 'ASKY9K4',
      flightNumber: 'KP 034',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Abidjan',
      destinationCode: 'ABJ',
      departureDate: DateTime(2026, 9, 25),
      departureTime: '10:15',
      arrivalTime: '11:35',
      status: _TripStatus.confirmed,
      isPast: false,
      countdownLabel: 'Dans 15 jours',
    ),
  ];

  static final List<_TripItem> demoPastTrips = [
    _TripItem(
      bookingReference: 'ASKY4B8',
      flightNumber: 'KP 012',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Cotonou',
      destinationCode: 'COO',
      departureDate: DateTime(2026, 8, 20),
      departureTime: '09:10',
      arrivalTime: '09:55',
      status: _TripStatus.completed,
      isPast: true,
    ),
    _TripItem(
      bookingReference: 'ASKY2M6',
      flightNumber: 'KP 018',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Dakar',
      destinationCode: 'DSS',
      departureDate: DateTime(2026, 7, 5),
      departureTime: '13:40',
      arrivalTime: '16:10',
      status: _TripStatus.completed,
      isPast: true,
    ),
  ];

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
      'status': status.label,
      'isPast': isPast,
    };
  }
}

class _TripsTabSelector extends StatelessWidget {
  const _TripsTabSelector({
    required this.selectedTab,
    required this.upcomingCount,
    required this.pastCount,
    required this.onChanged,
  });

  final _TripsTab selectedTab;
  final int upcomingCount;
  final int pastCount;
  final ValueChanged<_TripsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          _TripTabButton(
            label: '${_TripsTab.upcoming.label} ($upcomingCount)',
            selected: selectedTab == _TripsTab.upcoming,
            onTap: () => onChanged(_TripsTab.upcoming),
          ),
          _TripTabButton(
            label: '${_TripsTab.past.label} ($pastCount)',
            selected: selectedTab == _TripsTab.past,
            onTap: () => onChanged(_TripsTab.past),
          ),
        ],
      ),
    );
  }
}

class _TripTabButton extends StatelessWidget {
  const _TripTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.highlight});

  final _TripItem trip;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: () => _openTrip(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: highlight ? AppColors.secondary : AppColors.border,
            width: highlight ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        trip.bookingReference,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (highlight) const _NextTripLabel(),
                    ],
                  ),
                ),
                _TripStatusBadge(status: trip.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              trip.flightNumber,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _TripRoute(trip: trip),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _TripMetric(
                  label: 'Date',
                  value: _formatLongDate(trip.departureDate),
                ),
                _TripMetric(label: 'Départ', value: trip.departureTime),
                _TripMetric(label: 'Arrivée', value: trip.arrivalTime),
                if (!trip.isPast && trip.countdownLabel != null)
                  _TripMetric(
                    label: 'Compte à rebours',
                    value: trip.countdownLabel!,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => _openTrip(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: Text(
                  trip.isPast ? 'Voir les détails' : 'Voir le voyage',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTrip(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.tripDetails,
      arguments: trip.toArguments(),
    );
  }
}

class _NextTripLabel extends StatelessWidget {
  const _NextTripLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: const Text(
        'Prochain voyage',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TripRoute extends StatelessWidget {
  const _TripRoute({required this.trip});

  final _TripItem trip;

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
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          code,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TripMetric extends StatelessWidget {
  const _TripMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripStatusBadge extends StatelessWidget {
  const _TripStatusBadge({required this.status});

  final _TripStatus status;

  @override
  Widget build(BuildContext context) {
    assert(status.isSupported);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyTripsState extends StatelessWidget {
  const _EmptyTripsState({required this.tab});

  final _TripsTab tab;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = tab == _TripsTab.upcoming;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            isUpcoming ? Icons.travel_explore_outlined : Icons.history,
            color: AppColors.secondary,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isUpcoming ? 'Aucun voyage à venir' : 'Aucun voyage passé',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isUpcoming
                ? 'Prêt à préparer votre prochaine aventure ?'
                : 'Vos anciens voyages apparaîtront ici.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          if (isUpcoming) ...[
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: const Text(
                  'Rechercher un vol',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
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
