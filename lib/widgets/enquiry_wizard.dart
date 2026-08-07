import 'package:flutter/material.dart';
import '../data/form_fields.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Renders any of the four ported enquiry forms from a `List<FormStep>` —
/// same step-by-step shape as the website's useFormWizard hook (progress
/// dots, per-step required-field validation, Back/Next, a real "reviewed by
/// hand" success screen on the last step).
///
/// There's no backend to post to yet — this app is public screens only for
/// now (see the mobile-app phase notes) — so "submitting" just validates and
/// shows the success state locally. Wiring real submission needs a JSON API
/// route on the website; Server Actions aren't callable from outside Next.js.
class EnquiryWizard extends StatefulWidget {
  final List<FormStep> steps;
  final String submitLabel;
  final String successTitle;
  final String successBody;

  const EnquiryWizard({
    super.key,
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
  String? _stepError;

  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _controllerFor(String name) =>
      _controllers.putIfAbsent(name, () => TextEditingController());

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
          return _controllerFor('$name:other').text.trim().isNotEmpty;
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

  void _next() {
    if (!_validateStep(_stepIndex)) return;
    if (_stepIndex == widget.steps.length - 1) {
      setState(() => _submitted = true);
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
                  child: OutlinedButton(onPressed: _back, child: const Text('Back')),
                ),
              if (_stepIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: _stepIndex > 0 ? 1 : 1,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLastStep ? widget.submitLabel : 'Next'),
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

      case CheckboxGroupSpec(:final name, :final options, :final hint):
        final selected = (values[name] as Set<String>?) ?? <String>{};
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
                controller: controllerFor('$name:other'),
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
