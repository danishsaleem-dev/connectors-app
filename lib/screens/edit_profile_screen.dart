import 'package:flutter/material.dart';
import '../data/auth_result.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';

/// Editing the account's own details.
///
/// UI only — the mobile API has no profile-update endpoint, so Save
/// reports that rather than pretending to persist. Fields are prefilled
/// from the live session so the screen shows real values where it has
/// them; the rest are left genuinely empty rather than filled with
/// plausible-looking invented details.
class EditProfileScreen extends StatefulWidget {
  final AuthResult session;

  const EditProfileScreen({super.key, required this.session});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: widget.session.name);
  late final _org = TextEditingController(text: widget.session.orgName ?? '');
  final _role = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _bio = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _org.dispose();
    _role.dispose();
    _phone.dispose();
    _website.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.violet600,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.session.name.trim().isEmpty
                              ? '?'
                              : widget.session.name.trim()[0].toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: AppColors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _notWired,
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 17,
                                color: AppColors.violet600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              radius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Field(label: 'Full name', controller: _name),
                  const SizedBox(height: 14),
                  _Field(label: 'Company', controller: _org),
                  const SizedBox(height: 14),
                  _Field(label: 'Your role', controller: _role, hint: 'e.g. Expansion Manager'),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Phone',
                    controller: _phone,
                    hint: '+44 …',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Website',
                    controller: _website,
                    hint: 'https://',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'About',
                    controller: _bio,
                    hint: 'A short description of your business.',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _notWired,
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _notWired() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
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
    );
  }
}
