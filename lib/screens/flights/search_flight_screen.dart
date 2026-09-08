import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

enum _TripType {
  oneWay('Aller simple'),
  roundTrip('Aller-retour'),
  multiCity('Multi-villes');

  const _TripType(this.label);

  final String label;
}

enum _TravelClass {
  economy('Économique'),
  business('Affaires');

  const _TravelClass(this.label);

  final String label;
}

class SearchFlightScreen extends StatefulWidget {
  const SearchFlightScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  State<SearchFlightScreen> createState() => _SearchFlightScreenState();
}

class _SearchFlightScreenState extends State<SearchFlightScreen> {
  final TextEditingController _promoCodeController = TextEditingController();

  _TripType _tripType = _TripType.roundTrip;
  _TravelClass _travelClass = _TravelClass.economy;
  DateTime _departureDate = DateTime(2026, 9, 12);
  DateTime _returnDate = DateTime(2026, 9, 19);
  int _adultCount = 1;
  int _childCount = 0;
  int _infantCount = 0;

  _Airport _departure = const _Airport(city: 'Lomé', code: 'LFW');
  _Airport _destination = const _Airport(city: 'Accra', code: 'ACC');

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: !widget.showAppBar,
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
              _TripTypeSelector(
                selectedTripType: _tripType,
                onChanged: _changeTripType,
              ),
              const SizedBox(height: AppSpacing.md),
              _FlightRouteCard(
                departure: _departure,
                destination: _destination,
                onSwap: _swapAirports,
              ),
              const SizedBox(height: AppSpacing.md),
              _DateSection(
                tripType: _tripType,
                departureDate: _departureDate,
                returnDate: _returnDate,
                onSelectDeparture: () => _selectDepartureDate(context),
                onSelectReturn: () => _selectReturnDate(context),
              ),
              const SizedBox(height: AppSpacing.md),
              _PassengerClassSection(
                passengerSummary: _passengerSummary,
                travelClass: _travelClass,
                onPassengersTap: () => _showPassengerSheet(context),
                onClassChanged: (value) {
                  if (value == null) return;
                  setState(() => _travelClass = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _PromoCodeField(controller: _promoCodeController),
              const SizedBox(height: AppSpacing.lg),
              _SearchButton(onPressed: _searchFlights),
            ],
          ),
        ),
      ),
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Rechercher un vol'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: content,
    );
  }

  void _changeTripType(_TripType tripType) {
    setState(() {
      _tripType = tripType;
      if (_returnDate.isBefore(_departureDate)) {
        _returnDate = _departureDate.add(const Duration(days: 1));
      }
    });
  }

  void _swapAirports() {
    setState(() {
      final previousDeparture = _departure;
      _departure = _destination;
      _destination = previousDeparture;
    });
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final selectedDate = await _pickDate(
      context,
      initialDate: _departureDate,
      firstDate: DateTime(2026),
    );

    if (selectedDate == null) return;

    setState(() {
      _departureDate = selectedDate;
      if (_returnDate.isBefore(_departureDate)) {
        _returnDate = _departureDate.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final selectedDate = await _pickDate(
      context,
      initialDate: _returnDate.isBefore(_departureDate)
          ? _departureDate.add(const Duration(days: 1))
          : _returnDate,
      firstDate: _departureDate,
    );

    if (selectedDate == null) return;

    setState(() => _returnDate = selectedDate);
  }

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2028, 12, 31),
    );
  }

  Future<void> _showPassengerSheet(BuildContext context) async {
    var adults = _adultCount;
    var children = _childCount;
    var infants = _infantCount;

    final result = await showModalBottomSheet<_PassengerSelection>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
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
                  Text('Passagers', style: AppTextStyles.screenTitle),
                  const SizedBox(height: AppSpacing.md),
                  _PassengerCounterRow(
                    label: 'Adultes',
                    value: adults,
                    canDecrease: adults > 1,
                    onDecrease: () => setSheetState(() => adults--),
                    onIncrease: () => setSheetState(() => adults++),
                  ),
                  _PassengerCounterRow(
                    label: 'Enfants',
                    value: children,
                    canDecrease: children > 0,
                    onDecrease: () => setSheetState(() => children--),
                    onIncrease: () => setSheetState(() => children++),
                  ),
                  _PassengerCounterRow(
                    label: 'Bébés',
                    value: infants,
                    canDecrease: infants > 0,
                    onDecrease: () => setSheetState(() => infants--),
                    onIncrease: () => setSheetState(() => infants++),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _PassengerSelection(
                            adults: adults,
                            children: children,
                            infants: infants,
                          ),
                        );
                      },
                      child: const Text('Valider'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      _adultCount = result.adults;
      _childCount = result.children;
      _infantCount = result.infants;
    });
  }

  void _searchFlights() {
    Navigator.pushNamed(
      context,
      AppRoutes.flightResults,
      arguments: {
        'tripType': _tripType.label,
        'departureCity': _departure.city,
        'departureCode': _departure.code,
        'destinationCity': _destination.city,
        'destinationCode': _destination.code,
        'departureDate': _departureDate.toIso8601String(),
        'returnDate': _tripType == _TripType.oneWay
            ? null
            : _returnDate.toIso8601String(),
        'passengers': _passengerSummary,
        'travelClass': _travelClass.label,
        'promoCode': _promoCodeController.text.trim(),
      },
    );
  }

  String get _passengerSummary {
    final parts = [
      _pluralize(_adultCount, 'adulte'),
      if (_childCount > 0) _pluralize(_childCount, 'enfant'),
      if (_infantCount > 0) _pluralize(_infantCount, 'bébé', plural: 'bébés'),
    ];

    return parts.join(', ');
  }

  String _pluralize(int count, String singular, {String? plural}) {
    if (count == 1) return '1 $singular';
    return '$count ${plural ?? '${singular}s'}';
  }
}

class _Airport {
  const _Airport({required this.city, required this.code});

  final String city;
  final String code;
}

class _PassengerSelection {
  const _PassengerSelection({
    required this.adults,
    required this.children,
    required this.infants,
  });

  final int adults;
  final int children;
  final int infants;
}

class _TripTypeSelector extends StatelessWidget {
  const _TripTypeSelector({
    required this.selectedTripType,
    required this.onChanged,
  });

  final _TripType selectedTripType;
  final ValueChanged<_TripType> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Row(
        children: _TripType.values.map((tripType) {
          final isSelected = tripType == selectedTripType;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.small),
              onTap: () => onChanged(tripType),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  tripType.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

class _FlightRouteCard extends StatelessWidget {
  const _FlightRouteCard({
    required this.departure,
    required this.destination,
    required this.onSwap,
  });

  final _Airport departure;
  final _Airport destination;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        children: [
          _AirportField(
            label: 'DÉPART',
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
            label: 'DESTINATION',
            airport: destination,
            icon: Icons.flight_land,
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
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
                    fontSize: 11,
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

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.tripType,
    required this.departureDate,
    required this.returnDate,
    required this.onSelectDeparture,
    required this.onSelectReturn,
  });

  final _TripType tripType;
  final DateTime departureDate;
  final DateTime returnDate;
  final VoidCallback onSelectDeparture;
  final VoidCallback onSelectReturn;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dates',
            style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          _DateField(
            label: 'Date de départ',
            value: _formatDate(departureDate),
            onTap: onSelectDeparture,
          ),
          if (tripType != _TripType.oneWay) ...[
            const SizedBox(height: AppSpacing.sm),
            _DateField(
              label: 'Date de retour',
              value: _formatDate(returnDate),
              onTap: onSelectReturn,
            ),
          ],
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
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
              child: _FieldText(label: label, value: value),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PassengerClassSection extends StatelessWidget {
  const _PassengerClassSection({
    required this.passengerSummary,
    required this.travelClass,
    required this.onPassengersTap,
    required this.onClassChanged,
  });

  final String passengerSummary;
  final _TravelClass travelClass;
  final VoidCallback onPassengersTap;
  final ValueChanged<_TravelClass?> onClassChanged;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            onTap: onPassengersTap,
            child: _FieldSurface(
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _FieldText(
                      label: 'Passagers',
                      value: passengerSummary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FieldSurface(
            child: Row(
              children: [
                const Icon(
                  Icons.airline_seat_recline_normal_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    'Classe',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<_TravelClass>(
                    value: travelClass,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    items: _TravelClass.values.map((travelClass) {
                      return DropdownMenuItem<_TravelClass>(
                        value: travelClass,
                        child: Text(travelClass.label),
                      );
                    }).toList(),
                    onChanged: onClassChanged,
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

class _PassengerCounterRow extends StatelessWidget {
  const _PassengerCounterRow({
    required this.label,
    required this.value,
    required this.canDecrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final bool canDecrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton.outlined(
            onPressed: canDecrease ? onDecrease : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton.filled(onPressed: onIncrease, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}

class _PromoCodeField extends StatelessWidget {
  const _PromoCodeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Code promo',
          hintText: 'Ajouter un code promo',
          prefixIcon: Icon(Icons.confirmation_number_outlined),
          border: InputBorder.none,
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
          'Rechercher les vols',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

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

class _FieldText extends StatelessWidget {
  const _FieldText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
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
