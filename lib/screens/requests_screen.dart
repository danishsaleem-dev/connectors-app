import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/consultant_request.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// The consultant role's Opportunities tab content — see main.dart's
/// isConsultant branch (the tab is relabeled "Requests") and
/// opportunities_screen.dart (the tab body swaps to this entirely, same
/// pattern as landlord/developer's InterestedBody).
///
/// Unlike InterestedBody, this one *does* show the other party's contact
/// details — see ConsultantRequest's doc comment for why that's correct
/// here and not elsewhere: whoever submitted this filled in a form
/// addressed specifically to this consultant, wanting to be emailed back.
class RequestsBody extends StatefulWidget {
  const RequestsBody({super.key});

  @override
  State<RequestsBody> createState() => _RequestsBodyState();
}

class _RequestsBodyState extends State<RequestsBody> {
  late Future<List<ConsultantRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchConsultantRequests();
  }

  void _retry() => setState(() => _future = ApiClient.fetchConsultantRequests());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            icon: Icons.inbox_rounded,
            title: 'Requests',
            lead: "Leads from the public consultants page, once our team's reviewed them.",
          ),
          const SizedBox(height: AppSpacing.xl),
          FutureBuilder<List<ConsultantRequest>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _StatusMessage(
                  message: snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : "Couldn't load this. Please try again.",
                  onRetry: _retry,
                );
              }
              final requests = snapshot.data ?? const [];
              if (requests.isEmpty) {
                return const _StatusMessage(
                  icon: Icons.inbox_outlined,
                  message:
                      "Once someone reaches out through your profile on the public "
                      "consultants page and our team's reviewed it, it'll show up here.",
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < requests.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    Reveal(index: i, child: _RequestCard(request: requests[i])),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ConsultantRequest request;

  const _RequestCard({required this.request});

  Future<void> _reply(BuildContext context) async {
    final ok = await launchUrl(
      Uri(scheme: 'mailto', path: request.email, query: 'subject=${Uri.encodeComponent('Re: your enquiry to Connectors')}'),
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open your email app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                _formatDate(request.createdAt),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            request.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 10),
          Text(request.message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _reply(context),
              icon: const Icon(Icons.mail_outline_rounded, size: 16),
              label: const Text('Reply by email'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _StatusMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const _StatusMessage({
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.grey300, size: 36),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}
