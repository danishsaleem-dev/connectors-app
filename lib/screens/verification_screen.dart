import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/reveal.dart';

/// The KYC / business-verification flow the business-logic doc calls for.
///
/// UI only: there is no verification backend, no document storage, and no
/// review process behind any of this. The statuses below are illustrative
/// of the states the screen has to handle (verified / in review / not
/// started), not this account's real standing — which is why the header
/// says so plainly rather than presenting an invented "you are verified".
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            const Reveal(index: 0, child: _ProgressCard()),
            const SizedBox(height: AppSpacing.xl),
            Text('Documents', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _documents.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              Reveal(index: i + 1, child: _DocumentCard(doc: _documents[i])),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Verified businesses are prioritised when we match brands to '
              'locations and partners.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DocStatus { verified, inReview, required_ }

class _Doc {
  final IconData icon;
  final String title;
  final String body;
  final _DocStatus status;

  const _Doc({
    required this.icon,
    required this.title,
    required this.body,
    required this.status,
  });
}

const _documents = [
  _Doc(
    icon: Icons.badge_outlined,
    title: 'Business registration',
    body: 'Certificate of incorporation or trade licence.',
    status: _DocStatus.verified,
  ),
  _Doc(
    icon: Icons.receipt_long_outlined,
    title: 'Tax registration',
    body: 'VAT / NTN certificate.',
    status: _DocStatus.inReview,
  ),
  _Doc(
    icon: Icons.person_outline_rounded,
    title: 'Proof of identity',
    body: "Passport or national ID for the account's signatory.",
    status: _DocStatus.required_,
  ),
  _Doc(
    icon: Icons.account_balance_outlined,
    title: 'Proof of address',
    body: 'A recent utility bill or bank statement.',
    status: _DocStatus.required_,
  ),
];

({Color fg, Color bg, String label}) _statusStyle(_DocStatus status) {
  switch (status) {
    case _DocStatus.verified:
      return (fg: const Color(0xFF1B7F4E), bg: const Color(0xFFE6F4EC), label: 'Verified');
    case _DocStatus.inReview:
      return (fg: const Color(0xFF8A6100), bg: const Color(0xFFFDF1DA), label: 'In review');
    case _DocStatus.required_:
      return (fg: AppColors.grey500, bg: AppColors.grey100, label: 'Required');
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    const done = 1;
    final total = _documents.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet700, AppColors.violet600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Account verification',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 6,
              backgroundColor: AppColors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$done of $total documents complete',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.white.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: 4),
          Text(
            'Example statuses — verification is not live yet.',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final _Doc doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(doc.status);
    final actionable = doc.status == _DocStatus.required_;

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(16),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
            child: Icon(doc.icon, color: AppColors.violet600, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(doc.title, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        style.label,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: style.fg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  doc.body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500),
                ),
                if (actionable) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.upload_file_rounded, size: 16, color: AppColors.violet600),
                      const SizedBox(width: 6),
                      Text(
                        'Upload document',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.violet600),
                      ),
                    ],
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
