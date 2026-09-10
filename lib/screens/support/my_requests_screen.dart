import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({this.showDemoRequests = true, super.key});

  final bool showDemoRequests;

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late final List<_SupportRequest> _requests;
  _RequestFilter _filter = _RequestFilter.all;
  String? _selectedRequestId;

  @override
  void initState() {
    super.initState();
    _requests = widget.showDemoRequests ? _demoRequests() : [];
  }

  _SupportRequest? get _selectedRequest {
    for (final request in _requests) {
      if (request.id == _selectedRequestId) return request;
    }
    return null;
  }

  List<_SupportRequest> get _filteredRequests {
    return _requests.where((request) {
      return switch (_filter) {
        _RequestFilter.all => true,
        _RequestFilter.open => request.isOpen,
        _RequestFilter.resolved => request.isClosed,
      };
    }).toList();
  }

  void _addMessage(_SupportRequest request, String message) {
    if (!request.isOpen) return;

    // TODO backend: POST /api/support/requests/{id}/messages.
    // TODO backend: verify access to the ticket before adding a message.
    setState(() {
      request.messages.add(
        _SupportMessage(
          sender: 'Passager',
          message: message,
          date: 'Maintenant',
          isAgent: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedRequest = _selectedRequest;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (selectedRequest != null) {
              setState(() => _selectedRequestId = null);
              return;
            }
            Navigator.maybePop(context);
          },
        ),
        title: const Text('Mes demandes'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: selectedRequest == null
                  ? _RequestsListView(
                      requests: _filteredRequests,
                      filter: _filter,
                      onFilterChanged: (filter) {
                        setState(() => _filter = filter);
                      },
                      onRequestSelected: (request) {
                        setState(() => _selectedRequestId = request.id);
                      },
                    )
                  : _RequestDetailsView(
                      request: selectedRequest,
                      onMessageSent: (message) {
                        _addMessage(selectedRequest, message);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestsListView extends StatelessWidget {
  const _RequestsListView({
    required this.requests,
    required this.filter,
    required this.onFilterChanged,
    required this.onRequestSelected,
  });

  final List<_SupportRequest> requests;
  final _RequestFilter filter;
  final ValueChanged<_RequestFilter> onFilterChanged;
  final ValueChanged<_SupportRequest> onRequestSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RequestsHeader(),
        const SizedBox(height: AppSpacing.md),
        _RequestFilters(selected: filter, onChanged: onFilterChanged),
        const SizedBox(height: AppSpacing.md),
        if (requests.isEmpty)
          const _EmptyRequestsState()
        else
          for (final request in requests) ...[
            _SupportRequestCard(
              request: request,
              onTap: () => onRequestSelected(request),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _RequestsHeader extends StatelessWidget {
  const _RequestsHeader();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes demandes', style: AppTextStyles.screenTitle),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Suivez l’avancement de vos demandes d’assistance.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('my-requests-new-button'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.support),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Nouvelle demande',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestFilters extends StatelessWidget {
  const _RequestFilters({required this.selected, required this.onChanged});

  final _RequestFilter selected;
  final ValueChanged<_RequestFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _FilterChipButton(
          label: 'Toutes',
          selected: selected == _RequestFilter.all,
          onTap: () => onChanged(_RequestFilter.all),
        ),
        _FilterChipButton(
          label: 'Ouvertes',
          selected: selected == _RequestFilter.open,
          onTap: () => onChanged(_RequestFilter.open),
        ),
        _FilterChipButton(
          label: 'Résolues',
          selected: selected == _RequestFilter.resolved,
          onTap: () => onChanged(_RequestFilter.resolved),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: AppColors.white,
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _SupportRequestCard extends StatelessWidget {
  const _SupportRequestCard({required this.request, required this.onTap});

  final _SupportRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.large),
      onTap: onTap,
      child: _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.reference,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _RequestStatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.category,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              request.subject,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (request.hasTrip) ...[
              const SizedBox(height: AppSpacing.sm),
              _IconText(
                icon: Icons.flight_takeoff,
                text:
                    '${request.flightNumber} · ${request.departureCity} → ${request.destinationCity}',
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _IconText(icon: Icons.schedule, text: request.updatedAt),
          ],
        ),
      ),
    );
  }
}

class _RequestDetailsView extends StatelessWidget {
  const _RequestDetailsView({
    required this.request,
    required this.onMessageSent,
  });

  final _SupportRequest request;
  final ValueChanged<String> onMessageSent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestDetailsHeader(request: request),
        const SizedBox(height: AppSpacing.md),
        _RequestInfoCard(request: request),
        const SizedBox(height: AppSpacing.md),
        _RequestTimeline(status: request.status),
        const SizedBox(height: AppSpacing.md),
        _SupportConversation(request: request, onMessageSent: onMessageSent),
        const SizedBox(height: AppSpacing.md),
        _RequestActions(request: request),
      ],
    );
  }
}

class _RequestDetailsHeader extends StatelessWidget {
  const _RequestDetailsHeader({required this.request});

  final _SupportRequest request;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.reference,
                  style: AppTextStyles.screenTitle,
                ),
              ),
              _RequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(request.subject, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({required this.request});

  final _SupportRequest request;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Détail de la demande',
      child: Column(
        children: [
          _DetailRow(label: 'Catégorie', value: request.category),
          _DetailRow(label: 'Créée', value: request.createdAt),
          _DetailRow(label: 'Mise à jour', value: request.updatedAt),
          _DetailRow(label: 'Sujet', value: request.subject),
          _DetailRow(label: 'Description', value: request.description),
          if (request.hasTrip)
            _DetailRow(
              label: 'Voyage',
              value:
                  '${request.bookingReference} · ${request.flightNumber} · ${request.departureCity} → ${request.destinationCity}',
            ),
          if (request.baggageTag != null)
            _DetailRow(label: 'Bagage', value: request.baggageTag!),
        ],
      ),
    );
  }
}

class _RequestTimeline extends StatelessWidget {
  const _RequestTimeline({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = _timelineSteps(status);

    return _SectionCard(
      title: 'Timeline',
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            _RequestTimelineStep(step: steps[index]),
            if (index < steps.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 11),
                child: SizedBox(
                  height: 18,
                  child: VerticalDivider(color: AppColors.border, width: 1),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RequestTimelineStep extends StatelessWidget {
  const _RequestTimelineStep({required this.step});

  final _TimelineStep step;

  @override
  Widget build(BuildContext context) {
    final icon = switch (step.state) {
      _TimelineState.done => Icons.check_circle,
      _TimelineState.current => Icons.radio_button_checked,
      _TimelineState.pending => Icons.radio_button_unchecked,
    };
    final color = switch (step.state) {
      _TimelineState.done => AppColors.secondary,
      _TimelineState.current => AppColors.accent,
      _TimelineState.pending => AppColors.textSecondary,
    };

    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            step.label,
            style: TextStyle(
              color: step.state == _TimelineState.pending
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontWeight: step.state == _TimelineState.current
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportConversation extends StatelessWidget {
  const _SupportConversation({
    required this.request,
    required this.onMessageSent,
  });

  final _SupportRequest request;
  final ValueChanged<String> onMessageSent;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Échanges',
      child: Column(
        children: [
          for (final message in request.messages) ...[
            _SupportMessageBubble(message: message),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (request.isOpen)
            _SupportReplyComposer(onMessageSent: onMessageSent)
          else
            const _ClosedRequestNotice(),
        ],
      ),
    );
  }
}

class _SupportMessageBubble extends StatelessWidget {
  const _SupportMessageBubble({required this.message});

  final _SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isAgent
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final bubbleColor = message.isAgent ? AppColors.surface : AppColors.primary;
    final textColor = message.isAgent ? AppColors.textPrimary : AppColors.white;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          message.isAgent ? 'Agent ASKY' : message.sender,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: message.isAgent
                ? Border.all(color: AppColors.border)
                : null,
          ),
          child: Text(message.message, style: TextStyle(color: textColor)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message.date,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _SupportReplyComposer extends StatefulWidget {
  const _SupportReplyComposer({required this.onMessageSent});

  final ValueChanged<String> onMessageSent;

  @override
  State<_SupportReplyComposer> createState() => _SupportReplyComposerState();
}

class _SupportReplyComposerState extends State<_SupportReplyComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    FocusScope.of(context).unfocus();
    widget.onMessageSent(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('support-reply-field'),
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ajouter un message...',
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        FilledButton(
          key: const Key('support-reply-send-button'),
          onPressed: _send,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          child: const Text(
            'Envoyer',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ClosedRequestNotice extends StatelessWidget {
  const _ClosedRequestNotice();

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
      child: const Text(
        'Cette demande est clôturée.',
        style: AppTextStyles.body,
      ),
    );
  }
}

class _RequestActions extends StatelessWidget {
  const _RequestActions({required this.request});

  final _SupportRequest request;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Actions',
      child: Column(
        children: [
          if (request.category == 'Bagages') ...[
            _FullWidthActionButton(
              key: const Key('request-baggage-button'),
              label: 'Voir mes bagages',
              icon: Icons.luggage_outlined,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.baggage,
                arguments: request.toRouteArguments(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (request.hasTrip) ...[
            _FullWidthActionButton(
              key: const Key('request-trip-button'),
              label: 'Voir mon voyage',
              icon: Icons.flight_takeoff,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.tripDetails,
                arguments: request.toRouteArguments(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (request.isOpen)
            _FullWidthActionButton(
              key: const Key('request-assistant-button'),
              label: 'Contacter l’assistant',
              icon: Icons.smart_toy_outlined,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.assistant,
                arguments: request.toRouteArguments(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.support_agent, color: AppColors.primary, size: 36),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Aucune demande',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Vous n’avez encore créé aucune demande d’assistance.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.support),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Créer une demande',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestStatusBadge extends StatelessWidget {
  const _RequestStatusBadge({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _RequestStatusColors.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RequestStatusColors {
  const _RequestStatusColors(this.background, this.foreground);

  factory _RequestStatusColors.fromStatus(_RequestStatus status) {
    return switch (status) {
      _RequestStatus.newRequest => const _RequestStatusColors(
        Color(0xFFEAF3FF),
        Color(0xFF0957A5),
      ),
      _RequestStatus.inProgress => const _RequestStatusColors(
        Color(0xFFFFF8E0),
        Color(0xFF8A6400),
      ),
      _RequestStatus.waiting => const _RequestStatusColors(
        Color(0xFFF0F2F5),
        Color(0xFF475467),
      ),
      _RequestStatus.resolved => const _RequestStatusColors(
        Color(0xFFE7F7EF),
        Color(0xFF177245),
      ),
      _RequestStatus.closed => const _RequestStatusColors(
        Color(0xFFECEFF3),
        Color(0xFF344054),
      ),
    };
  }

  final Color background;
  final Color foreground;
}

class _FullWidthActionButton extends StatelessWidget {
  const _FullWidthActionButton({
    required super.key,
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
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 112, child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.md),
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

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title});

  final Widget child;
  final String? title;

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

class _SupportRequest {
  const _SupportRequest({
    required this.id,
    required this.reference,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bookingReference,
    this.flightNumber,
    this.departureCity,
    this.destinationCity,
    this.baggageTag,
    required this.messages,
  });

  final String id;
  final String reference;
  final String category;
  final String subject;
  final String description;
  final _RequestStatus status;
  final String createdAt;
  final String updatedAt;
  final String? bookingReference;
  final String? flightNumber;
  final String? departureCity;
  final String? destinationCity;
  final String? baggageTag;
  final List<_SupportMessage> messages;

  bool get isOpen =>
      status == _RequestStatus.newRequest ||
      status == _RequestStatus.inProgress ||
      status == _RequestStatus.waiting;

  bool get isClosed =>
      status == _RequestStatus.resolved || status == _RequestStatus.closed;

  bool get hasTrip =>
      bookingReference != null &&
      flightNumber != null &&
      departureCity != null &&
      destinationCity != null;

  Map<String, Object?> toRouteArguments() {
    return {
      'bookingReference': bookingReference,
      'flightNumber': flightNumber,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'baggageTag': baggageTag,
    };
  }
}

class _SupportMessage {
  const _SupportMessage({
    required this.sender,
    required this.message,
    required this.date,
    required this.isAgent,
  });

  final String sender;
  final String message;
  final String date;
  final bool isAgent;
}

enum _RequestStatus {
  newRequest('Nouveau'),
  inProgress('En traitement'),
  waiting('En attente'),
  resolved('Résolu'),
  closed('Fermé');

  const _RequestStatus(this.label);

  final String label;
}

enum _RequestFilter { all, open, resolved }

enum _TimelineState { done, current, pending }

class _TimelineStep {
  const _TimelineStep(this.label, this.state);

  final String label;
  final _TimelineState state;
}

List<_TimelineStep> _timelineSteps(_RequestStatus status) {
  final hasResolution =
      status == _RequestStatus.resolved || status == _RequestStatus.closed;
  return [
    const _TimelineStep('Demande envoyée', _TimelineState.done),
    const _TimelineStep('Demande reçue', _TimelineState.done),
    _TimelineStep(
      'En cours de traitement',
      hasResolution ? _TimelineState.done : _TimelineState.current,
    ),
    _TimelineStep(
      'Résolution',
      hasResolution ? _TimelineState.current : _TimelineState.pending,
    ),
  ];
}

List<_SupportRequest> _demoRequests() {
  // TODO backend: GET /api/support/requests.
  // TODO backend: GET /api/support/requests/{id}.
  // TODO backend: fetch only requests for the JWT-authenticated passenger.
  // TODO backend: never accept an arbitrary passengerId.
  // TODO backend: audit support request status changes.
  // TODO backend: notify passengers when agents answer.
  // TODO backend: paginate support requests.
  // TODO backend: secure attachments.
  // TODO backend: use backend-provided dates.
  return [
    _SupportRequest(
      id: '1',
      reference: 'ASKY-2048',
      category: 'Bagages',
      subject: 'Mon bagage n’est pas arrivé',
      description:
          'Mon bagage enregistré à Lomé n’était pas disponible à mon arrivée à Accra.',
      status: _RequestStatus.inProgress,
      createdAt: '10 sept. 2026 · 09:45',
      updatedAt: 'Aujourd’hui · 10:30',
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      departureCity: 'Lomé',
      destinationCity: 'Accra',
      baggageTag: 'BG-ASKY-20481',
      messages: [
        const _SupportMessage(
          sender: 'Passager',
          message: 'Bonjour, mon bagage n’était pas disponible à l’arrivée.',
          date: '10 sept. · 09:45',
          isAgent: false,
        ),
        const _SupportMessage(
          sender: 'Agent ASKY',
          message:
              'Bonjour Diane. Votre demande a bien été reçue. Nous vérifions actuellement le statut du bagage BG-ASKY-20481.',
          date: '10 sept. · 10:30',
          isAgent: true,
        ),
      ],
    ),
    _SupportRequest(
      id: '2',
      reference: 'ASKY-2031',
      category: 'Réservation',
      subject: 'Question concernant ma réservation',
      description:
          'Je souhaite confirmer les informations de ma réservation avant le départ.',
      status: _RequestStatus.newRequest,
      createdAt: '9 sept. 2026 · 14:20',
      updatedAt: '9 sept. 2026 · 14:20',
      bookingReference: 'ASKY9K4',
      flightNumber: 'KP 034',
      departureCity: 'Lomé',
      destinationCity: 'Abidjan',
      messages: const [],
    ),
    _SupportRequest(
      id: '3',
      reference: 'ASKY-1987',
      category: 'Documents de voyage',
      subject: 'Formalités pour mon voyage',
      description:
          'Je voulais vérifier les documents nécessaires pour mon voyage.',
      status: _RequestStatus.resolved,
      createdAt: '2 sept. 2026',
      updatedAt: '3 sept. 2026',
      bookingReference: 'ASKY7D2',
      flightNumber: 'KP 020',
      departureCity: 'Lomé',
      destinationCity: 'Accra',
      messages: const [
        _SupportMessage(
          sender: 'Agent ASKY',
          message:
              'Les informations utiles ont été transmises par le service Assistance.',
          date: '3 sept. · 11:00',
          isAgent: true,
        ),
      ],
    ),
    _SupportRequest(
      id: '4',
      reference: 'ASKY-1942',
      category: 'Paiement',
      subject: 'Confirmation de paiement',
      description:
          'Je souhaitais confirmer la bonne prise en compte de mon paiement.',
      status: _RequestStatus.closed,
      createdAt: '25 août 2026',
      updatedAt: '26 août 2026',
      messages: const [
        _SupportMessage(
          sender: 'Agent ASKY',
          message: 'Votre paiement a bien été confirmé.',
          date: '26 août · 09:10',
          isAgent: true,
        ),
      ],
    ),
  ];
}
