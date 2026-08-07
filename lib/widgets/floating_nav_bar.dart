import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({required this.icon, required this.activeIcon, required this.label});
}

/// A floating, rounded nav bar inset from the screen edges with a sliding
/// pill indicator behind the active icon — reads as a considered, custom
/// piece of the app rather than Material's default flat NavigationBar.
class FloatingNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slotWidth = constraints.maxWidth / items.length;
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: slotWidth * selectedIndex + 6,
                  top: 8,
                  child: Container(
                    width: slotWidth - 12,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.violet50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      SizedBox(
                        width: slotWidth,
                        child: _NavButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: selected ? AppColors.violet600 : AppColors.grey300,
              size: 22,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: selected ? AppColors.violet600 : AppColors.grey300,
                    fontSize: 10.5,
                  ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
