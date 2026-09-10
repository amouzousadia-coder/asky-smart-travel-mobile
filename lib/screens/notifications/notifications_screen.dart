import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({this.showDemoNotifications = true, super.key});

  final bool showDemoNotifications;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_TravelNotification> _notifications;
  _NotificationFilter _selectedFilter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _notifications = widget.showDemoNotifications ? _demoNotifications() : [];
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  List<_TravelNotification> get _filteredNotifications {
    return _notifications.where(_selectedFilter.matches).toList();
  }

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
        title: const Text('Notifications'),
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
                  _NotificationsHeader(
                    unreadCount: _unreadCount,
                    onMarkAllRead: _unreadCount > 0 ? _markAllAsRead : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _NotificationFilters(
                    selectedFilter: _selectedFilter,
                    onChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_filteredNotifications.isEmpty)
                    _EmptyNotificationsState(
                      filter: _selectedFilter,
                      hasNotifications: _notifications.isNotEmpty,
                    )
                  else
                    for (final notification in _filteredNotifications) ...[
                      _NotificationCard(
                        notification: notification,
                        onTap: () => _markAsRead(notification.id),
                        onDelete: () => _deleteNotification(notification.id),
                        onAction: () => _handleAction(notification),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      _notifications = [
        for (final notification in _notifications)
          if (notification.id == id)
            notification.copyWith(isRead: true)
          else
            notification,
      ];
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = [
        for (final notification in _notifications)
          notification.copyWith(isRead: true),
      ];
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications = [
        for (final notification in _notifications)
          if (notification.id != id) notification,
      ];
    });
  }

  void _handleAction(_TravelNotification notification) {
    _markAsRead(notification.id);

    if (notification.type == _NotificationType.checkin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement en ligne à venir.')),
      );
      return;
    }

    final routeName = notification.actionRoute;
    if (routeName == null) return;

    Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        'bookingReference': notification.bookingReference,
        'flightNumber': notification.flightNumber,
      },
    );
  }
}

class _TravelNotification {
  const _TravelNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAtLabel,
    required this.isRead,
    required this.bookingReference,
    required this.flightNumber,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String message;
  final _NotificationType type;
  final String createdAtLabel;
  final bool isRead;
  final String bookingReference;
  final String flightNumber;
  final String? actionRoute;

  _TravelNotification copyWith({bool? isRead}) {
    return _TravelNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAtLabel: createdAtLabel,
      isRead: isRead ?? this.isRead,
      bookingReference: bookingReference,
      flightNumber: flightNumber,
      actionRoute: actionRoute,
    );
  }
}

enum _NotificationType {
  flight(Icons.flight_takeoff, 'Voir le vol'),
  checkin(Icons.how_to_reg_outlined, 'Enregistrement'),
  baggage(Icons.luggage_outlined, 'Voir mes bagages'),
  document(Icons.assignment_turned_in_outlined, 'Voir ma checklist'),
  booking(Icons.confirmation_number_outlined, 'Voir mon voyage'),
  assistance(Icons.smart_toy_outlined, 'Demander à l’assistant'),
  general(Icons.notifications_none, null);

  const _NotificationType(this.icon, this.actionLabel);

  final IconData icon;
  final String? actionLabel;

  bool get isTravel {
    return switch (this) {
      _NotificationType.flight ||
      _NotificationType.checkin ||
      _NotificationType.baggage ||
      _NotificationType.document ||
      _NotificationType.booking => true,
      _NotificationType.assistance || _NotificationType.general => false,
    };
  }
}

enum _NotificationFilter {
  all('Toutes'),
  flight('Vol'),
  preparation('Préparation'),
  assistance('Assistance');

  const _NotificationFilter(this.label);

  final String label;

  bool matches(_TravelNotification notification) {
    return switch (this) {
      _NotificationFilter.all => true,
      _NotificationFilter.flight =>
        notification.type == _NotificationType.flight ||
            notification.type == _NotificationType.booking,
      _NotificationFilter.preparation =>
        notification.type == _NotificationType.checkin ||
            notification.type == _NotificationType.baggage ||
            notification.type == _NotificationType.document,
      _NotificationFilter.assistance =>
        notification.type == _NotificationType.assistance,
    };
  }
}

List<_TravelNotification> _demoNotifications() {
  return const [
    _TravelNotification(
      id: 'flight-on-time',
      title: 'Votre vol est à l’heure',
      message: 'Le vol KP 020 Lomé → Accra est prévu à 08:30.',
      type: _NotificationType.flight,
      createdAtLabel: 'Aujourd’hui, 07:15',
      isRead: false,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      actionRoute: AppRoutes.flightStatus,
    ),
    _TravelNotification(
      id: 'checkin-soon',
      title: 'Enregistrement bientôt disponible',
      message: 'L’enregistrement en ligne pour KP 020 ouvrira prochainement.',
      type: _NotificationType.checkin,
      createdAtLabel: 'Aujourd’hui, 06:30',
      isRead: false,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
    ),
    _TravelNotification(
      id: 'documents',
      title: 'Vérifiez vos documents',
      message:
          'Pensez à vérifier vos documents de voyage avant votre départ pour Accra.',
      type: _NotificationType.document,
      createdAtLabel: 'Hier, 18:20',
      isRead: true,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      actionRoute: AppRoutes.tripChecklist,
    ),
    _TravelNotification(
      id: 'baggage',
      title: 'Préparez vos bagages',
      message:
          'Votre tarif de démonstration inclut 1 bagage cabine et 1 bagage en soute.',
      type: _NotificationType.baggage,
      createdAtLabel: 'Hier, 10:00',
      isRead: true,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      actionRoute: AppRoutes.baggage,
    ),
    _TravelNotification(
      id: 'booking',
      title: 'Réservation confirmée',
      message: 'Votre réservation ASKY7D2 est confirmée.',
      type: _NotificationType.booking,
      createdAtLabel: '5 sept. 2026',
      isRead: true,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      actionRoute: AppRoutes.tripDetails,
    ),
    _TravelNotification(
      id: 'assistance',
      title: 'Besoin d’aide ?',
      message:
          'L’assistant ASKY Smart Travel peut vous aider à préparer votre voyage.',
      type: _NotificationType.assistance,
      createdAtLabel: '4 sept. 2026',
      isRead: true,
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      actionRoute: AppRoutes.assistant,
    ),
  ];
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final unreadLabel = unreadCount == 1
        ? '1 non lue'
        : '$unreadCount non lues';

    return _NotificationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restez informé de tout ce qui concerne vos voyages.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _UnreadBadge(label: unreadLabel),
              if (onMarkAllRead != null)
                TextButton.icon(
                  onPressed: onMarkAllRead,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Tout lire'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationFilters extends StatelessWidget {
  const _NotificationFilters({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _NotificationFilter selectedFilter;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _NotificationFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: selectedFilter == filter,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selectedFilter == filter
                    ? AppColors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) => onChanged(filter),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onAction,
  });

  final _TravelNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : AppColors.warningSurface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: notification.isRead ? AppColors.border : AppColors.secondary,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F102033),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationTypeIcon(type: notification.type),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w800
                                    : FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!notification.isRead) const _UnreadDot(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(notification.message, style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.createdAtLabel,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Options',
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ],
            ),
            if (notification.type.actionLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Text(
                    notification.type.actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationTypeIcon extends StatelessWidget {
  const _NotificationTypeIcon({required this.type});

  final _NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Icon(type.icon, color: AppColors.primary),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(left: AppSpacing.sm, top: 5),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState({
    required this.filter,
    required this.hasNotifications,
  });

  final _NotificationFilter filter;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    final title = hasNotifications
        ? 'Rien à afficher ici.'
        : 'Aucune notification';
    final message = hasNotifications
        ? 'Aucune notification ne correspond à ce filtre.'
        : 'Vos alertes de voyage apparaîtront ici.';

    return _NotificationsCard(
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            color: AppColors.secondary,
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.child});

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
