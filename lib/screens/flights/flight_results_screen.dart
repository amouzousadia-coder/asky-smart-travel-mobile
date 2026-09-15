import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

enum _SortOption {
  lowestPrice('Prix le plus bas'),
  earliestDeparture('Départ le plus tôt'),
  shortestDuration('Durée la plus courte');

  const _SortOption(this.label);

  final String label;
}

enum _FlightFilter {
  all('Tous'),
  direct('Vol direct'),
  stopover('Avec escale');

  const _FlightFilter(this.label);

  final String label;
}

class FlightResultsScreen extends StatefulWidget {
  const FlightResultsScreen({super.key});

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  _SortOption _sortOption = _SortOption.lowestPrice;
  _FlightFilter _filter = _FlightFilter.all;

  static const List<_FlightOption> _demoFlights = [
    _FlightOption(
      airline: 'ASKY',
      flightNumber: 'KP 020',
      departureCode: 'LFW',
      departureTime: '08:30',
      arrivalCode: 'ACC',
      arrivalTime: '09:20',
      duration: '0h50',
      durationMinutes: 50,
      isDirect: true,
      price: 306800,
    ),
    _FlightOption(
      airline: 'ASKY',
      flightNumber: 'KP 024',
      departureCode: 'LFW',
      departureTime: '14:15',
      arrivalCode: 'ACC',
      arrivalTime: '15:05',
      duration: '0h50',
      durationMinutes: 50,
      isDirect: true,
      price: 328500,
    ),
    _FlightOption(
      airline: 'ASKY',
      flightNumber: 'KP 028',
      departureCode: 'LFW',
      departureTime: '18:40',
      arrivalCode: 'ACC',
      arrivalTime: '19:30',
      duration: '0h50',
      durationMinutes: 50,
      isDirect: true,
      price: 341200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final criteria = _SearchCriteria.fromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    final flights = _sortedAndFilteredFlights();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Résultats des vols'),
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
                _SearchSummaryCard(criteria: criteria),
                const SizedBox(height: AppSpacing.md),
                _SortFilterBar(
                  sortLabel: _sortOption.label,
                  filterLabel: _filter.label,
                  onSortTap: _showSortSheet,
                  onFilterTap: _showFilterSheet,
                ),
                const SizedBox(height: AppSpacing.md),
                if (flights.isEmpty)
                  const _EmptyResults()
                else
                  ...flights.map(
                    (flight) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _FlightResultCard(
                        flight: flight,
                        onChoose: () => _chooseFlight(flight, criteria),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_FlightOption> _sortedAndFilteredFlights() {
    final flights = _demoFlights.where((flight) {
      return switch (_filter) {
        _FlightFilter.all => true,
        _FlightFilter.direct => flight.isDirect,
        _FlightFilter.stopover => !flight.isDirect,
      };
    }).toList();

    flights.sort((first, second) {
      return switch (_sortOption) {
        _SortOption.lowestPrice => first.price.compareTo(second.price),
        _SortOption.earliestDeparture => first.departureTime.compareTo(
          second.departureTime,
        ),
        _SortOption.shortestDuration => first.durationMinutes.compareTo(
          second.durationMinutes,
        ),
      };
    });

    return flights;
  }

  Future<void> _showSortSheet() async {
    final selectedOption = await showModalBottomSheet<_SortOption>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (context) {
        return _SelectionSheet<_SortOption>(
          title: 'Trier',
          selectedValue: _sortOption,
          values: _SortOption.values,
          labelBuilder: (option) => option.label,
        );
      },
    );

    if (selectedOption == null) return;

    setState(() => _sortOption = selectedOption);
  }

  Future<void> _showFilterSheet() async {
    final selectedFilter = await showModalBottomSheet<_FlightFilter>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (context) {
        return _SelectionSheet<_FlightFilter>(
          title: 'Filtrer',
          selectedValue: _filter,
          values: _FlightFilter.values,
          labelBuilder: (filter) => filter.label,
        );
      },
    );

    if (selectedFilter == null) return;

    setState(() => _filter = selectedFilter);
  }

  void _chooseFlight(_FlightOption flight, _SearchCriteria criteria) {
    Navigator.pushNamed(
      context,
      AppRoutes.flightDetails,
      arguments: {
        'airline': flight.airline,
        'flightNumber': flight.flightNumber,
        'departureCode': flight.departureCode,
        'departureTime': flight.departureTime,
        'arrivalCode': flight.arrivalCode,
        'arrivalTime': flight.arrivalTime,
        'duration': flight.duration,
        'isDirect': flight.isDirect,
        'price': flight.price,
        'criteria': criteria.toArguments(),
      },
    );
  }
}

class _SearchCriteria {
  const _SearchCriteria({
    required this.tripType,
    required this.departureCity,
    required this.departureCode,
    required this.destinationCity,
    required this.destinationCode,
    required this.departureDate,
    required this.returnDate,
    required this.passengers,
    required this.travelClass,
  });

  final String tripType;
  final String departureCity;
  final String departureCode;
  final String destinationCity;
  final String destinationCode;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String passengers;
  final String travelClass;

  factory _SearchCriteria.fromRouteArguments(Object? arguments) {
    if (arguments is! Map) return _SearchCriteria.demo();

    return _SearchCriteria(
      tripType: _readString(arguments, 'tripType', 'Aller-retour'),
      departureCity: _readString(arguments, 'departureCity', 'Lomé'),
      departureCode: _readString(arguments, 'departureCode', 'LFW'),
      destinationCity: _readString(arguments, 'destinationCity', 'Accra'),
      destinationCode: _readString(arguments, 'destinationCode', 'ACC'),
      departureDate: _readDate(
        arguments['departureDate'],
        DateTime(2026, 9, 12),
      ),
      returnDate: _readNullableDate(arguments['returnDate']),
      passengers: _readString(arguments, 'passengers', '1 adulte'),
      travelClass: _readString(arguments, 'travelClass', 'Économique'),
    );
  }

  factory _SearchCriteria.demo() {
    return _SearchCriteria(
      tripType: 'Aller-retour',
      departureCity: 'Lomé',
      departureCode: 'LFW',
      destinationCity: 'Accra',
      destinationCode: 'ACC',
      departureDate: DateTime(2026, 9, 12),
      returnDate: DateTime(2026, 9, 19),
      passengers: '1 adulte',
      travelClass: 'Économique',
    );
  }

  Map<String, Object?> toArguments() {
    return {
      'tripType': tripType,
      'departureCity': departureCity,
      'departureCode': departureCode,
      'destinationCity': destinationCity,
      'destinationCode': destinationCode,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'passengers': passengers,
      'travelClass': travelClass,
    };
  }

  static String _readString(
    Map<dynamic, dynamic> arguments,
    String key,
    String fallback,
  ) {
    final value = arguments[key];
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static DateTime _readDate(Object? value, DateTime fallback) {
    if (value is String) return DateTime.tryParse(value) ?? fallback;
    if (value is DateTime) return value;
    return fallback;
  }

  static DateTime? _readNullableDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _FlightOption {
  const _FlightOption({
    required this.airline,
    required this.flightNumber,
    required this.departureCode,
    required this.departureTime,
    required this.arrivalCode,
    required this.arrivalTime,
    required this.duration,
    required this.durationMinutes,
    required this.isDirect,
    required this.price,
  });

  final String airline;
  final String flightNumber;
  final String departureCode;
  final String departureTime;
  final String arrivalCode;
  final String arrivalTime;
  final String duration;
  final int durationMinutes;
  final bool isDirect;
  final int price;
}

class _SearchSummaryCard extends StatelessWidget {
  const _SearchSummaryCard({required this.criteria});

  final _SearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    final dateLine = criteria.returnDate == null
        ? _formatShortDate(criteria.departureDate)
        : '${_formatShortDate(criteria.departureDate)} - '
              '${_formatShortDate(criteria.returnDate!)}';

    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${criteria.departureCity} → ${criteria.destinationCity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.searchFlight),
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${criteria.departureCity} (${criteria.departureCode}) → '
            '${criteria.destinationCity} (${criteria.destinationCode})',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateLine,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${criteria.passengers} · ${criteria.travelClass}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortFilterBar extends StatelessWidget {
  const _SortFilterBar({
    required this.sortLabel,
    required this.filterLabel,
    required this.onSortTap,
    required this.onFilterTap,
  });

  final String sortLabel;
  final String filterLabel;
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChipButton(
            icon: Icons.sort,
            label: 'Trier',
            value: sortLabel,
            onTap: onSortTap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionChipButton(
            icon: Icons.tune,
            label: 'Filtrer',
            value: filterLabel,
            onTap: onFilterTap,
          ),
        ),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightResultCard extends StatelessWidget {
  const _FlightResultCard({required this.flight, required this.onChoose});

  final _FlightOption flight;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  flight.airline,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                flight.flightNumber,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _FlightTimeline(flight: flight),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.isDirect ? 'Direct' : 'Avec escale',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatPrice(flight.price),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onChoose,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(96, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: const Text(
                  'Choisir',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlightTimeline extends StatelessWidget {
  const _FlightTimeline({required this.flight});

  final _FlightOption flight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimeAirportBlock(
          time: flight.departureTime,
          code: flight.departureCode,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                Text(
                  flight.duration,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: const [
                    _TimelineDot(),
                    Expanded(child: Divider(color: AppColors.border)),
                    Icon(Icons.flight, color: AppColors.secondary, size: 18),
                    Expanded(child: Divider(color: AppColors.border)),
                    _TimelineDot(),
                  ],
                ),
              ],
            ),
          ),
        ),
        _TimeAirportBlock(time: flight.arrivalTime, code: flight.arrivalCode),
      ],
    );
  }
}

class _TimeAirportBlock extends StatelessWidget {
  const _TimeAirportBlock({required this.time, required this.code});

  final String time;
  final String code;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            code,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      child: Column(
        children: [
          const Icon(
            Icons.flight_takeoff_outlined,
            color: AppColors.secondary,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun vol disponible pour ces critères.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.searchFlight),
            child: const Text('Modifier la recherche'),
          ),
        ],
      ),
    );
  }
}

class _SelectionSheet<T> extends StatelessWidget {
  const _SelectionSheet({
    required this.title,
    required this.selectedValue,
    required this.values,
    required this.labelBuilder,
  });

  final String title;
  final T selectedValue;
  final List<T> values;
  final String Function(T value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            ...values.map((value) {
              final selected = value == selectedValue;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  labelBuilder(value),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, value),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child});

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

String _formatShortDate(DateTime date) {
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];

  return '${date.day} ${months[date.month - 1]}';
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
