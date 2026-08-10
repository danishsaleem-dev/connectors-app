import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../data/enquiry_forms.dart';
import '../data/form_fields.dart';
import '../data/site_data.dart';
import '../widgets/division_carousel.dart';
import '../widgets/enquiry_wizard.dart';
import '../widgets/eyebrow.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// One screen shape shared by Brands, Franchisees, Landlords and Investors —
/// each just supplies its slug, matching how the website drives all four
/// audience pages from the same `audiences` array plus a per-page divisions
/// filter and enquiry form, rather than four near-duplicate page files.
class AudienceScreen extends StatelessWidget {
  final String slug;
  final String formSource;
  final String formHeading;
  final List<FormStep> formSteps;
  final String submitLabel;
  final String successTitle;
  final String successBody;

  const AudienceScreen({
    super.key,
    required this.slug,
    required this.formSource,
    required this.formHeading,
    required this.formSteps,
    required this.submitLabel,
    required this.successTitle,
    required this.successBody,
  });

  @override
  Widget build(BuildContext context) {
    final audience = SiteData.audienceBySlug(slug);
    final divisions = DivisionData.forAudience(slug);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(icon: audience.icon, title: audience.title, lead: audience.lead),
          const SizedBox(height: 24),
          DivisionCarousel(divisions: divisions),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reveal(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Get started'),
                      const SizedBox(height: 8),
                      Text(formHeading, style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                EnquiryWizard(
                  source: formSource,
                  steps: formSteps,
                  submitLabel: submitLabel,
                  successTitle: successTitle,
                  successBody: successBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper so each screen file stays a one-liner.
Widget buildAudienceScreen(String slug) {
  switch (slug) {
    case 'for-brands':
      return AudienceScreen(
        slug: slug,
        formSource: 'brand',
        formHeading: "What are you looking to open, and where?",
        formSteps: EnquiryForms.brandSteps,
        submitLabel: 'Submit request',
        successTitle: 'Request received.',
        successBody:
            'A member of our brand expansion team will review this and get '
            'back to you within one business day.',
      );
    case 'for-franchise':
      return AudienceScreen(
        slug: slug,
        formSource: 'franchise',
        formHeading: 'Your budget, territory and industry interest.',
        formSteps: EnquiryForms.franchiseSteps,
        submitLabel: 'Submit application',
        successTitle: 'Application received.',
        successBody:
            'Our franchise development team reviews every application by '
            'hand and will get back to you within one business day.',
      );
    case 'for-landlords':
      return AudienceScreen(
        slug: slug,
        formSource: 'landlord',
        formHeading: 'Submit your space — we bring the brands to it.',
        formSteps: EnquiryForms.landlordSteps,
        submitLabel: 'Submit property',
        successTitle: 'Property submitted.',
        successBody:
            "We'll review the details and reach out once we've matched it "
            'against brands actively looking to expand in your area.',
      );
    case 'for-investors':
      return AudienceScreen(
        slug: slug,
        formSource: 'investor',
        formHeading: 'Your ticket size, sectors and horizon.',
        formSteps: EnquiryForms.investorSteps,
        submitLabel: 'Submit interest',
        successTitle: 'Interest submitted.',
        successBody:
            'Our investor connections team will review your profile and '
            'reach out with matching opportunities.',
      );
    default:
      throw ArgumentError('Unknown audience slug: $slug');
  }
}
