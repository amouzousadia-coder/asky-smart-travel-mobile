import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum _SearchMode {
  flightNumber('Numéro de vol'),
  route('Itinéraire');

  const _SearchMode(this.label);

  final String label;
}

enum _FlightStatus {
  onTime('À l’heure', AppColors.successSurface, AppColors.success),
  delayed('Retardé', AppColors.warningSurface, AppColors.warning),
  boarding('Embarquement', AppColors.surface, AppColors.brandBordeaux),
  inFlight('En vol', AppColors.surface, AppColors.primary),
  arrived('Arrivé', Color(0xFFE8F5E9), Color(0xFF2E7D32)),
  canceled('Annulé', Color(0xFFFFEBEE), Color(0xFFC62828));

  const _FlightStatus(this.label, this.backgroundColor, this.textColor);

  final String label;
  final Color backgroundColor;
  final Color textColor;
}

const List<_FlightStatus> _supportedFlightStatuses = [
  _FlightStatus.onTime,
  _FlightStatus.delayed,
  _FlightStatus.boarding,
  _FlightStatus.inFlight,
  _FlightStatus.arrived,
  _FlightStatus.canceled,
];

class FlightStatusScreen extends StatefulWidget {
  const FlightStatusScreen({super.key});

  @override
  State<FlightStatusScreen> createState() => _FlightStatusScreenState();
}

class _FlightStatusScreenState extends State<FlightStatusScreen> {
  final TextEditingController _flightNumberController = TextEditingController();

  _SearchMode _searchMode = _SearchMode.flightNumber;
  DateTime _flightDate = DateTime(2026, 9, 12);
  bool _hasSearched = false;
  String? _flightNumberError;
  _Airport _departure = const _Airport(city: 'Lomé', code: 'LFW');
  _Airport _destination = const _Airport(city: 'Accra', code: 'ACC');

  @override
  void dispose() {
    _flightNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Statut du vol'),
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
                _SearchModeSelector(
                  selectedMode: _searchMode,
                  onChanged: _changeMode,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_searchMode == _SearchMode.flightNumber)
                  _FlightNumberForm(
                    controller: _flightNumberController,
                    date: _flightDate,
                    errorText: _flightNumberError,
                    onDateTap: _selectFlightDate,
                    onSearch: _search,
                  )
                else
                  _RouteForm(
                    departure: _departure,
                    destination: _destination,
                    date: _flightDate,
                    onSwap: _swapAirports,
                    onDateTap: _selectFlightDate,
                    onSearch: _search,
                  ),
                const SizedBox(height: AppSpacing.lg),
                if (_hasSearched)
                  _FlightStatusResultCard(
                    result: _FlightStatusResult.demo(
                      departure: _departure,
                      destination: _destination,
                      date: _flightDate,
                    ),
                  )
                else
                  const _InitialStatusHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeMode(_SearchMode mode) {
    setState(() {
      _searchMode = mode;
      _flightNumberError = null;
      _hasSearched = false;
    });
  }

  void _swapAirports() {
    setState(() {
      final previousDeparture = _departure;
      _departure = _destination;
      _destination = previousDeparture;
    });
  }

  Future<void> _selectFlightDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _flightDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2028, 12, 31),
    );

    if (selectedDate == null) return;

    setState(() => _flightDate = selectedDate);
  }

  void _search() {
    if (_searchMode == _SearchMode.flightNumber &&
        _flightNumberController.text.trim().isEmpty) {
      setState(() {
        _flightNumberError = 'Veuillez saisir un numéro de vol.';
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _flightNumberError = null;
      _hasSearched = true;
    });
  }
}

class _Airport {
  const _Airport({required this.city, required this.code});

  final String city;
  final String code;
}

class _FlightStatusResult {
  const _FlightStatusResult({
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.gate,
    required this.terminal,
    required this.status,
    required this.date,
  });

  final String airline;
  final String flightNumber;
  final _Airport departure;
  final _Airport destination;
  final String departureTime;
  final String arrivalTime;
  final String gate;
  final String terminal;
  final _FlightStatus status;
  final DateTime date;

  factory _FlightStatusResult.demo({
    required _Airport departure,
    required _Airport destination,
    required DateTime date,
  }) {
    return _FlightStatusResult(
      airline: 'ASKY',
      flightNumber: 'KP 020',
      departure: departure,
      destination: destination,
      departureTime: '08:30',
      arrivalTime: '09:20',
      gate: '4',
      terminal: 'Principal',
      status: _FlightStatus.onTime,
      date: date,
    );
  }
}

class _SearchModeSelector extends StatelessWidget {
  const _SearchModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  final _SearchMode selectedMode;
  final ValueChanged<_SearchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: _SearchMode.values.map((mode) {
          final isSelected = mode == selectedMode;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.small),
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FlightNumberForm extends StatelessWidget {
  const _FlightNumberForm({
    required this.controller,
    required this.date,
    required this.errorText,
    required this.onDateTap,
    required this.onSearch,
  });

  final TextEditingController controller;
  final DateTime date;
  final String? errorText;
  final VoidCallback onDateTap;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Numéro de vol',
              hintText: 'Ex. KP020',
              errorText: errorText,
              prefixIcon: const Icon(Icons.flight_takeoff_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DateField(date: date, onTap: onDateTap),
          const SizedBox(height: AppSpacing.lg),
          _SearchButton(onPressed: onSearch),
        ],
      ),
    );
  }
}

class _RouteForm extends StatelessWidget {
  const _RouteForm({
    required this.departure,
    required this.destination,
    required this.date,
    required this.onSwap,
    required this.onDateTap,
    required this.onSearch,
  });

  final _Airport departure;
  final _Airport destination;
  final DateTime date;
  final VoidCallback onSwap;
  final VoidCallback onDateTap;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      child: Column(
        children: [
          _AirportField(
            label: 'Départ',
            airport: departure,
            icon: Icons.flight_takeoff,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: IconButton.filled(
              onPressed: onSwap,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              icon: const Icon(Icons.swap_vert),
            ),
          ),
          _AirportField(
            label: 'Destination',
            airport: destination,
            icon: Icons.flight_land,
          ),
          const SizedBox(height: AppSpacing.md),
          _DateField(date: date, onTap: onDateTap),
          const SizedBox(height: AppSpacing.lg),
          _SearchButton(onPressed: onSearch),
        ],
      ),
    );
  }
}

class _AirportField extends StatelessWidget {
  const _AirportField({
    required this.label,
    required this.airport,
    required this.icon,
  });

  final String label;
  final _Airport airport;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _FieldSurface(
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  airport.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            airport.code,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: _FieldSurface(
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.secondary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date du vol',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatLongDate(date),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onPressed});

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
          'Rechercher',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _InitialStatusHint extends StatelessWidget {
  const _InitialStatusHint();

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_outlined,
            color: AppColors.secondary,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Recherchez un vol pour consulter son statut.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _FlightStatusResultCard extends StatelessWidget {
  const _FlightStatusResultCard({required this.result});

  final _FlightStatusResult result;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.airline,
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                ),
              ),
              Text(
                result.flightNumber,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatusTimeline(result: result),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Statut',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(status: result.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'Départ prévu', value: result.departureTime),
          _InfoRow(label: 'Arrivée prévue', value: result.arrivalTime),
          _InfoRow(label: 'Porte', value: result.gate),
          _InfoRow(label: 'Terminal', value: result.terminal),
          _InfoRow(label: 'Date', value: _formatLongDate(result.date)),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.result});

  final _FlightStatusResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimelineEndpoint(
          code: result.departure.code,
          time: result.departureTime,
          city: result.departure.city,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: const [
                Expanded(child: Divider(color: AppColors.border, thickness: 2)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Icon(Icons.flight, color: AppColors.secondary),
                ),
                Expanded(child: Divider(color: AppColors.border, thickness: 2)),
              ],
            ),
          ),
        ),
        _TimelineEndpoint(
          code: result.destination.code,
          time: result.arrivalTime,
          city: result.destination.city,
          alignEnd: true,
        ),
      ],
    );
  }
}

class _TimelineEndpoint extends StatelessWidget {
  const _TimelineEndpoint({
    required this.code,
    required this.time,
    required this.city,
    this.alignEnd = false,
  });

  final String code;
  final String time;
  final String city;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            code,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _FlightStatus status;

  @override
  Widget build(BuildContext context) {
    assert(_supportedFlightStatuses.contains(status));

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
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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

class _FieldSurface extends StatelessWidget {
  const _FieldSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
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
