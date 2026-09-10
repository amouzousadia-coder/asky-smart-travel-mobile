import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class BaggageScreen extends StatelessWidget {
  const BaggageScreen({this.showCheckedBaggage = true, super.key});

  final bool showCheckedBaggage;

  @override
  Widget build(BuildContext context) {
    final trip = _BaggageTripData.fromRoute(context);
    final baggageItems = showCheckedBaggage
        ? _demoBaggageItems
        : _demoBaggageItems.where((item) => !item.isChecked).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Mes bagages'),
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
                  _BaggageHeader(trip: trip),
                  const SizedBox(height: AppSpacing.md),
                  const _AllowanceSection(),
                  const SizedBox(height: AppSpacing.md),
                  _BaggageItemsSection(items: baggageItems),
                  const SizedBox(height: AppSpacing.md),
                  if (showCheckedBaggage)
                    const _TrackingCard()
                  else
                    const _NoCheckedBaggageState(),
                  const SizedBox(height: AppSpacing.md),
                  const _RulesCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _ExtraBaggageCard(),
                  const SizedBox(height: AppSpacing.md),
                  _BaggageSupportCard(trip: trip),
                  const SizedBox(height: AppSpacing.md),
                  _AssistantBaggageCard(trip: trip),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BaggageTripData {
  const _BaggageTripData({
    required this.bookingReference,
    required this.flightNumber,
    required this.departureCity,
    required this.destinationCity,
    required this.travelClass,
  });

  factory _BaggageTripData.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const <String, Object?>{};

    return _BaggageTripData(
      bookingReference: _readString(values, 'bookingReference', 'ASKY7D2'),
      flightNumber: _readString(values, 'flightNumber', 'KP 020'),
      departureCity: _readString(values, 'departureCity', 'Lomé'),
      destinationCity: _readString(values, 'destinationCity', 'Accra'),
      travelClass: _readString(values, 'travelClass', 'Economy'),
    );
  }

  final String bookingReference;
  final String flightNumber;
  final String departureCity;
  final String destinationCity;
  final String travelClass;

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

class _BaggageItem {
  const _BaggageItem({
    required this.id,
    required this.name,
    required this.type,
    required this.weight,
    required this.allowance,
    required this.status,
    required this.isChecked,
    this.tag,
  });

  final String id;
  final String name;
  final String type;
  final String weight;
  final String allowance;
  final String? tag;
  final String status;
  final bool isChecked;
}

class _BaggageTrackingStep {
  const _BaggageTrackingStep({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;
}

const _demoBaggageItems = [
  _BaggageItem(
    id: 'checked-1',
    name: 'Bagage 1',
    type: 'Soute',
    weight: '18,4 kg',
    allowance: 'Maximum 23 kg',
    tag: 'BG-ASKY-20481',
    status: 'Enregistré',
    isChecked: true,
  ),
  _BaggageItem(
    id: 'cabin-1',
    name: 'Bagage cabine',
    type: 'Cabine',
    weight: '6 kg estimé',
    allowance: 'Maximum 8 kg',
    status: 'Avec le passager',
    isChecked: false,
  ),
];

const _trackingSteps = [
  _BaggageTrackingStep(title: 'Bagage enregistré à Lomé', isCompleted: true),
  _BaggageTrackingStep(title: 'Contrôle effectué', isCompleted: true),
  _BaggageTrackingStep(title: 'Chargement dans l’avion', isCompleted: false),
  _BaggageTrackingStep(title: 'Arrivée à Accra', isCompleted: false),
  _BaggageTrackingStep(title: 'Disponible à la livraison', isCompleted: false),
];

class _BaggageHeader extends StatelessWidget {
  const _BaggageHeader({required this.trip});

  final _BaggageTripData trip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${trip.departureCity} → ${trip.destinationCity}',
          style: AppTextStyles.screenTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Vol ${trip.flightNumber} · Référence ${trip.bookingReference}',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Classe ${trip.travelClass}', style: AppTextStyles.body),
      ],
    );
  }
}

class _AllowanceSection extends StatelessWidget {
  const _AllowanceSection();

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'Votre franchise',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Données de démonstration pour le prototype, non officielles.',
            style: AppTextStyles.body,
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _AllowanceCard(
                title: 'Bagage cabine',
                icon: Icons.work_outline,
                quantity: '1 bagage',
                weight: 'Maximum : 8 kg',
                dimensions: '55 x 40 x 23 cm',
              ),
              _AllowanceCard(
                title: 'Bagage en soute',
                icon: Icons.luggage_outlined,
                quantity: '1 bagage',
                weight: 'Maximum : 23 kg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({
    required this.title,
    required this.icon,
    required this.quantity,
    required this.weight,
    this.dimensions,
  });

  final String title;
  final IconData icon;
  final String quantity;
  final String weight;
  final String? dimensions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(quantity, style: AppTextStyles.body),
            Text(weight, style: AppTextStyles.body),
            if (dimensions != null)
              Text(
                'Dimensions indicatives : $dimensions',
                style: AppTextStyles.body,
              ),
          ],
        ),
      ),
    );
  }
}

class _BaggageItemsSection extends StatelessWidget {
  const _BaggageItemsSection({required this.items});

  final List<_BaggageItem> items;

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'Bagages associés au voyage',
      child: Column(
        children: [
          for (final item in items) ...[
            _BaggageItemCard(item: item),
            if (item != items.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _BaggageItemCard extends StatelessWidget {
  const _BaggageItemCard({required this.item});

  final _BaggageItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.isChecked ? Icons.luggage_outlined : Icons.work_outline,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Type : ${item.type}', style: AppTextStyles.body),
                  ],
                ),
              ),
              _BaggageStatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'Poids', value: item.weight),
          _InfoRow(label: 'Franchise', value: item.allowance),
          if (item.tag != null) _InfoRow(label: 'Étiquette', value: item.tag!),
        ],
      ),
    );
  }
}

class _BaggageStatusBadge extends StatelessWidget {
  const _BaggageStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _BaggageStatusColors.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
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

class _BaggageStatusColors {
  const _BaggageStatusColors(this.background, this.foreground);

  factory _BaggageStatusColors.fromStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('retard') || normalized.contains('signal')) {
      return const _BaggageStatusColors(Color(0xFFFFF4E5), Color(0xFF9A5B00));
    }
    if (normalized.contains('arriv') || normalized.contains('disponible')) {
      return const _BaggageStatusColors(Color(0xFFE7F7EF), Color(0xFF177245));
    }
    if (normalized.contains('transit') || normalized.contains('charge')) {
      return const _BaggageStatusColors(Color(0xFFEAF3FF), Color(0xFF0957A5));
    }
    return const _BaggageStatusColors(Color(0xFFE7F7EF), Color(0xFF177245));
  }

  final Color background;
  final Color foreground;
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard();

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'Suivi du bagage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < _trackingSteps.length; index++) ...[
            _TrackingStep(step: _trackingSteps[index]),
            if (index < _trackingSteps.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 11),
                child: SizedBox(
                  height: 18,
                  child: VerticalDivider(color: AppColors.border, width: 1),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Le suivi en temps réel nécessitera plus tard une connexion aux systèmes opérationnels de la compagnie.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({required this.step});

  final _BaggageTrackingStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          step.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: step.isCompleted
              ? AppColors.secondary
              : AppColors.textSecondary,
          size: 22,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(step.title, style: AppTextStyles.body)),
      ],
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'À savoir',
      child: Column(
        children: const [
          _RuleTile(
            text:
                'Les objets dangereux ou interdits ne doivent pas être placés dans les bagages.',
          ),
          _RuleTile(
            text:
                'Les objets de valeur et documents importants sont préférables en cabine.',
          ),
          _RuleTile(
            text:
                'Le poids autorisé dépend du billet et de la classe de voyage.',
          ),
          _RuleTile(
            text:
                'Un excédent de bagage peut entraîner des frais supplémentaires.',
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _ExtraBaggageCard extends StatelessWidget {
  const _ExtraBaggageCard();

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'Besoin de plus de bagages ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Les options de bagage supplémentaire seront disponibles lorsque le service de réservation sera connecté.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Option à venir.'))),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('En savoir plus'),
          ),
        ],
      ),
    );
  }
}

class _BaggageSupportCard extends StatelessWidget {
  const _BaggageSupportCard({required this.trip});

  final _BaggageTripData trip;

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      title: 'Un problème avec votre bagage ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Signalez une difficulté afin de préparer la future assistance contextuelle.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          _FullWidthActionButton(
            label: 'Signaler un problème',
            icon: Icons.support_agent,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.support,
              arguments: {
                'category': 'baggage',
                'bookingReference': trip.bookingReference,
                'baggageTag': 'BG-ASKY-20481',
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantBaggageCard extends StatelessWidget {
  const _AssistantBaggageCard({required this.trip});

  final _BaggageTripData trip;

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
            'Une question sur vos bagages ?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.assistant,
              arguments: {
                'bookingReference': trip.bookingReference,
                'topic': 'baggage',
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

class _NoCheckedBaggageState extends StatelessWidget {
  const _NoCheckedBaggageState();

  @override
  Widget build(BuildContext context) {
    return _BaggageCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.work_outline, color: AppColors.primary, size: 30),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucun bagage en soute enregistré.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Votre bagage cabine reste soumis aux conditions de votre tarif.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
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
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
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

class _BaggageCard extends StatelessWidget {
  const _BaggageCard({required this.child, this.title});

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
