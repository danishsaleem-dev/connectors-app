import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../theme/colors.dart';

/// What both the login and signup screens end on — there's no in-app
/// dashboard (see the mobile-app phase notes: role-based screens live on
/// the website, not duplicated here), so this hands the signed-in user off
/// to a real browser via the handoff link, opened externally rather than in
/// an in-app webview so the resulting session actually persists.
class AuthSuccessView extends StatelessWidget {
  final AuthResult result;
  final String title;

  const AuthSuccessView({super.key, required this.result, required this.title});

  Future<void> _openPortal(BuildContext context) async {
    final ok = await launchUrl(Uri.parse(result.handoffUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the browser. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text(
              'The rest — your dashboard, documents and requests — lives on '
              'the Connectors portal. Tap below to open it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openPortal(context),
                child: const Text('Continue to the portal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
