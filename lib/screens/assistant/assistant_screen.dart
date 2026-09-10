import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_text_styles.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  late _AssistantContext _travelContext;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _travelContext = _AssistantContext.fromRoute(context);
    _isInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation intelligente à connecter au backend.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = _travelContext.topic;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Assistant'),
            Text(
              'Contexte : vol ${_travelContext.flightNumber} · 12 sept.',
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: _DatePill()),
                        const SizedBox(height: AppSpacing.lg),
                        _DemoConversation(contextData: _travelContext),
                        const SizedBox(height: AppSpacing.md),
                        _SuggestionGrid(topic: topic),
                        const SizedBox(height: AppSpacing.md),
                        const _AssistantNotice(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _MessageComposer(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _AssistantContext {
  const _AssistantContext({
    required this.bookingReference,
    required this.flightNumber,
    required this.departureCity,
    required this.destinationCity,
    required this.topic,
  });

  factory _AssistantContext.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final values = args is Map ? args : const <String, Object?>{};

    return _AssistantContext(
      bookingReference: _readString(values, 'bookingReference', 'ASKY7D2'),
      flightNumber: _readString(values, 'flightNumber', 'KP 020'),
      departureCity: _readString(values, 'departureCity', 'Lomé'),
      destinationCity: _readString(values, 'destinationCity', 'Accra'),
      topic: _readString(values, 'topic', 'travel'),
    );
  }

  final String bookingReference;
  final String flightNumber;
  final String departureCity;
  final String destinationCity;
  final String topic;

  static String _readString(
    Map<dynamic, dynamic> values,
    String key,
    String fallback,
  ) {
    final value = values[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    final suggestions = topic == 'baggage'
        ? const ['Mon bagage est-il suivi ?', 'Documents requis']
        : const ['Mon vol est-il à l’heure ?', 'Documents requis'];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final suggestion in suggestions)
          ActionChip(
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.border),
            label: Text(suggestion),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$suggestion à connecter au backend.')),
              );
            },
          ),
      ],
    );
  }
}

class _DemoConversation extends StatelessWidget {
  const _DemoConversation({required this.contextData});

  final _AssistantContext contextData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantLine(
          child: _MessageBubble(
            message:
                'Bonjour Diane. Il vous reste 2 tâches avant votre vol ${contextData.flightNumber} ${contextData.departureCity} → ${contextData.destinationCity}.',
            isAssistant: true,
            action: OutlinedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.tripChecklist,
                arguments: {
                  'bookingReference': contextData.bookingReference,
                  'flightNumber': contextData.flightNumber,
                  'departureCity': contextData.departureCity,
                  'destinationCity': contextData.destinationCity,
                },
              ),
              child: const Text('Ouvrir la checklist'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Align(
          alignment: Alignment.centerRight,
          child: _MessageBubble(
            message: 'Que dois-je vérifier avant le départ ?',
            isAssistant: false,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _AssistantLine(
          child: _MessageBubble(
            message:
                'Sur votre tarif Economy : 1 bagage cabine et 1 bagage en soute. Vérifiez aussi vos documents de voyage.',
            isAssistant: true,
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isAssistant,
    this.action,
  });

  final String message;
  final bool isAssistant;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isAssistant ? AppColors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: isAssistant ? Border.all(color: AppColors.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isAssistant ? AppColors.textPrimary : AppColors.white,
                fontSize: 16,
                height: 1.45,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantLine extends StatelessWidget {
  const _AssistantLine({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.auto_awesome, color: AppColors.white, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Aujourd’hui · 09:12',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _AssistantNotice extends StatelessWidget {
  const _AssistantNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF356CB8)),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'L’assistant répond uniquement à partir de vos données et de la base de connaissances.',
              style: TextStyle(color: Color(0xFF356CB8), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('assistant-message-field'),
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Poser une question à l’assistant...',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                key: const Key('assistant-send-button'),
                tooltip: 'Envoyer',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                  fixedSize: const Size(48, 48),
                ),
                onPressed: onSend,
                icon: const Icon(Icons.send_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
