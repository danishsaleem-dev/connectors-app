import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';
import 'phone_login_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  // Sessions are already persisted to secure storage on every sign-in —
  // this reflects that real behaviour rather than gating it; there's
  // nothing to wire up when it's unchecked (yet).
  bool _keepSignedIn = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiClient.login(email: email, password: password);
      Auth.signIn(result);
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
      title: 'Welcome back',
      subtitle: 'Sign in to pick up where you left off.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: authInput(icon: Icons.mail_outline_rounded, hint: 'Email address'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: authInput(
              icon: Icons.lock_outline_rounded,
              hint: 'Password',
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
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _keepSignedIn,
                  onChanged: (v) => setState(() => _keepSignedIn = v ?? true),
                  activeColor: AppColors.violet600,
                  side: const BorderSide(color: AppColors.grey300),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Keep me signed in',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const Spacer(),
              TextButton(
                onPressed: _soon,
                child: Text(
                  'Forgot password?',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.violet600),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
          const SizedBox(height: 18),
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
                  : const Text('Log in'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.grey200, width: 1.2),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
              ),
              icon: const Icon(Icons.smartphone_rounded, size: 19),
              label: const Text('Use mobile number'),
            ),
          ),
          const SizedBox(height: 26),
          AuthProviderRow(
            providers: [
              (icon: Icons.g_mobiledata_rounded, label: 'Google', onTap: _soon),
              (icon: Icons.apple_rounded, label: 'Apple', onTap: _soon),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              ),
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500),
                  children: const [
                    TextSpan(text: "Don't have an account?  "),
                    TextSpan(
                      text: 'Sign up',
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
