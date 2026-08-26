import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import 'gradient_background.dart';
import 'orbit_field.dart';

/// Shared chrome for Login and Signup — the same layered gradient entrance
/// as Splash/Welcome, continued rather than dropped back to a plain white
/// AppBar screen once the visitor taps through. No background watermark
/// mark here (that read as clutter behind the form) — instead a proper,
/// prominent logo sits above the form, and the whole logo+form group is
/// vertically centered on the screen rather than pinned under a header.
class AuthShell extends StatelessWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  // Top padding clears the floating back button even when
                  // content is tall enough to need scrolling instead of
                  // centering.
                  padding: const EdgeInsets.fromLTRB(28, 72, 28, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 72,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 64,
                            height: 64,
                            child: OrbitField(color: AppColors.white, count: 20),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            SiteData.name.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 36),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Material(
                  color: AppColors.white.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
