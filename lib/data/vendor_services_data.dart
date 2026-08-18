import 'package:flutter/material.dart';

/// The Partners Program's service catalog — same twelve disciplines as the
/// website's /vendor-services, one-line each. The website gives each of
/// these its own deep page (deliverables, who it's for, FAQs); that depth
/// stays website-only by design — a phone screen gets the catalog, not the
/// full brief for all twelve.
class VendorService {
  final String title;
  final String body;
  final IconData icon;

  const VendorService({required this.title, required this.body, required this.icon});
}

class VendorServicesData {
  VendorServicesData._();

  static const all = [
    VendorService(
      title: 'Designers',
      body: 'Brand identity, store concept and the visual language a rollout repeats.',
      icon: Icons.brush_rounded,
    ),
    VendorService(
      title: 'Architects',
      body: 'Drawings, approvals and the technical package a landlord and council will accept.',
      icon: Icons.architecture_rounded,
    ),
    VendorService(
      title: 'Interior Specialists',
      body: 'Fit-out, joinery, lighting and the finish that makes a unit feel like the brand.',
      icon: Icons.chair_alt_rounded,
    ),
    VendorService(
      title: 'Agencies',
      body: 'Launch campaigns, local marketing and the opening that gets noticed.',
      icon: Icons.campaign_rounded,
    ),
    VendorService(
      title: 'Consultants',
      body: 'Feasibility, operations, supply chain and franchise structuring.',
      icon: Icons.insights_rounded,
    ),
    VendorService(
      title: 'Contractors',
      body: 'Build, site management and handing over on the date you said you would.',
      icon: Icons.construction_rounded,
    ),
    VendorService(
      title: 'Accounts',
      body: 'Bookkeeping, payroll and financial reporting for a growing operation.',
      icon: Icons.calculate_rounded,
    ),
    VendorService(
      title: 'Audit',
      body: 'Compliance checks and brand-standard audits across the network.',
      icon: Icons.fact_check_rounded,
    ),
    VendorService(
      title: 'Franchise Training',
      body: 'Structured onboarding and operational training for every new franchisee.',
      icon: Icons.school_rounded,
    ),
    VendorService(
      title: 'Customer Care Training',
      body: 'Front-of-house standards and service training that protects the brand.',
      icon: Icons.support_agent_rounded,
    ),
    VendorService(
      title: 'Advertisements',
      body: 'Paid media, outdoor and launch advertising planned around the opening date.',
      icon: Icons.bar_chart_rounded,
    ),
    VendorService(
      title: 'Project Handling',
      body: 'End-to-end project management from signed lease to opening day.',
      icon: Icons.assignment_rounded,
    ),
  ];
}
