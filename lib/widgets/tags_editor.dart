import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A plain-string chip input — add by typing + Enter or tapping Add,
/// remove by tapping a chip's ×. Same interaction as the website's own
/// TagsEditor (industries) and ExpertiseEditor (minus the optional
/// per-tag description the website's version also has — see
/// ProfileDraft.expertise's doc comment for why that's not here yet).
class TagsEditor extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;
  final String placeholder;

  const TagsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.placeholder = 'e.g. Site Selection',
  });

  @override
  State<TagsEditor> createState() => _TagsEditorState();
}

class _TagsEditorState extends State<TagsEditor> {
  late List<String> _tags = List.of(widget.initial);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final value = _controller.text.trim();
    if (value.isEmpty || _tags.any((t) => t.toLowerCase() == value.toLowerCase())) {
      _controller.clear();
      return;
    }
    setState(() {
      _tags = [..._tags, value];
      _controller.clear();
    });
    widget.onChanged(_tags);
  }

  void _remove(int index) {
    setState(() => _tags = [..._tags]..removeAt(index));
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _tags.length; i++)
                Chip(
                  label: Text(_tags[i]),
                  onDeleted: () => _remove(i),
                  backgroundColor: AppColors.violet50,
                  labelStyle: const TextStyle(color: AppColors.violet700),
                  deleteIconColor: AppColors.violet600,
                  side: const BorderSide(color: AppColors.violet200),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  filled: true,
                  fillColor: AppColors.grey50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: _add, child: const Text('Add')),
          ],
        ),
      ],
    );
  }
}
