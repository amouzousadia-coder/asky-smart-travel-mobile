import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
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
        title: const Text('Assistant intelligent'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AssistantHeader(),
                  const SizedBox(height: AppSpacing.md),
                  _ContextCard(contextData: _travelContext),
                  const SizedBox(height: AppSpacing.md),
                  _SuggestionGrid(topic: topic),
                  const SizedBox(height: AppSpacing.md),
                  _DemoConversation(contextData: _travelContext),
                  const SizedBox(height: AppSpacing.md),
                  _MessageComposer(
                    controller: _controller,
                    onSend: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
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

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant ASKY Smart Travel',
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Aide automatisée pour préparer le voyage, retrouver les informations utiles et clarifier les prochaines étapes.',
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

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.contextData});

  final _AssistantContext contextData;

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      title: 'Contexte du voyage',
      child: Column(
        children: [
          _InfoRow(label: 'Référence', value: contextData.bookingReference),
          _InfoRow(label: 'Vol', value: contextData.flightNumber),
          _InfoRow(
            label: 'Trajet',
            value:
                '${contextData.departureCity} → ${contextData.destinationCity}',
          ),
        ],
      ),
    );
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    final suggestions = topic == 'baggage'
        ? const [
            'Règles bagages',
            'Suivi bagage',
            'Franchise',
            'Assistance bagage',
          ]
        : const ['Checklist', 'Heure de départ', 'Documents', 'Bagages'];

    return _AssistantCard(
      title: 'Questions rapides',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final suggestion in suggestions)
            ActionChip(
              avatar: const Icon(Icons.help_outline, size: 18),
              label: Text(suggestion),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$suggestion à connecter au backend.'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DemoConversation extends StatelessWidget {
  const _DemoConversation({required this.contextData});

  final _AssistantContext contextData;

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      title: 'Conversation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBubble(
            sender: 'Assistant',
            message:
                'Bonjour Diane. Je peux vous aider pour le vol ${contextData.flightNumber} ${contextData.departureCity} → ${contextData.destinationCity}.',
            isAssistant: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _MessageBubble(
            sender: 'Diane',
            message: 'Que dois-je vérifier avant le départ ?',
            isAssistant: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _MessageBubble(
            sender: 'Assistant',
            message:
                'Vérifiez vos documents, préparez vos bagages et suivez votre checklist de voyage.',
            isAssistant: true,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.sender,
    required this.message,
    required this.isAssistant,
  });

  final String sender;
  final String message;
  final bool isAssistant;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: isAssistant
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              sender,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isAssistant ? AppColors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: isAssistant
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isAssistant ? AppColors.textPrimary : AppColors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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
    return _AssistantCard(
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
            onPressed: onSend,
            icon: const Icon(Icons.send_outlined),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.child, this.title});

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
