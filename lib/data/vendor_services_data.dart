import 'package:flutter/material.dart';

/// The Partners Program's service catalog — same twelve disciplines as the
/// website's /vendor-services, grouped into three categories for the app's
/// catalog view. The website gives each of these its own deep page
/// (deliverables, who it's for, FAQs); that depth stays website-only by
/// design — a phone screen gets the catalog, not the full brief for all
/// twelve.
class VendorService {
  final String title;
  final String body;
  final IconData icon;
  final String category;

  const VendorService({
    required this.title,
    required this.body,
    required this.icon,
    required this.category,
  });
}

class VendorServicesData {
  VendorServicesData._();

  static const _designAndBuild = 'Design & Build';
  static const _marketingAndLaunch = 'Marketing & Launch';
  static const _operationsAndCompliance = 'Operations & Compliance';

  static const all = [
    VendorService(
      title: 'Designers',
      body: 'Brand identity, store concept and the visual language a rollout repeats.',
      icon: Icons.brush_rounded,
      category: _designAndBuild,
    ),
    VendorService(
      title: 'Architects',
      body: 'Drawings, approvals and the technical package a landlord and council will accept.',
      icon: Icons.architecture_rounded,
      category: _designAndBuild,
    ),
    VendorService(
      title: 'Interior Specialists',
      body: 'Fit-out, joinery, lighting and the finish that makes a unit feel like the brand.',
      icon: Icons.chair_alt_rounded,
      category: _designAndBuild,
    ),
    VendorService(
      title: 'Contractors',
      body: 'Build, site management and handing over on the date you said you would.',
      icon: Icons.construction_rounded,
      category: _designAndBuild,
    ),
    VendorService(
      title: 'Agencies',
      body: 'Launch campaigns, local marketing and the opening that gets noticed.',
      icon: Icons.campaign_rounded,
      category: _marketingAndLaunch,
    ),
    VendorService(
      title: 'Advertisements',
      body: 'Paid media, outdoor and launch advertising planned around the opening date.',
      icon: Icons.bar_chart_rounded,
      category: _marketingAndLaunch,
    ),
    VendorService(
      title: 'Customer Care Training',
      body: 'Front-of-house standards and service training that protects the brand.',
      icon: Icons.support_agent_rounded,
      category: _marketingAndLaunch,
    ),
    VendorService(
      title: 'Consultants',
      body: 'Feasibility, operations, supply chain and franchise structuring.',
      icon: Icons.insights_rounded,
      category: _operationsAndCompliance,
    ),
    VendorService(
      title: 'Accounts',
      body: 'Bookkeeping, payroll and financial reporting for a growing operation.',
      icon: Icons.calculate_rounded,
      category: _operationsAndCompliance,
    ),
    VendorService(
      title: 'Audit',
      body: 'Compliance checks and brand-standard audits across the network.',
      icon: Icons.fact_check_rounded,
      category: _operationsAndCompliance,
    ),
    VendorService(
      title: 'Franchise Training',
      body: 'Structured onboarding and operational training for every new franchisee.',
      icon: Icons.school_rounded,
      category: _operationsAndCompliance,
    ),
    VendorService(
      title: 'Project Handling',
      body: 'End-to-end project management from signed lease to opening day.',
      icon: Icons.assignment_rounded,
      category: _operationsAndCompliance,
    ),
  ];

  /// Same twelve services grouped under the three categories above, in a
  /// fixed display order — used to render the catalog as scannable
  /// categories instead of one long undifferentiated list.
  static List<MapEntry<String, List<VendorService>>> get grouped {
    const order = [_designAndBuild, _marketingAndLaunch, _operationsAndCompliance];
    return [
      for (final category in order)
        MapEntry(category, all.where((s) => s.category == category).toList()),
    ];
  }
}
