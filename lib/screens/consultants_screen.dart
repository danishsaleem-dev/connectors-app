import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/reveal.dart';
import 'signup_screen.dart';

class _ConsultingAudience {
  final String audience;
  final String body;
  final IconData icon;

  const _ConsultingAudience({required this.audience, required this.body, required this.icon});
}

const _audiences = [
  _ConsultingAudience(
    audience: 'Brands',
    body: 'Market entry, site selection and franchise structuring for your next opening.',
    icon: Icons.storefront_rounded,
  ),
  _ConsultingAudience(
    audience: 'Franchisees',
    body: 'Feasibility and operational planning before you commit capital to a territory.',
    icon: Icons.handshake_rounded,
  ),
  _ConsultingAudience(
    audience: 'Landlords',
    body: "Positioning a space, and reading which brands it will actually attract.",
    icon: Icons.apartment_rounded,
  ),
];

/// Connectors' own in-house consultancy — not the Partners Program. This
/// screen is deliberately static (no live roster): browsing individual
/// consultant profiles needs a public API the website doesn't expose yet,
/// so for now the app explains the service and routes both directions —
/// hire one, or join the roster.
class ConsultantsScreen extends StatelessWidget {
  const ConsultantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultants')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advice from people who do this for a living.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Site selection, feasibility and franchise structuring — '
                "Connectors' own consultancy, available whether or not "
                "you're already working with us on an expansion.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < _audiences.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Reveal(index: i, child: _AudienceRow(item: _audiences[i])),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen(initialType: 'consultant')),
                  ),
                  child: const Text('Join the consultants roster'),
                ),
              ),
              const SizedBox(height: 12),
              const EnquireCta(message: 'Need a consultant? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudienceRow extends StatelessWidget {
  final _ConsultingAudience item;

  const _AudienceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.violet50, borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: AppColors.violet600, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.audience, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
