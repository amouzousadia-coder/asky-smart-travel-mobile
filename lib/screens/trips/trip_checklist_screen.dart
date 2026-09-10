import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class TripChecklistScreen extends StatefulWidget {
  const TripChecklistScreen({super.key});

  @override
  State<TripChecklistScreen> createState() => _TripChecklistScreenState();
}

class _TripChecklistScreenState extends State<TripChecklistScreen> {
  late _ChecklistTripData _trip;
  late List<_ChecklistItem> _tasks;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _trip = _ChecklistTripData.fromRoute(context);
    _tasks = _initialTasks();
    _isInitialized = true;
  }

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  double get _progress => _completedCount / _tasks.length;

  bool get _isComplete => _completedCount == _tasks.length;

  List<_ChecklistItem> get _sortedTasks {
    final sorted = [..._tasks];
    sorted.sort((a, b) {
      final aRank = a.sortRank;
      final bRank = b.sortRank;
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  List<_ChecklistItem> get _priorityTasks {
    return _tasks
        .where((task) => task.isImportant && !task.isCompleted)
        .take(2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_trip.isPast) {
      return _PastChecklistScreen(trip: _trip);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Préparer mon voyage'),
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
                  _ChecklistHeader(trip: _trip),
                  const SizedBox(height: AppSpacing.md),
                  _ChecklistProgressCard(
                    completedCount: _completedCount,
                    totalCount: _tasks.length,
                    progress: _progress,
                  ),
                  if (_isComplete) ...[
                    const SizedBox(height: AppSpacing.md),
                    const _CompletedStateCard(),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _PriorityCard(tasks: _priorityTasks),
                  const SizedBox(height: AppSpacing.md),
                  for (final task in _sortedTasks) ...[
                    _ChecklistTaskCard(
                      task: task,
                      onChanged: (value) => _toggleTask(task.id, value),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _AssistantHelpCard(trip: _trip),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTask(String taskId, bool isCompleted) {
    setState(() {
      _tasks = [
        for (final task in _tasks)
          if (task.id == taskId)
            task.copyWith(isCompleted: isCompleted)
          else
            task,
      ];
    });
  }
}

class _ChecklistTripData {
  const _ChecklistTripData({
    required this.bookingReference,
    required this.flightNumber,
    required this.departureCity,
    required this.destinationCity,
    required this.departureDate,
    required this.isPast,
  });

  factory _ChecklistTripData.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const <String, Object?>{};

    return _ChecklistTripData(
      bookingReference: _readString(values, 'bookingReference', 'ASKY7D2'),
      flightNumber: _readString(values, 'flightNumber', 'KP 020'),
      departureCity: _readString(values, 'departureCity', 'Lomé'),
      destinationCity: _readString(values, 'destinationCity', 'Accra'),
      departureDate: _readString(values, 'departureDate', '12 septembre 2026'),
      isPast: values['isPast'] == true,
    );
  }

  final String bookingReference;
  final String flightNumber;
  final String departureCity;
  final String destinationCity;
  final String departureDate;
  final bool isPast;

  Map<String, Object?> get assistantArguments {
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
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }
}

class _ChecklistItem {
  const _ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.isImportant,
  });

  final String id;
  final String title;
  final _ChecklistCategory category;
  final bool isCompleted;
  final bool isImportant;

  int get sortRank {
    if (isCompleted) return 3;
    if (isImportant) return 1;
    return 2;
  }

  _ChecklistItem copyWith({bool? isCompleted}) {
    return _ChecklistItem(
      id: id,
      title: title,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant,
    );
  }
}

List<_ChecklistItem> _initialTasks() {
  return const [
    _ChecklistItem(
      id: 'booking-confirmed',
      title: 'Réservation confirmée',
      category: _ChecklistCategory.booking,
      isCompleted: true,
      isImportant: false,
    ),
    _ChecklistItem(
      id: 'travel-documents',
      title: 'Vérifier les documents de voyage',
      category: _ChecklistCategory.documents,
      isCompleted: false,
      isImportant: true,
    ),
    _ChecklistItem(
      id: 'entry-formalities',
      title: 'Vérifier les formalités d’entrée',
      category: _ChecklistCategory.documents,
      isCompleted: false,
      isImportant: true,
    ),
    _ChecklistItem(
      id: 'prepare-baggage',
      title: 'Préparer les bagages',
      category: _ChecklistCategory.baggage,
      isCompleted: false,
      isImportant: false,
    ),
    _ChecklistItem(
      id: 'online-checkin',
      title: 'Faire l’enregistrement en ligne',
      category: _ChecklistCategory.checkIn,
      isCompleted: false,
      isImportant: true,
    ),
    _ChecklistItem(
      id: 'flight-time',
      title: 'Vérifier l’heure de départ',
      category: _ChecklistCategory.flight,
      isCompleted: false,
      isImportant: false,
    ),
  ];
}

enum _ChecklistCategory {
  booking('Réservation', Icons.confirmation_number_outlined),
  documents('Documents', Icons.assignment_turned_in_outlined),
  baggage('Bagages', Icons.luggage_outlined),
  checkIn('Enregistrement', Icons.how_to_reg_outlined),
  flight('Vol', Icons.flight_takeoff);

  const _ChecklistCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({required this.trip});

  final _ChecklistTripData trip;

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
        Text(trip.departureDate, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'Votre checklist avant départ',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistProgressCard extends StatelessWidget {
  const _ChecklistProgressCard({
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  final int completedCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return _ChecklistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression globale',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedCount sur $totalCount terminé',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$percent %',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(AppRadius.small),
            backgroundColor: AppColors.border,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.tasks});

  final List<_ChecklistItem> tasks;

  @override
  Widget build(BuildContext context) {
    return _ChecklistCard(
      title: 'À faire en priorité',
      child: tasks.isEmpty
          ? const Text('Vos priorités sont à jour.', style: AppTextStyles.body)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final task in tasks) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.priority_high_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(task.title, style: AppTextStyles.body),
                      ),
                    ],
                  ),
                  if (task != tasks.last) const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }
}

class _ChecklistTaskCard extends StatelessWidget {
  const _ChecklistTaskCard({required this.task, required this.onChanged});

  final _ChecklistItem task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = task.isCompleted
        ? AppColors.textSecondary
        : AppColors.textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: () => onChanged(!task.isCompleted),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: task.isCompleted ? const Color(0xFFF7FBF9) : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFFB7E3CA)
                : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F102033),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _CategoryBadge(category: task.category),
                      if (task.isImportant) const _ImportantBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    task.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (task.category == _ChecklistCategory.baggage) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.baggage),
                      icon: const Icon(Icons.luggage_outlined),
                      label: const Text('Voir les règles bagages'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final _ChecklistCategory category;

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 15, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            category.label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportantBadge extends StatelessWidget {
  const _ImportantBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: const Text(
        'Important',
        style: TextStyle(
          color: AppColors.warning,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CompletedStateCard extends StatelessWidget {
  const _CompletedStateCard();

  @override
  Widget build(BuildContext context) {
    return _ChecklistCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 30),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Vous êtes prêt pour votre voyage',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Votre checklist est complète.',
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

class _AssistantHelpCard extends StatelessWidget {
  const _AssistantHelpCard({required this.trip});

  final _ChecklistTripData trip;

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
            'Une question avant votre départ ?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Demandez à l’assistant ASKY Smart Travel de vous aider à préparer votre voyage.',
            style: TextStyle(color: AppColors.white, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.assistant,
              arguments: trip.assistantArguments,
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

class _PastChecklistScreen extends StatelessWidget {
  const _PastChecklistScreen({required this.trip});

  final _ChecklistTripData trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Préparer mon voyage'),
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
                  _ChecklistHeader(trip: trip),
                  const SizedBox(height: AppSpacing.md),
                  _ChecklistCard(
                    title: 'Ce voyage est terminé.',
                    child: Text(
                      '${trip.flightNumber} - ${trip.departureCity} vers ${trip.destinationCity}, ${trip.departureDate}.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AssistantHelpCard(trip: trip),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.child, this.title});

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
