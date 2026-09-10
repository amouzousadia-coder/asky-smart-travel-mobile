import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _baggageTagController = TextEditingController();

  _SupportRouteContext? _routeContext;
  String? _selectedCategory;
  String? _selectedTrip;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeContext != null) return;

    final routeContext = _SupportRouteContext.fromRoute(context);
    _routeContext = routeContext;
    _selectedCategory = routeContext.initialCategory;
    _selectedTrip = routeContext.bookingReference ?? _selectedTrip;
    _baggageTagController.text = routeContext.baggageTag ?? '';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _baggageTagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = _SupportRequestDraft(
      category: _selectedCategory!,
      bookingReference: _routeContext?.bookingReference ?? _selectedTrip,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      baggageTag: _baggageTagController.text.trim().isEmpty
          ? null
          : _baggageTagController.text.trim(),
    );

    // TODO backend: resolve the authenticated user from the JWT.
    // TODO backend: never accept an arbitrary passengerId from Flutter.
    // TODO backend: automatically link the ticket to the signed-in passenger.
    // TODO backend: verify that bookingReference belongs to the passenger.
    // TODO backend: validate attachments on the backend.
    // TODO backend: limit attachment file size and file type.
    // TODO backend: audit status changes.
    // TODO backend: rate-limit ticket creation.
    debugPrint('Demo support request: ${draft.toLogValue()}');

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeContext =
        _routeContext ?? _SupportRouteContext.fromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Assistance'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _isSubmitted
                  ? _SupportSuccessState(routeContext: routeContext)
                  : _SupportForm(
                      formKey: _formKey,
                      routeContext: routeContext,
                      selectedCategory: _selectedCategory,
                      selectedTrip: _selectedTrip,
                      subjectController: _subjectController,
                      descriptionController: _descriptionController,
                      baggageTagController: _baggageTagController,
                      isSubmitting: _isSubmitting,
                      onCategoryChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      onTripChanged: (value) {
                        setState(() => _selectedTrip = value);
                      },
                      onSubmit: _submit,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportForm extends StatelessWidget {
  const _SupportForm({
    required this.formKey,
    required this.routeContext,
    required this.selectedCategory,
    required this.selectedTrip,
    required this.subjectController,
    required this.descriptionController,
    required this.baggageTagController,
    required this.isSubmitting,
    required this.onCategoryChanged,
    required this.onTripChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final _SupportRouteContext routeContext;
  final String? selectedCategory;
  final String? selectedTrip;
  final TextEditingController subjectController;
  final TextEditingController descriptionController;
  final TextEditingController baggageTagController;
  final bool isSubmitting;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onTripChanged;
  final VoidCallback onSubmit;

  bool get _showsBaggage => selectedCategory == 'Bagages';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SupportHeader(),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('support-category-field'),
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: _supportCategories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Veuillez choisir une catégorie.' : null,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: AppSpacing.lg),
                _TripSection(
                  routeContext: routeContext,
                  selectedTrip: selectedTrip,
                  onTripChanged: onTripChanged,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  key: const Key('support-subject-field'),
                  controller: subjectController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Sujet',
                    hintText: 'Ex. Mon bagage n’est pas arrivé',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le sujet de votre demande.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  key: const Key('support-description-field'),
                  controller: descriptionController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                    labelText: 'Décrivez votre problème',
                    hintText:
                        'Donnez-nous les informations utiles pour comprendre votre demande...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Veuillez donner un peu plus de détails.';
                    }
                    return null;
                  },
                ),
                if (_showsBaggage) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _BaggageTagField(controller: baggageTagController),
                ],
                const SizedBox(height: AppSpacing.lg),
                const _PriorityNotice(),
                const SizedBox(height: AppSpacing.lg),
                const _AttachmentArea(),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('support-submit-button'),
                    onPressed: isSubmitting ? null : onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      isSubmitting ? 'Envoi...' : 'Envoyer ma demande',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
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

class _SupportHeader extends StatelessWidget {
  const _SupportHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Comment pouvons-nous vous aider ?',
          style: AppTextStyles.screenTitle,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Décrivez votre problème et suivez ensuite l’avancement de votre demande.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}

class _TripSection extends StatelessWidget {
  const _TripSection({
    required this.routeContext,
    required this.selectedTrip,
    required this.onTripChanged,
  });

  final _SupportRouteContext routeContext;
  final String? selectedTrip;
  final ValueChanged<String?> onTripChanged;

  @override
  Widget build(BuildContext context) {
    if (routeContext.bookingReference != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Voyage concerné'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeContext.bookingReference!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${routeContext.departureCity} → ${routeContext.destinationCity}',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(routeContext.flightNumber, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      key: const Key('support-trip-field'),
      initialValue: selectedTrip,
      decoration: const InputDecoration(labelText: 'Voyage concerné'),
      items: const [
        DropdownMenuItem(
          value: 'ASKY7D2',
          child: Text('ASKY7D2 · Lomé → Accra'),
        ),
        DropdownMenuItem(
          value: 'ASKY9K4',
          child: Text('ASKY9K4 · Lomé → Abidjan'),
        ),
        DropdownMenuItem(value: 'none', child: Text('Aucun voyage spécifique')),
      ],
      onChanged: onTripChanged,
    );
  }
}

class _BaggageTagField extends StatelessWidget {
  const _BaggageTagField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('support-baggage-tag-field'),
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Étiquette du bagage',
        hintText: 'Ex. BG-ASKY-20481',
      ),
    );
  }
}

class _PriorityNotice extends StatelessWidget {
  const _PriorityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E0),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Nous traiterons votre demande selon sa nature et son urgence.',
              style: TextStyle(color: AppColors.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentArea extends StatelessWidget {
  const _AttachmentArea();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter une pièce jointe',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Photo du bagage, reçu ou document utile.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ajout de pièce jointe à venir.')),
            ),
            icon: const Icon(Icons.attach_file),
            label: const Text('Ajouter une pièce jointe'),
          ),
        ],
      ),
    );
  }
}

class _SupportSuccessState extends StatelessWidget {
  const _SupportSuccessState({required this.routeContext});

  final _SupportRouteContext routeContext;

  @override
  Widget build(BuildContext context) {
    final hasLinkedTrip = routeContext.bookingReference != null;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF177245), size: 44),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Demande envoyée',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Votre demande ASKY-2048 a bien été enregistrée.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          const _StatusBadge(status: 'Nouveau'),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('support-my-requests-button'),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.myRequests),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text(
                'Voir mes demandes',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('support-return-button'),
              onPressed: () => Navigator.pushNamed(
                context,
                hasLinkedTrip ? AppRoutes.tripDetails : AppRoutes.dashboard,
                arguments: hasLinkedTrip
                    ? routeContext.toTripArguments()
                    : null,
              ),
              icon: Icon(
                hasLinkedTrip ? Icons.flight_takeoff : Icons.dashboard_outlined,
              ),
              label: Text(
                hasLinkedTrip ? 'Retour à mon voyage' : 'Retour au Dashboard',
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

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
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SupportRouteContext {
  const _SupportRouteContext({
    this.category,
    this.bookingReference,
    this.baggageTag,
    required this.flightNumber,
    required this.departureCity,
    required this.destinationCity,
  });

  factory _SupportRouteContext.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const <String, Object?>{};

    return _SupportRouteContext(
      category: _readNullableString(values, 'category'),
      bookingReference: _readNullableString(values, 'bookingReference'),
      baggageTag: _readNullableString(values, 'baggageTag'),
      flightNumber: _readString(values, 'flightNumber', 'KP 020'),
      departureCity: _readString(values, 'departureCity', 'Lomé'),
      destinationCity: _readString(values, 'destinationCity', 'Accra'),
    );
  }

  final String? category;
  final String? bookingReference;
  final String? baggageTag;
  final String flightNumber;
  final String departureCity;
  final String destinationCity;

  String? get initialCategory {
    final normalized = category?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized == 'baggage' || normalized == 'bagage') return 'Bagages';

    for (final categoryLabel in _supportCategories) {
      if (categoryLabel.toLowerCase() == normalized) return categoryLabel;
    }

    return null;
  }

  Map<String, Object?> toTripArguments() {
    return {
      'bookingReference': bookingReference,
      'flightNumber': flightNumber,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
    };
  }

  static String _readString(
    Map<dynamic, dynamic> values,
    String key,
    String fallback,
  ) {
    final value = values[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String? _readNullableString(Map<dynamic, dynamic> values, String key) {
    final value = values[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }
}

class _SupportRequestDraft {
  const _SupportRequestDraft({
    required this.category,
    required this.bookingReference,
    required this.subject,
    required this.description,
    this.baggageTag,
  });

  final String category;
  final String? bookingReference;
  final String subject;
  final String description;
  final String? baggageTag;

  Map<String, Object?> toLogValue() {
    return {
      'category': category,
      'bookingReference': bookingReference == 'none' ? null : bookingReference,
      'subject': subject,
      'description': description,
      'baggageTag': baggageTag,
    };
  }
}

const _supportCategories = [
  'Réservation',
  'Paiement',
  'Vol retardé / annulé',
  'Bagages',
  'Documents de voyage',
  'Assistance spéciale',
  'ASKY Club',
  'Autre',
];
