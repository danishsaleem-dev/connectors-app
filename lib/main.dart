import 'package:flutter/material.dart';
import 'data/api_client.dart';
import 'data/auth_state.dart';
import 'data/message.dart';
import 'data/profile_fields.dart';
import 'data/session_storage.dart';
import 'data/site_data.dart';
import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/onboarding_screen.dart';
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

/// Decides Onboarding vs. Welcome vs. the signed-in app shell — the one
/// thing every launch has to settle before showing anything else. Checks
/// SessionStorage for a token, and if there is one, verifies it's still
/// good with the server (never trusts a stored token's mere presence,
/// since the account behind it could since have changed or been
/// deactivated) before signing in. Onboarding shows once, on the very
/// first launch, then never again regardless of sign-in state.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _checking = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    // Started together so the onboarding-seen read overlaps the session
    // check rather than adding to it, then all awaited below. The delay is
    // held to a minimum so the splash reads as a deliberate brand moment
    // rather than a flash on the (common) fast path where there's no
    // stored token at all — while still actually waiting on the real
    // session check when that takes longer than the minimum.
    final sessionCheck = _checkStoredSession();
    final onboardingSeen = SessionStorage.hasSeenOnboarding();
    final minDelay = Future.delayed(const Duration(milliseconds: 1400));
    await sessionCheck;
    final seen = await onboardingSeen;
    await minDelay;
    if (mounted) {
      setState(() {
        _checking = false;
        _showOnboarding = !seen;
      });
    }
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

  void _dismissOnboarding() {
    SessionStorage.markOnboardingSeen();
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const SplashScreen();
    }
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) {
        if (session != null) return const AppShell();
        if (_showOnboarding) {
          return OnboardingScreen(
            onGetStarted: _dismissOnboarding,
            onLogin: () {
              _dismissOnboarding();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          );
        }
        return const WelcomeScreen();
      },
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadMessages();
  }

  // Same fire-and-forget shape as _loadProfile — the nav badge just reads
  // 0 until this lands, no loading state needed for a number in a corner.
  Future<void> _loadMessages() async {
    if (Auth.session.value?.orgType == null) return;
    try {
      await MessagesStore.refresh();
      if (mounted) setState(() {});
    } catch (_) {
      // No connection — badge just stays at whatever it already was.
    }
  }

  // Fire-and-forget: Home renders immediately either way, and the
  // completion strip (a ValueListenableBuilder on ProfileDraft.values)
  // just updates in place once this lands. Runs once per signed-in
  // session — an admin has no organization/profile to load at all.
  Future<void> _loadProfile() async {
    if (Auth.session.value?.orgType == null) return;
    try {
      final data = await ApiClient.fetchProfile();
      final seeded = <String, Object>{};
      if (data.organizationName != null) seeded['organizationName'] = data.organizationName!;
      if (data.phone != null) seeded['phone'] = data.phone!;
      if (data.country != null) seeded['country'] = data.country!;
      for (final field in profileFieldsFor(data.orgType)) {
        final value = coerceProfileValue(field, data.profile[field.key]);
        if (value != null) seeded[field.key] = value;
      }
      ProfileDraft.seed(seeded);
      if (data.onboardingCompletedAt != null && Auth.session.value != null) {
        Auth.session.value = Auth.session.value!.copyWith(
          onboardingCompletedAt: data.onboardingCompletedAt,
        );
      }
    } catch (_) {
      // No connection, or nothing saved yet — the draft just stays empty,
      // same as before this existed.
    }
  }

  void _goTo(int index) {
    // Messages tab is index 2 — mark the thread read the moment someone
    // actually opens it, not at mount (every tab is mounted up front
    // inside the IndexedStack below, so initState alone would mark it
    // read before it was ever looked at). Notifications is just a
    // different view of the same admin messages (see MessagesStore's doc
    // comment), so this is also what clears the Notifications badge.
    if (index == 2) MessagesStore.markRead();
    setState(() => _index = index);
  }

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
        badgeCount: MessagesStore.unreadCount,
      ),
      NavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: 'Notifications',
        badgeCount: MessagesStore.unreadCount,
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
      NotificationsBody(onOpenMessages: () => _goTo(2)),
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
