import 'package:flutter/material.dart';
import '../data/account_types.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../data/oauth_outcome.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';

/// The second half of a first-time Google/Apple signup.
///
/// A provider hands over an email and (sometimes) a name; it can't say
/// whether this is a brand, a landlord or an investor, or what the company
/// is called — and an organization can't be created without both. So rather
/// than guessing a default that someone would have to discover and undo
/// later, the account isn't created until this screen is filled in.
///
/// Only the fields the provider genuinely can't supply are asked for: no
/// password (there isn't one) and no email (already verified, shown but
/// fixed, since editing it here would let someone sign up as anyone).
class OAuthSignupScreen extends StatefulWidget {
  final OAuthNeedsSignup pending;
  final String providerLabel;

  const OAuthSignupScreen({
    super.key,
    required this.pending,
    required this.providerLabel,
  });

  @override
  State<OAuthSignupScreen> createState() => _OAuthSignupScreenState();
}

class _OAuthSignupScreenState extends State<OAuthSignupScreen> {
  late String _type = accountTypes.first.value;
  String? _discipline;
  late final _nameController = TextEditingController(text: widget.pending.name ?? '');
  final _orgController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  AccountTypeOption get _activeType => accountTypes.firstWhere((t) => t.value == _type);

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final org = _orgController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    if (org.isEmpty) {
      setState(() => _error = 'Enter your ${_activeType.orgLabel.toLowerCase()}.');
      return;
    }
    if (_type == 'vendor' && _discipline == null) {
      setState(() => _error = 'Choose what you do.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiClient.completeOauthSignup(
        pendingToken: widget.pending.pendingToken,
        type: _type,
        organizationName: org,
        name: name,
        discipline: _discipline,
      );
      Auth.signIn(result);
      if (!mounted) return;
      // AppRoot is already listening to Auth.session and has rebuilt the
      // signed-in shell underneath — same as the password paths.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err is ApiException ? err.message : 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Almost there',
      subtitle: 'Tell us what kind of account to set up.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.violet50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 18, color: AppColors.violet600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Signed in with ${widget.providerLabel} as ${widget.pending.email}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.violet700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('I am a…', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accountTypes.map((option) {
              final selected = option.value == _type;
              return ChoiceChip(
                label: Text(option.label),
                selected: selected,
                onSelected: (_) => setState(() {
                  _type = option.value;
                  if (_type != 'vendor') _discipline = null;
                }),
                showCheckmark: false,
                selectedColor: AppColors.violet600,
                backgroundColor: AppColors.white,
                labelStyle: TextStyle(
                  color: selected ? AppColors.white : AppColors.grey500,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: selected ? AppColors.violet600 : AppColors.grey200),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: authInput(icon: Icons.person_outline_rounded, hint: 'Your full name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _orgController,
            textCapitalization: TextCapitalization.words,
            decoration: authInput(
              icon: Icons.business_outlined,
              hint: _activeType.orgLabel,
            ),
          ),
          if (_type == 'vendor') ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _discipline,
              decoration: authInput(
                icon: Icons.build_outlined,
                hint: 'Choose your discipline…',
              ),
              items: vendorDisciplines.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _discipline = value),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Create my account'),
            ),
          ),
        ],
      ),
    );
  }
}
