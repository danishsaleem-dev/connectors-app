import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/message.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/page_header.dart';

/// MessagesBody with its own AppBar/back button — for reaching the thread
/// from somewhere other than the bottom-nav Messages tab (which already
/// has its own chrome-less Scaffold via AppShell), e.g. a franchisee's
/// "Contact Brand" Home tile.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const SafeArea(child: MessagesBody()),
    );
  }
}

/// The org's one real thread with the Connectors team — see /api/mobile/
/// messages's doc comment for why this is a single conversation, not a
/// list of threads: every conversation in the product has Connectors on
/// one side of it, so there's nothing to pick between. Needs a bounded-
/// height ancestor (a Scaffold body, or AppShell's own) — its Expanded
/// message list means it can't sit inside a SingleChildScrollView, so
/// wherever this is used as a Home tile it must set hasOwnScaffold: true
/// and go through MessagesScreen above, not this widget bare.
class MessagesBody extends StatefulWidget {
  const MessagesBody({super.key});

  @override
  State<MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<MessagesBody> {
  final _composeController = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _composeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await MessagesStore.refresh();
      if (!mounted) return;
      setState(() => _loading = false);
      _scrollToEnd();
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err is ApiException ? err.message : "Couldn't load messages.";
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _composeController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ApiClient.sendMessage(text);
      _composeController.clear();
      await MessagesStore.refresh();
      if (!mounted) return;
      setState(() => _sending = false);
      _scrollToEnd();
    } catch (err) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err is ApiException ? err.message : "Couldn't send. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 110 clears the floating nav bar, which overlays the body (see
    // AppShell's extendBody) — the same allowance every other tab's
    // scrollable content uses, applied here to the whole column since this
    // screen pins a composer at the bottom instead of just scrolling.
    return Padding(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        children: [
          const PageHeader(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Messages',
            lead: 'Your direct line to the Connectors team.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _body()),
          _Composer(controller: _composeController, sending: _sending, onSend: _send),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.grey300, size: 40),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<List<Message>>(
      valueListenable: MessagesStore.thread,
      builder: (context, thread, _) {
        if (thread.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Say hello — a member of the Connectors team will reply here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
            ),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          itemCount: thread.length,
          itemBuilder: (context, i) => _MessageBubble(message: thread[i]),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromConnectors = message.authorIsAdmin;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: fromConnectors ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  fromConnectors ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  fromConnectors ? 'Connectors' : message.authorName,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: fromConnectors ? AppColors.grey50 : AppColors.violet600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: fromConnectors ? AppColors.ink : AppColors.white,
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

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Write a message…',
                filled: true,
                fillColor: AppColors.grey50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
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
              onTap: sending ? null : onSend,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Icon(Icons.arrow_upward_rounded, color: AppColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
