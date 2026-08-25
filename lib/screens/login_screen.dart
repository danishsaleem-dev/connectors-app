import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';
import '../widgets/form_controls.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expand Smarter.\nGrow Faster.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 36),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.ink),
            decoration: authInputDecoration(icon: Icons.mail_outline_rounded, hintText: 'Email address'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: const TextStyle(color: AppColors.ink),
            decoration: authInputDecoration(
              icon: Icons.lock_outline_rounded,
              hintText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.grey300,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _keepSignedIn,
                  onChanged: (v) => setState(() => _keepSignedIn = v ?? true),
                  activeColor: AppColors.white,
                  checkColor: AppColors.violet700,
                  side: BorderSide(color: AppColors.white.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Keep me signed in',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                ),
                child: Text(
                  'Forgot password?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFFFF9E9E))),
          ],
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.white,
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('LOG IN'),
            ),
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
                      ?.copyWith(color: AppColors.white.withValues(alpha: 0.68)),
                  children: const [
                    TextSpan(text: "Don't have an account?  "),
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
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
