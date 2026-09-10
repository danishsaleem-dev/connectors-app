import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/chat.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'audience_screen.dart';

/// Deep-links a chat answer's link straight to the app's own matching
/// screen where one exists, rather than a website URL the app can't open.
const _audienceSlugs = {
  'for-brands',
  'for-franchise',
  'for-landlords',
  'for-investors',
};

class _ChatMessage {
  final bool isUser;
  final String text;
  final ChatLink? link;
  final bool needsHuman;

  /// Only set on an assistant message that needs a human — what to send
  /// on if the user asks to talk to the team, since the assistant's own
  /// reply text isn't the question that needs answering.
  final String? originalQuestion;
  bool escalated = false;

  _ChatMessage({
    required this.isUser,
    required this.text,
    this.link,
    this.needsHuman = false,
    this.originalQuestion,
  });
}

/// Connectors AI — the app's version of the website's ChatWidget, wrapping
/// the exact same scripted matcher over /api/mobile/chat (see that route's
/// doc comment: no language model on either surface). Push with
/// ChatScreen.route() rather than a plain MaterialPageRoute so every call
/// site gets the same slide-from-below transition without repeating the
/// animation setup.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ChatScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        // This route has no Scaffold, so nothing resizes it for the
        // keyboard the way a normal screen's body would — heightFactor is
        // computed against the *full* screen, so without this the keyboard
        // just overlaps whatever's at the bottom instead of the sheet
        // shrinking to stay above it. Matches the keyboard's own animation
        // speed rather than the framework's longer implicit-animation
        // default, so the sheet doesn't visibly lag behind it opening.
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.88,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: const _ChatBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _messages = <_ChatMessage>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatSuggestion> _suggested = const [];
  bool _loadingIntro = true;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _loadIntro();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIntro() async {
    try {
      final intro = await ApiClient.fetchChatIntro();
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(isUser: false, text: intro.greeting));
        _suggested = intro.suggested;
        _loadingIntro = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text: "Couldn't connect right now — please try again in a moment.",
          ),
        );
        _loadingIntro = false;
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _ask({String? question, ChatSuggestion? suggestion}) async {
    final text = question ?? suggestion!.question;
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _asking = true;
      _suggested = const []; // Chips are a first-impression thing only.
    });
    _scrollToEnd();

    try {
      final reply = suggestion != null
          ? await ApiClient.askChat(entryId: suggestion.id)
          : await ApiClient.askChat(question: text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text: reply.answer,
            link: reply.link,
            needsHuman: reply.needsHuman,
            originalQuestion: text,
          ),
        );
        _asking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            isUser: false,
            text: "Couldn't reach Connectors AI. Please try again.",
          ),
        );
        _asking = false;
      });
    }
    _scrollToEnd();
  }

  Future<void> _escalate(_ChatMessage message) async {
    setState(() => message.escalated = true);
    try {
      await ApiClient.sendMessage(
        "Connectors AI couldn't answer: ${message.originalQuestion}",
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent to your Connectors team.')),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => message.escalated = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err is ApiException
                ? err.message
                : "Couldn't send. Please try again.",
          ),
        ),
      );
    }
  }

  void _submitInput() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _asking) return;
    _inputController.clear();
    _ask(question: text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.violet400, AppColors.violet600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Connectors AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.grey500),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingIntro
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  itemCount:
                      _messages.length +
                      (_suggested.isNotEmpty ? 1 : 0) +
                      (_asking ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i < _messages.length) {
                      return _MessageBubble(
                        message: _messages[i],
                        onOpenLink: _openLink,
                        onEscalate: () => _escalate(_messages[i]),
                      );
                    }
                    if (_asking && i == _messages.length) {
                      return const _ThinkingBubble();
                    }
                    return _SuggestedChips(
                      suggestions: _suggested,
                      onTap: (s) => _ask(suggestion: s),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  enabled: !_asking,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitInput(),
                  decoration: InputDecoration(
                    hintText: 'Ask Connectors AI…',
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.violet600,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.violet600,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _asking ? null : _submitInput,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLink(ChatLink link) {
    final slug = link.href.replaceFirst('/', '');
    if (!_audienceSlugs.contains(slug)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: SafeArea(child: buildAudienceScreen(slug))),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final ValueChanged<ChatLink> onOpenLink;
  final VoidCallback onEscalate;

  const _MessageBubble({
    required this.message,
    required this.onOpenLink,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.violet600 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? AppColors.white : AppColors.ink,
                    ),
                  ),
                ),
                if (message.link != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => onOpenLink(message.link!),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(message.link!.label),
                  ),
                ],
                if (message.needsHuman) ...[
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: message.escalated ? null : onEscalate,
                    icon: Icon(
                      message.escalated
                          ? Icons.check_rounded
                          : Icons.forum_outlined,
                      size: 16,
                    ),
                    label: Text(
                      message.escalated
                          ? 'Sent to your team'
                          : 'Talk to our team',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.violet400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedChips extends StatelessWidget {
  final List<ChatSuggestion> suggestions;
  final ValueChanged<ChatSuggestion> onTap;

  const _SuggestedChips({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in suggestions)
            Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Text(
                    s.question,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
