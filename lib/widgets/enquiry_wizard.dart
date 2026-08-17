import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/form_fields.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Renders any of the four ported enquiry forms from a `List<FormStep>` —
/// same step-by-step shape as the website's useFormWizard hook (progress
/// dots, per-step required-field validation, Back/Next), submitting to the
/// same /api/mobile/enquiries route every audience shares (see ApiClient),
/// which validates with the exact zod schemas the website's own Server
/// Actions use and lands the entry in the same admin queue.
class EnquiryWizard extends StatefulWidget {
  final String source;
  final List<FormStep> steps;
  final String submitLabel;
  final String successTitle;
  final String successBody;

  const EnquiryWizard({
    super.key,
    required this.source,
    required this.steps,
    required this.successTitle,
    required this.successBody,
    this.submitLabel = 'Submit',
  });

  @override
  State<EnquiryWizard> createState() => _EnquiryWizardState();
}

class _EnquiryWizardState extends State<EnquiryWizard> {
  int _stepIndex = 0;
  bool _submitted = false;
  bool _submitting = false;
  String? _stepError;

  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _controllerFor(String name) =>
      _controllers.putIfAbsent(name, () => TextEditingController());

  String _otherKey(CheckboxGroupSpec field) => field.otherFieldName ?? '${field.name}:other';

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isFilled(FieldSpec field) {
    switch (field) {
      case TextFieldSpec(:final name):
        return _controllerFor(name).text.trim().isNotEmpty;
      case DateFieldSpec(:final name):
        return _values[name] != null;
      case RangeFieldSpec(:final minName, :final maxName):
        return _controllerFor(minName).text.trim().isNotEmpty &&
            _controllerFor(maxName).text.trim().isNotEmpty;
      case CheckboxGroupSpec(:final name):
        final selected = _values[name] as Set<String>?;
        if (selected == null || selected.isEmpty) return false;
        if (selected.contains('Other')) {
          return _controllerFor(_otherKey(field)).text.trim().isNotEmpty;
        }
        return true;
      case RadioGroupSpec(:final name):
        return _values[name] != null;
      case FileFieldSpec():
        return true; // always optional
    }
  }

  bool _validateStep(int index) {
    final step = widget.steps[index];
    for (final field in step.fields) {
      if (field.required && !_isFilled(field)) {
        setState(() => _stepError = 'Fill in "${field.label}" to continue.');
        return false;
      }
    }
    setState(() => _stepError = null);
    return true;
  }

  /// Walks every step's fields (not just the current one — earlier steps'
  /// values are already collected in _values/_controllers) into the flat
  /// JSON body /api/mobile/enquiries expects.
  Map<String, dynamic> _collectPayload() {
    final payload = <String, dynamic>{};
    for (final step in widget.steps) {
      for (final field in step.fields) {
        switch (field) {
          case TextFieldSpec(:final name):
            final text = _controllerFor(name).text.trim();
            if (text.isNotEmpty) payload[name] = text;
          case RangeFieldSpec(:final minName, :final maxName):
            final min = _controllerFor(minName).text.trim();
            final max = _controllerFor(maxName).text.trim();
            if (min.isNotEmpty) payload[minName] = min;
            if (max.isNotEmpty) payload[maxName] = max;
          case DateFieldSpec(:final name):
            final date = _values[name] as DateTime?;
            if (date != null) {
              payload[name] =
                  '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          case CheckboxGroupSpec(:final name):
            final selected = (_values[name] as Set<String>?) ?? <String>{};
            payload[name] = selected.toList();
            if (field.otherFieldName != null && selected.contains('Other')) {
              final other = _controllerFor(_otherKey(field)).text.trim();
              if (other.isNotEmpty) payload[field.otherFieldName!] = other;
            }
          case RadioGroupSpec(:final name):
            final value = _values[name] as String?;
            if (value != null) payload[name] = value;
          case FileFieldSpec():
            break; // no upload support yet — see FileFieldSpec's doc comment
        }
      }
    }
    return payload;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ApiClient.submitEnquiry(widget.source, _collectPayload());
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _stepError = err is ApiException ? err.message : 'Something went wrong. Please try again.';
      });
    }
  }

  void _next() {
    if (_submitting) return;
    if (!_validateStep(_stepIndex)) return;
    if (_stepIndex == widget.steps.length - 1) {
      _submit();
    } else {
      setState(() => _stepIndex++);
    }
  }

  void _back() {
    setState(() {
      _stepError = null;
      _stepIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessCard(title: widget.successTitle, body: widget.successBody);
    }

    final step = widget.steps[_stepIndex];
    final isLastStep = _stepIndex == widget.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepProgress(total: widget.steps.length, current: _stepIndex, title: step.title),
          const SizedBox(height: 20),
          for (var i = 0; i < step.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _FieldRenderer(
              field: step.fields[i],
              values: _values,
              controllerFor: _controllerFor,
              onChanged: () => setState(() {}),
            ),
          ],
          if (_stepError != null) ...[
            const SizedBox(height: 16),
            Text(
              _stepError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_stepIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : _back,
                    child: const Text('Back'),
                  ),
                ),
              if (_stepIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : _next,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      // Scales the label down to fit one line instead of
                      // wrapping — labels like "Submit application" don't
                      // fit the button's default padding on narrower phones
                      // once it's sharing the row with Back.
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isLastStep ? widget.submitLabel : 'Next',
                            maxLines: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int total;
  final int current;
  final String title;

  const _StepProgress({required this.total, required this.current, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == current
                      ? AppColors.violet600
                      : i < current
                          ? AppColors.violet50
                          : AppColors.grey100,
                ),
                child: i < current
                    ? const Icon(Icons.check, size: 13, color: AppColors.violet600)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: i == current ? AppColors.white : AppColors.grey300,
                        ),
                      ),
              ),
              if (i < total - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: i < current ? AppColors.violet200 : AppColors.grey200,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'STEP ${current + 1} OF $total — ${title.toUpperCase()}',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.violet600, letterSpacing: 1.2),
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String title;
  final String body;

  const _SuccessCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _FieldRenderer extends StatelessWidget {
  final FieldSpec field;
  final Map<String, dynamic> values;
  final TextEditingController Function(String name) controllerFor;
  final VoidCallback onChanged;

  const _FieldRenderer({
    required this.field,
    required this.values,
    required this.controllerFor,
    required this.onChanged,
  });

  Widget _label(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: field.label),
          if (field.required)
            const TextSpan(text: ' *', style: TextStyle(color: AppColors.violet400)),
        ],
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, {String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.violet600, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (field) {
      case TextFieldSpec(:final name, :final keyboardType, :final maxLines, :final hint):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 8),
            TextField(
              controller: controllerFor(name),
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: _decoration(context, hintText: hint),
              onChanged: (_) => onChanged(),
            ),
          ],
        );

      case RangeFieldSpec(:final minName, :final maxName):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllerFor(minName),
                    keyboardType: TextInputType.number,
                    decoration: _decoration(context, hintText: 'Min'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controllerFor(maxName),
                    keyboardType: TextInputType.number,
                    decoration: _decoration(context, hintText: 'Max'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ],
        );

      case DateFieldSpec(:final name):
        final selected = values[name] as DateTime?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selected ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked != null) {
                  values[name] = picked;
                  onChanged();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  border: Border.all(color: AppColors.grey200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey500),
                    const SizedBox(width: 10),
                    Text(
                      selected == null
                          ? 'Select a date'
                          : '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case CheckboxGroupSpec(:final name, :final options, :final hint, :final otherFieldName):
        final selected = (values[name] as Set<String>?) ?? <String>{};
        final otherKey = otherFieldName ?? '$name:other';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            if (hint != null) ...[
              const SizedBox(height: 2),
              Text(hint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return _SelectChip(
                  label: option,
                  selected: isSelected,
                  onTap: () {
                    final next = Set<String>.from(selected);
                    if (isSelected) {
                      next.remove(option);
                    } else {
                      next.add(option);
                    }
                    values[name] = next;
                    onChanged();
                  },
                );
              }).toList(),
            ),
            if (selected.contains('Other')) ...[
              const SizedBox(height: 10),
              TextField(
                controller: controllerFor(otherKey),
                decoration: _decoration(context, hintText: 'Please specify'),
                onChanged: (_) => onChanged(),
              ),
            ],
          ],
        );

      case RadioGroupSpec(:final name, :final options):
        final selected = values[name] as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return _SelectChip(
                  label: option,
                  selected: selected == option,
                  onTap: () {
                    values[name] = option;
                    onChanged();
                  },
                );
              }).toList(),
            ),
          ],
        );

      case FileFieldSpec(:final hint):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File attachments are coming soon.')),
              ),
              child: DottedTile(hint: hint),
            ),
          ],
        );
    }
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet50 : AppColors.white,
          border: Border.all(color: selected ? AppColors.violet600 : AppColors.grey200),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? AppColors.violet600 : AppColors.ink,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

class DottedTile extends StatelessWidget {
  final String? hint;

  const DottedTile({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border.all(color: AppColors.grey200, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.upload_file_outlined, color: AppColors.grey300),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(hint!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500)),
          ],
        ],
      ),
    );
  }
}
