import 'package:flutter/material.dart';
import '../data/account_types.dart';
import '../data/api_client.dart';
import '../theme/colors.dart';
import '../widgets/auth_success_view.dart';
import '../widgets/form_controls.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _type = accountTypes.first.value;
  String? _discipline;
  final _orgController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  AuthResult? _result;

  @override
  void dispose() {
    _orgController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AccountTypeOption get _activeType => accountTypes.firstWhere((t) => t.value == _type);

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
      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = result;
      });
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
    if (_result != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account created')),
        body: AuthSuccessView(result: _result!, title: "You're in, ${_result!.name}."),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join the network.', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Brands, franchisees, landlords, investors and vendors all '
                'start here. Takes about a minute.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 24),
              const FieldLabel('I am a…'),
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
                        color: selected ? AppColors.violet50 : AppColors.white,
                        border: Border.all(color: selected ? AppColors.violet600 : AppColors.grey200),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: selected ? AppColors.violet600 : AppColors.ink,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              FieldLabel(_activeType.orgLabel),
              TextField(controller: _orgController, decoration: formInputDecoration()),
              if (_type == 'vendor') ...[
                const SizedBox(height: 16),
                const FieldLabel('What do you do?'),
                DropdownButtonFormField<String>(
                  initialValue: _discipline,
                  decoration: formInputDecoration(hintText: 'Choose your discipline…'),
                  items: vendorDisciplines.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _discipline = value),
                ),
              ],
              const SizedBox(height: 16),
              const FieldLabel('Your name'),
              TextField(controller: _nameController, decoration: formInputDecoration()),
              const SizedBox(height: 16),
              const FieldLabel('Email'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: formInputDecoration(),
              ),
              const SizedBox(height: 16),
              FieldLabel('Password'),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: formInputDecoration(hintText: 'At least 8 characters').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ],
              const SizedBox(height: 24),
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
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
