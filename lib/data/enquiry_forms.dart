import 'package:flutter/material.dart';
import 'form_fields.dart';

/// Ported field-for-field from the website's four enquiry wizards
/// (src/components/forms/*EnquiryForm.tsx + src/lib/schemas/*.ts) — same
/// steps, same option lists, so a brand filling this in on the app sees
/// exactly what they'd see on the site.
class EnquiryForms {
  EnquiryForms._();

  static const _requiredCities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Faisalabad',
    'Multan',
    'Other',
  ];

  static const _industries = [
    'Food & Beverage',
    'Fashion & Apparel',
    'Beauty & Cosmetics',
    'Retail Chains',
    'Fitness & Wellness',
    'Entertainment',
    'Healthcare',
    'Education',
    'Technology',
    'Lifestyle Brands',
    'Luxury Retail',
    'Hospitality',
  ];

  static const brandSteps = [
    FormStep(
      title: 'Company Information',
      fields: [
        TextFieldSpec(name: 'brandName', label: 'Brand Name', required: true, hint: 'e.g. Verona Kitchens'),
        TextFieldSpec(name: 'companyName', label: 'Company Name', required: true, hint: 'Registered company name'),
        TextFieldSpec(name: 'contactName', label: 'Contact Person Name', required: true, hint: 'Full name'),
        TextFieldSpec(name: 'designation', label: 'Designation', hint: 'e.g. Expansion Manager'),
        TextFieldSpec(name: 'mobile', label: 'Mobile Number', required: true, keyboardType: TextInputType.phone, hint: '+92 3XX XXXXXXX'),
        TextFieldSpec(name: 'email', label: 'Email Address', required: true, keyboardType: TextInputType.emailAddress),
        TextFieldSpec(name: 'website', label: 'Website / Social Media', hint: 'https://'),
      ],
    ),
    FormStep(
      title: 'Expansion Requirement',
      fields: [
        CheckboxGroupSpec(name: 'cities', label: 'Required City', options: _requiredCities, required: true),
        TextFieldSpec(
          name: 'preferredAreas',
          label: 'Preferred Area(s)',
          required: true,
          maxLines: 3,
          hint: 'e.g. DHA Phase 6, Gulberg Main Boulevard, Johar Town',
        ),
      ],
    ),
    FormStep(
      title: 'Space Requirement',
      fields: [
        CheckboxGroupSpec(
          name: 'outletTypes',
          label: 'Outlet Type',
          required: true,
          options: ['Restaurant', 'Coffee Shop', 'Clothing', 'Pharmacy', 'Electronics', 'Grocery', 'Other'],
        ),
        RangeFieldSpec(minName: 'areaMin', maxName: 'areaMax', label: 'Required Area (Sq Ft)', required: true),
        CheckboxGroupSpec(
          name: 'locationTypes',
          label: 'Preferred Location Type',
          required: true,
          options: ['Mall', 'High Street', 'Commercial Plaza', 'Standalone Building', 'Mixed Use Development'],
        ),
      ],
    ),
    FormStep(
      title: 'Financial & Additional Services',
      fields: [
        RadioGroupSpec(
          name: 'rentalBudget',
          label: 'Monthly Rental Budget',
          required: true,
          options: ['Under 200,000', '200,000 – 500,000', '500,000 – 1,000,000', 'Above 1,000,000'],
        ),
        CheckboxGroupSpec(
          name: 'additionalServices',
          label: 'Additional Services Required',
          hint: 'Optional',
          options: [
            'Location Sourcing',
            'Lease Negotiation',
            'Interior Design',
            'Fit-Out Execution',
            'Construction & Renovation',
            'Signage & Branding',
            'Mall Leasing Support',
            'Legal Documentation',
            'Retail Expansion Consultancy',
          ],
        ),
      ],
    ),
    FormStep(
      title: 'Uploads',
      fields: [
        FileFieldSpec(label: 'Company Profile (PDF)', hint: 'Optional'),
        FileFieldSpec(label: 'Brand Logo', hint: 'Optional'),
        FileFieldSpec(label: 'Existing Outlet Photos', hint: 'Optional, up to a few'),
      ],
    ),
  ];

  static const franchiseSteps = [
    FormStep(
      title: 'Personal Information',
      fields: [
        TextFieldSpec(name: 'fullName', label: 'Full Name', required: true, hint: 'Your full name'),
        TextFieldSpec(name: 'email', label: 'Email Address', required: true, keyboardType: TextInputType.emailAddress),
        TextFieldSpec(name: 'mobile', label: 'Mobile Number', required: true, keyboardType: TextInputType.phone, hint: '+92 3XX XXXXXXX'),
        TextFieldSpec(name: 'cityOfResidence', label: 'City of Residence', required: true, hint: 'e.g. Lahore'),
      ],
    ),
    FormStep(
      title: 'Investment & Experience',
      fields: [
        RadioGroupSpec(
          name: 'investmentCapacity',
          label: 'Investment Capacity',
          required: true,
          options: [
            'Under PKR 2,500,000',
            'PKR 2,500,000 – 5,000,000',
            'PKR 5,000,000 – 10,000,000',
            'Above PKR 10,000,000',
          ],
        ),
        RadioGroupSpec(
          name: 'businessExperience',
          label: 'Business Experience',
          required: true,
          options: [
            'First-time business owner',
            '1–3 years running a business',
            '3+ years running a business',
            'Currently own another franchise',
          ],
        ),
        TextFieldSpec(name: 'currentBusiness', label: 'Current Business', hint: 'What do you currently run, if anything?'),
      ],
    ),
    FormStep(
      title: 'Franchise Preference',
      fields: [
        CheckboxGroupSpec(name: 'industryInterest', label: 'Industry Interest', required: true, options: _industries),
        CheckboxGroupSpec(name: 'cities', label: 'Preferred Territory', required: true, options: _requiredCities),
        RadioGroupSpec(
          name: 'operationalCapability',
          label: 'How Will You Operate It?',
          required: true,
          options: [
            'I will operate it myself',
            'I will hire a manager',
            'I have a team ready to run it',
            'I plan to be an absentee owner',
          ],
        ),
      ],
    ),
    FormStep(
      title: 'Documents',
      fields: [FileFieldSpec(label: 'CV / Business Profile', hint: 'Optional, PDF')],
    ),
  ];

  static const landlordSteps = [
    FormStep(
      title: 'Contact Information',
      fields: [
        TextFieldSpec(name: 'fullName', label: 'Full Name', required: true, hint: 'Your full name'),
        TextFieldSpec(name: 'companyName', label: 'Company / Entity Name', hint: 'If applicable'),
        TextFieldSpec(name: 'mobile', label: 'Mobile Number', required: true, keyboardType: TextInputType.phone, hint: '+92 3XX XXXXXXX'),
        TextFieldSpec(name: 'email', label: 'Email Address', required: true, keyboardType: TextInputType.emailAddress),
      ],
    ),
    FormStep(
      title: 'Property Details',
      fields: [
        CheckboxGroupSpec(
          name: 'propertyTypes',
          label: 'Property Type',
          required: true,
          options: [
            'Retail shops',
            'Commercial units',
            'Food court spaces',
            'Standalone buildings',
            'Kiosks',
            'Showrooms',
            'Office spaces',
            'Mixed-use properties',
          ],
        ),
        TextFieldSpec(name: 'address', label: 'Property Address / Location', required: true, hint: 'Street, area, landmark'),
        CheckboxGroupSpec(name: 'cities', label: 'City', required: true, options: _requiredCities),
        TextFieldSpec(
          name: 'totalAreaSqFt',
          label: 'Total Area (Sq Ft)',
          required: true,
          keyboardType: TextInputType.number,
          hint: 'e.g. 2200',
        ),
      ],
    ),
    FormStep(
      title: 'Leasing Details',
      fields: [
        DateFieldSpec(name: 'availableFrom', label: 'Available From', required: true),
        RadioGroupSpec(
          name: 'expectedRent',
          label: 'Expected Monthly Rent',
          required: true,
          options: [
            'Under PKR 200,000',
            'PKR 200,000 – 500,000',
            'PKR 500,000 – 1,000,000',
            'Above PKR 1,000,000',
          ],
        ),
        RadioGroupSpec(
          name: 'occupancyStatus',
          label: 'Current Occupancy Status',
          required: true,
          options: [
            'Vacant now',
            'Currently occupied, becoming vacant soon',
            'New construction / not yet built',
          ],
        ),
      ],
    ),
    FormStep(
      title: 'Uploads',
      fields: [
        FileFieldSpec(label: 'Property Photos', hint: 'Optional, up to a few'),
        FileFieldSpec(label: 'Floor Plan / Layout', hint: 'Optional'),
      ],
    ),
  ];

  static const investorSteps = [
    FormStep(
      title: 'Contact Information',
      fields: [
        TextFieldSpec(name: 'fullName', label: 'Full Name', required: true, hint: 'Your full name'),
        TextFieldSpec(name: 'email', label: 'Email Address', required: true, keyboardType: TextInputType.emailAddress),
        TextFieldSpec(name: 'mobile', label: 'Mobile Number', required: true, keyboardType: TextInputType.phone, hint: '+92 3XX XXXXXXX'),
        TextFieldSpec(name: 'companyOrFund', label: 'Company / Fund Name', hint: 'If applicable'),
      ],
    ),
    FormStep(
      title: 'Investment Profile',
      fields: [
        RadioGroupSpec(
          name: 'ticketSize',
          label: 'Investment Ticket Size',
          required: true,
          options: [
            'Under PKR 5,000,000',
            'PKR 5,000,000 – 20,000,000',
            'PKR 20,000,000 – 50,000,000',
            'Above PKR 50,000,000',
          ],
        ),
        CheckboxGroupSpec(
          name: 'investmentTypes',
          label: 'Preferred Investment Type',
          required: true,
          options: [
            'Franchise investment (multi-unit)',
            'Brand equity / growth capital',
            'Joint venture',
            'Commercial real estate / project',
            'Business acquisition',
          ],
        ),
        CheckboxGroupSpec(name: 'sectorInterest', label: 'Sector Interest', required: true, options: _industries),
      ],
    ),
    FormStep(
      title: 'Preferences',
      fields: [
        CheckboxGroupSpec(name: 'cities', label: 'Preferred City / Region', required: true, options: _requiredCities),
        RadioGroupSpec(
          name: 'horizon',
          label: 'Investment Horizon',
          required: true,
          options: ['Short-term (1–2 years)', 'Medium-term (3–5 years)', 'Long-term (5+ years)'],
        ),
      ],
    ),
    FormStep(
      title: 'Documents',
      fields: [FileFieldSpec(label: 'Investment Profile / Company Overview', hint: 'Optional, PDF')],
    ),
  ];
}
