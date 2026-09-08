import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

enum _DestinationRegion {
  all('Toutes'),
  westAfrica('Afrique de l’Ouest'),
  centralAfrica('Afrique centrale'),
  eastAfrica('Afrique de l’Est');

  const _DestinationRegion(this.label);

  final String label;
}

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _DestinationRegion _selectedRegion = _DestinationRegion.all;
  String _searchQuery = '';

  static const List<_Destination> _destinations = [
    _Destination(
      city: 'Accra',
      country: 'Ghana',
      code: 'ACC',
      region: _DestinationRegion.westAfrica,
      language: 'Anglais',
      currency: 'Cedi ghanéen',
      timeZone: 'GMT',
    ),
    _Destination(
      city: 'Abidjan',
      country: 'Côte d’Ivoire',
      code: 'ABJ',
      region: _DestinationRegion.westAfrica,
      language: 'Français',
      currency: 'Franc CFA',
      timeZone: 'GMT',
    ),
    _Destination(
      city: 'Dakar',
      country: 'Sénégal',
      code: 'DSS',
      region: _DestinationRegion.westAfrica,
      language: 'Français',
      currency: 'Franc CFA',
      timeZone: 'GMT',
    ),
    _Destination(
      city: 'Cotonou',
      country: 'Bénin',
      code: 'COO',
      region: _DestinationRegion.westAfrica,
      language: 'Français',
      currency: 'Franc CFA',
      timeZone: 'GMT+1',
    ),
    _Destination(
      city: 'Lagos',
      country: 'Nigeria',
      code: 'LOS',
      region: _DestinationRegion.westAfrica,
      language: 'Anglais',
      currency: 'Naira',
      timeZone: 'GMT+1',
    ),
    _Destination(
      city: 'Douala',
      country: 'Cameroun',
      code: 'DLA',
      region: _DestinationRegion.centralAfrica,
      language: 'Français, anglais',
      currency: 'Franc CFA',
      timeZone: 'GMT+1',
    ),
    _Destination(
      city: 'Libreville',
      country: 'Gabon',
      code: 'LBV',
      region: _DestinationRegion.centralAfrica,
      language: 'Français',
      currency: 'Franc CFA',
      timeZone: 'GMT+1',
    ),
    _Destination(
      city: 'Nairobi',
      country: 'Kenya',
      code: 'NBO',
      region: _DestinationRegion.eastAfrica,
      language: 'Swahili, anglais',
      currency: 'Shilling kényan',
      timeZone: 'GMT+3',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDestinations = _filteredDestinations;
    final showPopular =
        _searchQuery.trim().isEmpty &&
        _selectedRegion == _DestinationRegion.all;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Destinations'),
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
                Text(
                  'Découvrez votre prochaine destination',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.md),
                _DestinationSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSpacing.md),
                _RegionFilters(
                  selectedRegion: _selectedRegion,
                  onChanged: (region) =>
                      setState(() => _selectedRegion = region),
                ),
                if (showPopular) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _PopularDestinations(
                    destinations: _destinations.take(3).toList(),
                    onTap: _showDestinationDetails,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Toutes les destinations',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.md),
                if (filteredDestinations.isEmpty)
                  const _EmptyDestinations()
                else
                  ...filteredDestinations.map(
                    (destination) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _DestinationListItem(
                        destination: destination,
                        onTap: () => _showDestinationDetails(destination),
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

  List<_Destination> get _filteredDestinations {
    final normalizedQuery = _normalize(_searchQuery);

    return _destinations.where((destination) {
      final matchesRegion =
          _selectedRegion == _DestinationRegion.all ||
          destination.region == _selectedRegion;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          _normalize(destination.city).contains(normalizedQuery) ||
          _normalize(destination.country).contains(normalizedQuery) ||
          _normalize(destination.code).contains(normalizedQuery);

      return matchesRegion && matchesSearch;
    }).toList();
  }

  void _showDestinationDetails(_Destination destination) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (context) => _DestinationDetailsSheet(destination: destination),
    );
  }
}

class _Destination {
  const _Destination({
    required this.city,
    required this.country,
    required this.code,
    required this.region,
    required this.language,
    required this.currency,
    required this.timeZone,
  });

  final String city;
  final String country;
  final String code;
  final _DestinationRegion region;
  final String language;
  final String currency;
  final String timeZone;

  Map<String, String> toArguments() {
    return {
      'destinationCity': city,
      'destinationCountry': country,
      'destinationCode': code,
    };
  }
}

class _DestinationSearchField extends StatelessWidget {
  const _DestinationSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        hintText: 'Rechercher une ville ou un pays',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
      ),
    );
  }
}

class _RegionFilters extends StatelessWidget {
  const _RegionFilters({required this.selectedRegion, required this.onChanged});

  final _DestinationRegion selectedRegion;
  final ValueChanged<_DestinationRegion> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _DestinationRegion.values.map((region) {
          final selected = region == selectedRegion;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(region.label),
              selected: selected,
              onSelected: (_) => onChanged(region),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PopularDestinations extends StatelessWidget {
  const _PopularDestinations({required this.destinations, required this.onTap});

  final List<_Destination> destinations;
  final ValueChanged<_Destination> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinations populaires',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final destination = destinations[index];

              return _PopularDestinationCard(
                destination: destination,
                onTap: () => onTap(destination),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemCount: destinations.length,
          ),
        ),
      ],
    );
  }
}

class _PopularDestinationCard extends StatelessWidget {
  const _PopularDestinationCard({
    required this.destination,
    required this.onTap,
  });

  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_outlined, color: AppColors.white),
                const Spacer(),
                Text(
                  destination.code,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              destination.city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              destination.country,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.82),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationListItem extends StatelessWidget {
  const _DestinationListItem({required this.destination, required this.onTap});

  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Text(
                destination.code,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
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
                    destination.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    destination.country,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    destination.region.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

class _DestinationDetailsSheet extends StatelessWidget {
  const _DestinationDetailsSheet({required this.destination});

  final _Destination destination;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination.city,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${destination.country} · Aéroport : ${destination.code}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              _DestinationInfoLine(
                label: 'Langue',
                value: destination.language,
              ),
              _DestinationInfoLine(
                label: 'Monnaie',
                value: destination.currency,
              ),
              _DestinationInfoLine(
                label: 'Fuseau horaire',
                value: destination.timeZone,
              ),
              const _DestinationInfoLine(
                label: 'Type',
                value: 'Destination ASKY - données de démonstration',
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.searchFlight,
                      arguments: destination.toArguments(),
                    );
                  },
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
          ),
        ),
      ),
    );
  }
}

class _DestinationInfoLine extends StatelessWidget {
  const _DestinationInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDestinations extends StatelessWidget {
  const _EmptyDestinations();

  @override
  Widget build(BuildContext context) {
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
          const Icon(
            Icons.travel_explore_outlined,
            color: AppColors.secondary,
            size: 42,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune destination trouvée.',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Essayez une autre recherche.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ç', 'c')
      .trim();
}
