import 'package:flutter/material.dart';
import 'data/api_client.dart';
import 'data/auth_state.dart';
import 'data/session_storage.dart';
import 'data/site_data.dart';
import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/opportunities_screen.dart';
import 'screens/splash_screen.dart';
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
    // Held to a minimum so the splash reads as a deliberate brand moment
    // rather than a flash on the (common) fast path where there's no
    // stored token at all — while still actually waiting on the real
    // session check when that takes longer than the minimum.
    await Future.wait([
      _checkStoredSession(),
      Future.delayed(const Duration(milliseconds: 1400)),
    ]);
    if (mounted) setState(() => _checking = false);
  }

  // Wraps the whole thing, not just the network call: a platform storage
  // failure reading the token (rare, but flutter_secure_storage can throw —
  // e.g. a corrupted Android keystore after an OS update) would otherwise
  // leave _checking true forever, since nothing downstream would ever run
  // to flip it back. Any failure here should just mean "not signed in",
  // not a stuck splash screen.
  Future<void> _checkStoredSession() async {
    try {
      final token = await SessionStorage.readToken();
      if (token == null) return;
      final result = await ApiClient.checkSession(token);
      Auth.signIn(result);
    } catch (_) {
      try {
        await SessionStorage.clearToken();
      } catch (_) {
        // Clearing failed too — nothing more to do; worst case a bad token
        // is checked again (and fails the same way) on the next launch.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const SplashScreen();
    }
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) =>
          session == null ? const WelcomeScreen() : const AppShell(),
    );
  }
}

/// The signed-in app — 5 tabs per the business-logic doc's bottom-nav spec:
/// Home, Opportunities (a shared category-browsing hub now — see
/// OpportunitiesScreen — rather than the old per-type primary form),
/// Messages and Notifications (both UI-only placeholders, no backend yet),
/// and Profile. No app bar — nothing left to put in one once the logo and
/// the old Menu/Account icons moved into the tabs and Home's own profile
/// row.
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
    final orgType = Auth.session.value?.orgType;

    final navItems = [
      const NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      const NavItem(
        icon: Icons.travel_explore_outlined,
        activeIcon: Icons.travel_explore_rounded,
        label: 'Opportunities',
      ),
      NavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'Messages',
        badgeCount: unreadMessagesCount,
      ),
      NavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: 'Notifications',
        badgeCount: unreadNotificationsCount,
      ),
      const NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    final pages = [
      HomeScreen(onOpenProfile: () => _goTo(4)),
      OpportunitiesScreen(orgType: orgType),
      const MessagesBody(),
      const NotificationsBody(),
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
