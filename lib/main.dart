import 'package:flutter/material.dart';
import 'data/api_client.dart';
import 'data/auth_state.dart';
import 'data/site_data.dart';
import 'screens/account_screen.dart';
import 'screens/brands_screen.dart';
import 'screens/franchise_screen.dart';
import 'screens/home_screen.dart';
import 'screens/investors_screen.dart';
import 'screens/landlords_screen.dart';
import 'screens/login_screen.dart';
import 'screens/more_screen.dart';
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
      home: const AppShell(),
    );
  }
}

const _navItems = [
  NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
  NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'Brands'),
  NavItem(icon: Icons.handshake_outlined, activeIcon: Icons.handshake_rounded, label: 'Franchise'),
  NavItem(icon: Icons.apartment_outlined, activeIcon: Icons.apartment_rounded, label: 'Landlords'),
  NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up_rounded, label: 'Investors'),
];

/// Bottom-nav shell holding the five public screens this first phase ships.
/// IndexedStack (not a route push per tab) keeps each screen's scroll
/// position when switching tabs, same as a native tab bar would.
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
    final pages = [
      HomeScreen(onSelectAudience: _goTo),
      const BrandsScreen(),
      const FranchiseScreen(),
      const LandlordsScreen(),
      const InvestorsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        // The one place the logo appears — natural colours against the app
        // bar's white background, not repeated on every screen's gradient
        // banner underneath.
        title: Image.asset(
          'assets/images/logo.png',
          height: 30,
          fit: BoxFit.contain,
          semanticLabel: '${SiteData.name} — ${SiteData.tagline}',
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoreScreen()),
            ),
          ),
          // Signed in, this is the account screen rather than a login form —
          // there's nothing to log into twice.
          ValueListenableBuilder<AuthResult?>(
            valueListenable: Auth.session,
            builder: (context, session, _) => IconButton(
              icon: Icon(
                session == null ? Icons.person_outline_rounded : Icons.person_rounded,
              ),
              tooltip: session == null ? 'Sign in' : 'Account',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      session == null ? const LoginScreen() : AccountScreen(session: session),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: FloatingNavBar(
        items: _navItems,
        selectedIndex: _index,
        onSelect: _goTo,
      ),
    );
  }
}
