import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/page_header.dart';

/// A short, honest description of a service Connectors offers, plus a way
/// to ask about it — used for services (Marketing, IT/Technology) that
/// don't have a dedicated in-app flow yet. Deliberately light on invented
/// specifics: real capabilities live on the website/with the team, not
/// fabricated here.
class ServiceInfoScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String lead;
  final String body;
  final String enquireMessage;

  const ServiceInfoScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.lead,
    required this.body,
    required this.enquireMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(icon: icon, title: title, lead: lead),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xl,
                  AppSpacing.page,
                  AppSpacing.section,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    EnquireCta(message: enquireMessage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
