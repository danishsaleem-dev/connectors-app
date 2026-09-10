import 'package:flutter/material.dart';
import '../data/countries.dart';
import '../data/profile_fields.dart';
import '../theme/colors.dart';
import '../utils/validators.dart';

/// Renders one [ProfileField] against [ProfileDraft].
///
/// Shared so the completion flow and Edit Profile stay in lockstep — the
/// same field definition drives both, which is the whole point of having
/// the definitions in one place. Adding a field to the doc's list means
/// touching profile_fields.dart only.
class ProfileFieldInput extends StatefulWidget {
  final ProfileField field;

  const ProfileFieldInput({super.key, required this.field});

  @override
  State<ProfileFieldInput> createState() => _ProfileFieldInputState();
}

class _ProfileFieldInputState extends State<ProfileFieldInput> {
  late final TextEditingController _controller = TextEditingController(
    text: ProfileDraft.get(widget.field.key) is String
        ? ProfileDraft.get(widget.field.key) as String
        : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _decoration({String? hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint ?? widget.field.hint,
        hintStyle: const TextStyle(color: AppColors.grey300),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
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

  @override
  Widget build(BuildContext context) {
    // A checkbox carries its own label inline (checkbox-style, not a
    // heading over an input) — repeating it above would say the same
    // sentence twice.
    if (widget.field.kind == ProfileFieldKind.checkbox) return _input(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _input(context),
      ],
    );
  }

  /// The phone field specifically — validated live against whichever
  /// country is currently selected in this same step (see
  /// _organizationStep's doc comment on why country has to come first).
  /// Rebuilds on every ProfileDraft.values change, country included,
  /// since that's the one signal this needs to react to beyond its own
  /// typing.
  Widget _phoneInput() {
    return ValueListenableBuilder<Map<String, Object>>(
      valueListenable: ProfileDraft.values,
      builder: (context, values, _) {
        final country = countryByName(values['country'] as String?);
        final text = _controller.text.trim();
        final error = text.isEmpty
            ? null
            : FormatValidators.phoneError(text, country: country);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: _decoration(),
              onChanged: (v) => ProfileDraft.set('phone', v),
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(
                error,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _input(BuildContext context) {
    final field = widget.field;

    switch (field.kind) {
      case ProfileFieldKind.text:
      case ProfileFieldKind.number:
      case ProfileFieldKind.multiline:
        if (field.key == 'phone') return _phoneInput();
        return TextField(
          controller: _controller,
          maxLines: field.kind == ProfileFieldKind.multiline ? 4 : 1,
          keyboardType: field.kind == ProfileFieldKind.number
              ? TextInputType.number
              : TextInputType.text,
          decoration: _decoration(),
          onChanged: (v) => ProfileDraft.set(field.key, v),
        );

      case ProfileFieldKind.select:
        final value = ProfileDraft.get(field.key) as String?;
        return DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: _decoration(hint: 'Choose…'),
          items: field.options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(field.optionLabels[o] ?? o),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => ProfileDraft.set(field.key, v)),
        );

      case ProfileFieldKind.checkbox:
        final checked = ProfileDraft.get(field.key) == true;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => ProfileDraft.set(field.key, !checked)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              border: Border.all(
                color: checked ? AppColors.violet600 : AppColors.grey200,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: checked,
                  activeColor: AppColors.violet600,
                  onChanged: (v) =>
                      setState(() => ProfileDraft.set(field.key, v ?? false)),
                ),
                Expanded(
                  child: Text(
                    field.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );

      case ProfileFieldKind.multiSelect:
        final selected =
            (ProfileDraft.get(field.key) as List?)?.cast<String>() ??
            const <String>[];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: field.options.map((option) {
            final isOn = selected.contains(option);
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                final next = List<String>.from(selected);
                isOn ? next.remove(option) : next.add(option);
                setState(() => ProfileDraft.set(field.key, next));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isOn ? AppColors.violet600 : AppColors.grey50,
                  border: Border.all(
                    color: isOn ? AppColors.violet600 : AppColors.grey200,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isOn ? AppColors.white : AppColors.ink,
                    fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case ProfileFieldKind.upload:
        final done = ProfileDraft.get(field.key) != null;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          // No file picker wired up — marking it "attached" locally is
          // enough to demonstrate the state change without pretending a
          // file was actually stored anywhere.
          onTap: () {
            setState(
              () => ProfileDraft.set(field.key, done ? null : 'attached'),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File picking is coming soon')),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: done
                  ? AppColors.violet600.withValues(alpha: 0.06)
                  : AppColors.grey50,
              border: Border.all(
                color: done ? AppColors.violet600 : AppColors.grey200,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_outlined,
                  color: done ? AppColors.violet600 : AppColors.grey300,
                ),
                const SizedBox(height: 6),
                Text(
                  done ? 'Attached' : 'Upload ${field.label.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: done ? AppColors.violet600 : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
