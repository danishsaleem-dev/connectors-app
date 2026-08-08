import 'package:flutter/material.dart';

/// One typed field spec per input shape the four website wizards use.
/// EnquiryWizard renders whichever variant a step lists — this is the model
/// half of that split; enquiry_forms.dart supplies the actual step content
/// per audience.
sealed class FieldSpec {
  final String label;
  final bool required;
  final String? hint;

  const FieldSpec({required this.label, this.required = false, this.hint});
}

class TextFieldSpec extends FieldSpec {
  final String name;
  final TextInputType keyboardType;
  final int maxLines;

  const TextFieldSpec({
    required this.name,
    required super.label,
    super.required,
    super.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });
}

class DateFieldSpec extends FieldSpec {
  final String name;

  const DateFieldSpec({required this.name, required super.label, super.required});
}

/// Sq Ft min/max pair — the one two-field-in-one-row shape the brand form
/// uses for "Required Area".
class RangeFieldSpec extends FieldSpec {
  final String minName;
  final String maxName;

  const RangeFieldSpec({
    required this.minName,
    required this.maxName,
    required super.label,
    super.required,
  });
}

class CheckboxGroupSpec extends FieldSpec {
  final String name;
  final List<String> options;
  /// The API field name for the free-text companion when "Other" is
  /// selected — e.g. "cities" pairs with "otherCity". Null when the group
  /// has no "Other" option.
  final String? otherFieldName;

  const CheckboxGroupSpec({
    required this.name,
    required super.label,
    required this.options,
    this.otherFieldName,
    super.required,
    super.hint,
  });
}

class RadioGroupSpec extends FieldSpec {
  final String name;
  final List<String> options;

  const RadioGroupSpec({
    required this.name,
    required super.label,
    required this.options,
    super.required,
  });
}

/// Every file field on the website is optional, and real upload handling
/// needs a backend endpoint this app doesn't have yet — rendered as an
/// honest "coming soon" tile rather than faking a working picker.
class FileFieldSpec extends FieldSpec {
  const FileFieldSpec({required super.label, super.hint});
}

class FormStep {
  final String title;
  final List<FieldSpec> fields;

  const FormStep({required this.title, required this.fields});
}
