/// Same six self-service account types and per-type organisation-name
/// labels as the website's RegisterForm CHOICES — kept in sync by hand
/// since it's six short lines, not worth a codegen step for.
class AccountTypeOption {
  final String value;
  final String label;
  final String orgLabel;

  const AccountTypeOption({required this.value, required this.label, required this.orgLabel});
}

const accountTypes = [
  AccountTypeOption(value: 'brand', label: 'Brand', orgLabel: 'Company name'),
  AccountTypeOption(
    value: 'franchisee',
    label: 'Franchisee',
    orgLabel: 'Business name (or your own)',
  ),
  AccountTypeOption(
    value: 'landlord',
    label: 'Landlord',
    orgLabel: 'Company / individual name',
  ),
  AccountTypeOption(value: 'developer', label: 'Mall / Developer', orgLabel: 'Company name'),
  AccountTypeOption(
    value: 'investor',
    label: 'Investor',
    orgLabel: 'Company / individual name',
  ),
  AccountTypeOption(value: 'vendor', label: 'Vendor', orgLabel: 'Studio / company name'),
];

/// Same discipline options as VENDOR_DISCIPLINE_LABEL on the website.
const vendorDisciplines = {
  'designer': 'Designer',
  'architect': 'Architect',
  'interior': 'Interior Specialist',
  'agency': 'Agency',
  'consultant': 'Consultant',
  'contractor': 'Contractor',
};
