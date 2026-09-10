import 'package:flutter/material.dart';
import '../data/onboarding_data.dart';
import '../theme/colors.dart';
import '../widgets/gradient_background.dart';
import '../widgets/orbit_field.dart';

/// The doc's four welcome screens, as a swipeable carousel.
///
/// Deliberately **not** auto-advancing on a timer. Onboarding is read, not
/// watched — a slide that moves on its own either rushes someone still
/// reading it or makes them fight the animation to go back. Swipe (or
/// Next) puts the pace with the reader; Skip is always available for
/// anyone who doesn't want it at all. The dots double as a progress
/// indicator so the end is visible from the first slide.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const OnboardingScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == onboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onGetStarted();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base fallback (also what briefly shows while a photo is still
          // loading) — the same gradient this screen always had, so a slow
          // connection never means a blank or black screen.
          const LightGradientBackground(child: SizedBox.expand()),
          // Crossfades to the current slide's own photo rather than
          // swapping instantly, so paging feels considered rather than a
          // hard cut. AnimatedSwitcher's own internal Stack gives its
          // child loose constraints (sized to content, centered) rather
          // than the screen's — which is why BoxFit.cover had nothing to
          // actually cover before this; SizedBox.expand forces full-bleed
          // regardless.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: SizedBox.expand(
                key: ValueKey(_page),
                child: Image.network(
                  onboardingPhotoUrl(onboardingSlides[_page].backgroundPhotoId),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.expand(),
                ),
              ),
            ),
          ),
          // A light wash over the photo — enough of it shows through to
          // read as themed, deliberate imagery, while every heading/body
          // text color on this screen (all dark-on-light) stays exactly as
          // legible as it was against the plain gradient.
          IgnorePointer(
            child: Container(color: AppColors.white.withValues(alpha: 0.82)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                    child: TextButton(
                      onPressed: widget.onGetStarted,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: onboardingSlides.length,
                    itemBuilder: (context, i) =>
                        _Slide(slide: onboardingSlides[i]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < onboardingSlides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.violet600
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          child: Text(_isLast ? 'Get Started' : 'Next'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: widget.onLogin,
                        child: Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.grey500),
                            children: const [
                              TextSpan(text: 'Already have an account?  '),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: AppColors.violet600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final OnboardingSlide slide;

  const _Slide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The brand mark as the backdrop for every slide — keeps
                // the four screens visually one family without needing
                // four bespoke illustrations we don't have.
                OrbitField(
                  color: AppColors.violet600.withValues(alpha: 0.16),
                  count: 20,
                  duration: const Duration(seconds: 40),
                ),
                Container(
                  width: 104,
                  height: 104,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.violet700, AppColors.violet600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(slide.icon, color: AppColors.white, size: 44),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
          Text(
            slide.heading,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
