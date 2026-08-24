import 'package:flutter/material.dart';
import 'data/account_type_config.dart';
import 'data/api_client.dart';
import 'data/auth_state.dart';
import 'data/session_storage.dart';
import 'data/site_data.dart';
import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/floating_nav_bar.dart';

void main() {
  runApp(const ConnectorsApp());
}

class ConnectorsApp extends StatelessWidget {
  const ConnectorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: SiteData.name,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppRoot(),
    );
  }
}

/// Decides Welcome vs. the signed-in app shell — the one thing every launch
/// has to settle before showing anything else. Checks SessionStorage for a
/// token, and if there is one, verifies it's still good with the server
/// (never trusts a stored token's mere presence, since the account behind
/// it could since have changed or been deactivated) before signing in.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await SessionStorage.readToken();
    if (token != null) {
      try {
        final result = await ApiClient.checkSession(token);
        Auth.signIn(result);
      } catch (_) {
        await SessionStorage.clearToken();
      }
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) =>
          session == null ? const WelcomeScreen() : const AppShell(),
    );
  }
}

/// The signed-in app — Home, the account type's one primary action, and
/// Account. Every account is exactly one type (AccountTypeConfig), so the
/// second tab is the only thing that actually varies between users; the
/// shape of the bar (3 tabs, this order) stays fixed. No app bar — nothing
/// left to put in one once the logo and the old Menu/Account icons moved
/// into the tabs and Home's own profile row.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final config = configFor(Auth.session.value?.orgType);

    final navItems = [
      const NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      NavItem(icon: config.tabIcon, activeIcon: config.tabActiveIcon, label: config.tabLabel),
      const NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Account',
      ),
    ];

    final pages = [
      const HomeScreen(),
      config.buildPrimaryScreen(),
      const AccountBody(),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: FloatingNavBar(
        items: navItems,
        selectedIndex: _index,
        onSelect: _goTo,
      ),
    );
  }
}
