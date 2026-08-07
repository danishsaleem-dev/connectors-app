import 'package:flutter/material.dart';
import 'data/site_data.dart';
import 'screens/brands_screen.dart';
import 'screens/franchise_screen.dart';
import 'screens/home_screen.dart';
import 'screens/investors_screen.dart';
import 'screens/landlords_screen.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';

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
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.grey500),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined, color: AppColors.grey500),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Brands',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined, color: AppColors.grey500),
            selectedIcon: Icon(Icons.handshake_rounded),
            label: 'Franchise',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined, color: AppColors.grey500),
            selectedIcon: Icon(Icons.apartment_rounded),
            label: 'Landlords',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_rounded, color: AppColors.grey500),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Investors',
          ),
        ],
      ),
    );
  }
}
