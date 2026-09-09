import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/form_fields.dart';
import '../data/upload.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// One picked-and-uploaded file — [displayName] is what was actually
/// picked (for showing "brand-logo.png" in the UI); [path] is the private
/// Storage path the server needs, from ApiClient.uploadFile.
class _UploadedFile {
  final String displayName;
  final String path;

  const _UploadedFile({required this.displayName, required this.path});
}

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
  final Map<String, bool> _fileUploading = {};
  final Map<String, List<_UploadedFile>> _uploadedFiles = {};

  TextEditingController _controllerFor(String name) =>
      _controllers.putIfAbsent(name, () => TextEditingController());

  String _otherKey(CheckboxGroupSpec field) => field.otherFieldName ?? '${field.name}:other';

  /// Picks (one, or several when [FileFieldSpec.multiple]) and uploads
  /// immediately — same "upload on pick, not on submit" flow as Edit
  /// Profile's photo, so a mistake is caught before the whole form's been
  /// filled in, not after. PDF/Word/image because these are documents and
  /// photos, not just photos — unlike the profile-photo upload, which is
  /// UploadPurpose.photo and image-only.
  Future<void> _pickFile(FileFieldSpec field) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: field.multiple,
      );
    } catch (_) {
      setState(() => _stepError = "Couldn't open the file picker.");
      return;
    }
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _fileUploading[field.name] = true;
      _stepError = null;
    });
    try {
      final uploaded = <_UploadedFile>[];
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        final res = await ApiClient.uploadFile(File(path), purpose: UploadPurpose.document);
        uploaded.add(_UploadedFile(displayName: file.name, path: res.path));
      }
      if (!mounted) return;
      setState(() {
        if (field.multiple) {
          _uploadedFiles.putIfAbsent(field.name, () => []).addAll(uploaded);
        } else {
          _uploadedFiles[field.name] = uploaded;
        }
        _fileUploading[field.name] = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _fileUploading[field.name] = false;
        _stepError =
            err is ApiException ? err.message : "Couldn't upload that file. Please try again.";
      });
    }
  }

  void _removeFile(String name, int index) {
    setState(() => _uploadedFiles[name]?.removeAt(index));
  }

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
      final formatError = _formatError(field);
      if (formatError != null) {
        setState(() => _stepError = formatError);
        return false;
      }
    }
    setState(() => _stepError = null);
    return true;
  }

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  // Digits plus the punctuation a real phone number is actually written
  // with (+, spaces, hyphens, parens) — rejects anything with a letter or
  // other stray character, then separately requires enough digits that a
  // partial/garbled number ("123") can't pass just for looking phone-shaped.
  static final _phoneCharsPattern = RegExp(r'^[0-9+\-\s()]+$');

  /// Real format checks, independent of _isFilled's presence check —
  /// applies whether or not the field is required, so an *optional* email
  /// field that's been typed into still has to actually be an email.
  /// Server-side validation already exists (the zod schemas behind
  /// /api/mobile/enquiries — see this class's doc comment), but catching
  /// it here means a mistyped email fails on the step it was typed on,
  /// not after a round trip once the whole form's been filled in.
  String? _formatError(FieldSpec field) {
    switch (field) {
      case TextFieldSpec(:final name, :final label, :final keyboardType):
        final text = _controllerFor(name).text.trim();
        if (text.isEmpty) return null;
        if (keyboardType == TextInputType.emailAddress) {
          if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address.';
        } else if (keyboardType == TextInputType.phone) {
          final digitCount = text.replaceAll(RegExp(r'[^0-9]'), '').length;
          if (!_phoneCharsPattern.hasMatch(text) || digitCount < 7) {
            return 'Enter a valid phone number.';
          }
        } else if (keyboardType == TextInputType.number) {
          if (double.tryParse(text) == null) return 'Enter a valid number for "$label".';
        }
        return null;

      case RangeFieldSpec(:final minName, :final maxName, :final label):
        final minText = _controllerFor(minName).text.trim();
        final maxText = _controllerFor(maxName).text.trim();
        if (minText.isEmpty && maxText.isEmpty) return null;
        final min = minText.isEmpty ? null : double.tryParse(minText);
        final max = maxText.isEmpty ? null : double.tryParse(maxText);
        if (minText.isNotEmpty && min == null) {
          return 'Enter a valid number for "$label".';
        }
        if (maxText.isNotEmpty && max == null) {
          return 'Enter a valid number for "$label".';
        }
        if (min != null && max != null && min > max) {
          return '"$label" minimum can\'t be more than the maximum.';
        }
        return null;

      case DateFieldSpec():
      case CheckboxGroupSpec():
      case RadioGroupSpec():
      case FileFieldSpec():
        return null;
    }
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
          case FileFieldSpec(:final name, :final multiple):
            final files = _uploadedFiles[name] ?? const [];
            if (files.isEmpty) break;
            payload[name] = multiple ? files.map((f) => f.path).toList() : files.first.path;
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
            if (i > 0) const SizedBox(height: 14),
            _FieldRenderer(
              field: step.fields[i],
              values: _values,
              controllerFor: _controllerFor,
              onChanged: () => setState(() {}),
              isUploading: (name) => _fileUploading[name] ?? false,
              uploadedFilesFor: (name) => _uploadedFiles[name] ?? const [],
              onPickFile: _pickFile,
              onRemoveFile: _removeFile,
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

/// A slim segmented bar rather than the numbered-circles-and-connectors
/// stepper this replaced — that pattern reads as a website wizard ported
/// to a phone; a segmented progress bar (the same shape as a story
/// progress indicator) is the mobile-native equivalent and costs a lot
/// less vertical space.
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
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.violet600 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Step ${current + 1} of $total',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.violet600),
            ),
            Expanded(
              child: Text(
                '  ·  $title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w500),
              ),
            ),
          ],
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
  final bool Function(String name) isUploading;
  final List<_UploadedFile> Function(String name) uploadedFilesFor;
  final void Function(FileFieldSpec field) onPickFile;
  final void Function(String name, int index) onRemoveFile;

  const _FieldRenderer({
    required this.field,
    required this.values,
    required this.controllerFor,
    required this.onChanged,
    required this.isUploading,
    required this.uploadedFilesFor,
    required this.onPickFile,
    required this.onRemoveFile,
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

  Widget _floatingLabel(BuildContext context, {String? text}) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
        children: [
          TextSpan(text: text ?? field.label),
          if (field.required)
            const TextSpan(text: ' *', style: TextStyle(color: AppColors.violet400)),
        ],
      ),
    );
  }

  /// Used by single-line text/date fields — a floating label inside the
  /// field itself instead of a separate label row above it. That
  /// above-the-field pattern is a desktop-form convention; collapsing
  /// label + input into one compact control is the mobile-native
  /// equivalent, and shaves real vertical space off a 5-field-per-step
  /// form.
  InputDecoration _floatingDecoration(BuildContext context, {String? hintText, Widget? label}) {
    return InputDecoration(
      label: label ?? _floatingLabel(context),
      hintText: hintText,
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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

  /// Used by grouped fields (range, checkboxes, radios, file) where a
  /// persistent label above makes sense — they aren't a single value a
  /// floating label could collapse into.
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
        return TextField(
          controller: controllerFor(name),
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: _floatingDecoration(context, hintText: hint),
          onChanged: (_) => onChanged(),
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
        return InkWell(
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
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              border: Border.all(color: AppColors.grey200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _floatingLabel(context),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.grey500),
                    const SizedBox(width: 8),
                    Text(
                      selected == null
                          ? 'Select a date'
                          : '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
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

      case FileFieldSpec(:final name, :final hint, :final multiple):
        final uploading = isUploading(name);
        final files = uploadedFilesFor(name);
        // Single-file fields hide the picker once something's uploaded —
        // tapping the file's own remove button is how you'd pick a
        // different one, rather than the tile silently accepting a second
        // file that would then overwrite the first without saying so.
        final showPicker = multiple || files.isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context),
            const SizedBox(height: 8),
            for (var i = 0; i < files.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _UploadedFileTile(name: files[i].displayName, onRemove: () => onRemoveFile(name, i)),
            ],
            if (files.isNotEmpty && (uploading || showPicker)) const SizedBox(height: 8),
            if (uploading)
              const _UploadingTile()
            else if (showPicker)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                // `field` (this.field, typed FieldSpec) isn't promoted by
                // the switch pattern the way a local parameter would be —
                // this cast is safe precisely because we're already inside
                // the exhaustive `case FileFieldSpec(...)` branch.
                onTap: () => onPickFile(field as FileFieldSpec),
                child: DottedTile(hint: hint),
              ),
          ],
        );
    }
  }
}

class _UploadedFileTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _UploadedFileTile({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        border: Border.all(color: AppColors.violet200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 18, color: AppColors.violet600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.violet700),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.violet600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadingTile extends StatelessWidget {
  const _UploadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet400),
          ),
          const SizedBox(height: 8),
          Text('Uploading…', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500)),
        ],
      ),
    );
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
