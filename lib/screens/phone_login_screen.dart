import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';
import 'otp_screen.dart';

/// "Mobile Number Login" from the doc's login options.
///
/// UI only — there's no SMS provider and no phone-auth endpoint, so
/// Continue goes straight to the OTP screen without a code ever being
/// sent. The country list is a short real-world set covering the three
/// markets Connectors actually operates in, not an invented one.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phone = TextEditingController();
  _Dial _dial = _dialCodes.first;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _continue() {
    if (_phone.text.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(destination: '${_dial.code} ${_phone.text.trim()}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Enter your mobile',
      subtitle: "We'll text you a code to confirm it's you.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CountryPicker(
                value: _dial,
                onChanged: (d) => setState(() => _dial = d),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _continue(),
                  decoration: authInput(
                    icon: Icons.smartphone_rounded,
                    hint: 'Mobile number',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _phone.text.trim().isEmpty ? null : _continue,
              child: const Text('Send code'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Standard message rates may apply.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }
}

class _Dial {
  final String flag;
  final String code;
  final String country;

  const _Dial(this.flag, this.code, this.country);
}

const _dialCodes = [
  _Dial('🇬🇧', '+44', 'United Kingdom'),
  _Dial('🇺🇸', '+1', 'United States'),
  _Dial('🇵🇰', '+92', 'Pakistan'),
  _Dial('🇦🇪', '+971', 'United Arab Emirates'),
];

class _CountryPicker extends StatelessWidget {
  final _Dial value;
  final ValueChanged<_Dial> onChanged;

  const _CountryPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Country', style: Theme.of(sheetContext).textTheme.titleLarge),
                ),
              ),
              for (final dial in _dialCodes)
                ListTile(
                  leading: Text(dial.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(dial.country),
                  trailing: Text(
                    dial.code,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.grey500),
                  ),
                  onTap: () {
                    onChanged(dial);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Text(value.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(value.code, style: Theme.of(context).textTheme.bodyLarge),
            const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}
