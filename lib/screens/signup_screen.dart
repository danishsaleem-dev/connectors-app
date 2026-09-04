import 'package:flutter/material.dart';
import '../data/account_types.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../data/oauth_flow.dart';
import '../data/oauth_service.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';
import 'login_screen.dart';

/// Signup, carrying the doc's field list: Full Name, Company Name, Email,
/// Phone Number, Country, Password. Phone and Country are new here and are
/// collected but not yet sent — the register endpoint doesn't accept them,
/// so they're held for the profile-completion step rather than silently
/// dropped into a request that would reject them.
class SignupScreen extends StatefulWidget {
  /// Preselects the "I am a…" chip — used by screens like Consultants and
  /// Partners that already know which account type their CTA should land on,
  /// so the visitor doesn't have to hunt for it among seven options.
  final String? initialType;

  const SignupScreen({super.key, this.initialType});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String _type = widget.initialType ?? accountTypes.first.value;
  String? _discipline;
  final _orgController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _country;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const _countries = [
    'United Kingdom',
    'United States',
    'Pakistan',
    'United Arab Emirates',
    'Other',
  ];

  @override
  void dispose() {
    _orgController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AccountTypeOption get _activeType => accountTypes.firstWhere((t) => t.value == _type);

  /// Signing up with a provider is the same call as signing in with one —
  /// the server decides which it is by whether the verified email already
  /// has an account, so there's no separate "register with Google" path.
  void _oauth(String provider) => startOAuthSignIn(
        context,
        provider: provider,
        setBusy: (busy) {
          if (mounted) setState(() => _loading = busy);
        },
      );

  Future<void> _submit() async {
    if (_orgController.text.trim().length < 2) {
      setState(() => _error = 'Enter your company or organization name.');
      return;
    }
    if (_nameController.text.trim().length < 2) {
      setState(() => _error = 'Enter your name.');
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
      final result = await ApiClient.register(
        type: _type,
        organizationName: _orgController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        discipline: _discipline,
      );
      Auth.signIn(result);
      // The register endpoint doesn't take phone/country itself (see this
      // file's own doc comment) — sent on afterward instead, best-effort,
      // so a save failure here doesn't block getting into the app that was
      // just successfully created.
      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty || _country != null) {
        ApiClient.saveProfile(
          phone: phone.isEmpty ? null : phone,
          country: _country,
        ).catchError((_) {});
      }
      if (!mounted) return;
      // AppRoot is listening to Auth.session and has already rebuilt to
      // the signed-in app shell underneath this screen — popping back to
      // it is all that's left to do.
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
      title: 'Create your account',
      subtitle: 'A minute to set up. You can finish your profile after.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I AM A…',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.grey500, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accountTypes.map((option) {
              final selected = option.value == _type;
              return InkWell(
                onTap: () => setState(() {
                  _type = option.value;
                  if (_type != 'vendor') _discipline = null;
                }),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.violet600 : AppColors.grey50,
                    border: Border.all(
                      color: selected ? AppColors.violet600 : AppColors.grey200,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected ? AppColors.white : AppColors.ink,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: authInput(icon: Icons.person_outline_rounded, hint: 'Full name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _orgController,
            decoration: authInput(icon: Icons.apartment_rounded, hint: _activeType.orgLabel),
          ),
          if (_type == 'vendor') ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _discipline,
              decoration: authInput(icon: Icons.build_outlined, hint: 'Choose your discipline…'),
              items: vendorDisciplines.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _discipline = value),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: authInput(icon: Icons.mail_outline_rounded, hint: 'Email address'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: authInput(icon: Icons.smartphone_rounded, hint: 'Phone number'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _country,
            decoration: authInput(icon: Icons.public_rounded, hint: 'Country'),
            items: _countries
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _country = value),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: authInput(
              icon: Icons.lock_outline_rounded,
              hint: 'Password (min. 8 characters)',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.grey300,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
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
                  : const Text('Create account'),
            ),
          ),
          const SizedBox(height: 26),
          AuthProviderRow(
            providers: [
              if (OAuthService.googleConfigured)
                (
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Google',
                  onTap: () => _oauth('google'),
                ),
              if (OAuthService.appleAvailable)
                (
                  icon: Icons.apple_rounded,
                  label: 'Apple',
                  onTap: () => _oauth('apple'),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500),
                  children: const [
                    TextSpan(text: 'Already have an account?  '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(color: AppColors.violet600, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
