import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// A single-line prompt that opens a real enquiry, not a mailto link — no
/// party in the portal contacts another directly, everything goes through
/// Connectors, and this is that path for whatever screen it sits on
/// (a location, a brand, a service, the consultants roster, the Partners
/// Program). Submitting posts straight into the org's own real Messages
/// thread with Connectors (see ApiClient.sendMessage) — the same
/// admin-mediated channel as everything else, so there's nowhere new to
/// build or maintain for this.
class InquireCta extends StatelessWidget {
  /// The on-screen prompt, e.g. "Interested in this listing?".
  final String message;

  /// What Connectors sees as the enquiry's subject, e.g. a location's
  /// title or a brand's name — kept separate from [message] since the
  /// on-screen prompt is written for the viewer, not for the admin
  /// reading the thread afterwards.
  final String subject;

  const InquireCta({super.key, required this.message, required this.subject});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow(),
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => showInquireSheet(context, subject: subject),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.white, size: 16),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.violet50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Inquire',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the slide-up "Inquire" sheet directly — for a caller that isn't
/// the standard [InquireCta] card (e.g. an app bar action).
Future<void> showInquireSheet(BuildContext context, {required String subject}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _InquireSheet(subject: subject),
  );
}

class _InquireSheet extends StatefulWidget {
  final String subject;

  const _InquireSheet({required this.subject});

  @override
  State<_InquireSheet> createState() => _InquireSheetState();
}

class _InquireSheetState extends State<_InquireSheet> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Write a message first.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ApiClient.sendMessage('Enquiry — ${widget.subject}: $text');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent — our team will be in touch.')),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = err is ApiException ? err.message : "Couldn't send. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Rides above the keyboard rather than being covered by it.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              14,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Inquire', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 4),
                Text(
                  widget.subject,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'What would you like to know?',
                    filled: true,
                    fillColor: AppColors.grey50,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.violet600, width: 1.5),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Send enquiry'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Goes straight to your Connectors team messages.',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppColors.grey300),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
