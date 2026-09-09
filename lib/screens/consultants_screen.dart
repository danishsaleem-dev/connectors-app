import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/consultant.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/page_header.dart';

/// Connectors' own in-house consultancy — not the Partners Program (a
/// separate system; don't fold vendor/partner data in here). Used to be a
/// static page explaining the service with no real roster behind it; now
/// the same published rows the website's own /consultants page shows, as
/// cards.
///
/// No FutureBuilder-owned Scaffold here — this is embedded (hasOwnScaffold
/// is false on its HomeAction) inside Home's own SingleChildScrollView, so
/// the grid below stays `shrinkWrap: true` / non-scrollable rather than
/// opening a second, nested scroll region.
class ConsultantsBody extends StatefulWidget {
  const ConsultantsBody({super.key});

  @override
  State<ConsultantsBody> createState() => _ConsultantsBodyState();
}

class _ConsultantsBodyState extends State<ConsultantsBody> {
  late Future<List<Consultant>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchConsultants();
  }

  void _retry() => setState(() => _future = ApiClient.fetchConsultants());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          icon: Icons.groups_rounded,
          title: 'Consultants',
          lead: 'Advice from people who do this for a living.',
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: FutureBuilder<List<Consultant>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _StatusMessage(
                  message: snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : "Couldn't load the consultants roster. Please try again.",
                  onRetry: _retry,
                );
              }
              final consultants = snapshot.data ?? const [];
              if (consultants.isEmpty) {
                return const _StatusMessage(
                  message: 'The roster is being finalised — check back soon.',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: consultants.length,
                    itemBuilder: (context, i) =>
                        _ConsultantCard(consultant: consultants[i]),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const InquireCta(
                    message: 'Need a consultant?',
                    subject: 'The consultants roster',
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConsultantCard extends StatelessWidget {
  final Consultant consultant;

  const _ConsultantCard({required this.consultant});

  // Opens the same public profile the website's own /consultants page
  // links to — the app has no consultant detail screen of its own (see
  // the user's own scoping decision on ProfileDraft.expertise: experience/
  // education stay out of the app UI for now), so the full profile only
  // ever existed on the website. externalApplication so it opens in the
  // device's browser rather than an in-app webview.
  Future<void> _open(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse('$apiBaseUrl/consultants/${consultant.slug}'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open that profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = consultant.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photoUrl != null)
                Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _PhotoFallback(),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const _PhotoFallback(loading: true),
                )
              else
                const _PhotoFallback(),
              // Scrim rather than a solid bar — the name stays legible over a
              // light or dark portrait without cropping the image behind it,
              // same treatment the website's own ConsultantCard uses.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                      if (consultant.title != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          consultant.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.78),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  final bool loading;

  const _PhotoFallback({this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey50,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.grey300,
              ),
            )
          : const Icon(
              Icons.person_outline_rounded,
              color: AppColors.grey300,
              size: 32,
            ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _StatusMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.groups_outlined, color: AppColors.grey300, size: 36),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
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
