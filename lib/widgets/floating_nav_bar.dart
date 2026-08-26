import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// 0 (the default) shows no badge. A count > 0 shows a small red dot —
  /// or the number itself, once it's more than a glance can convey.
  final int badgeCount;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
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
    // Icon only, no label underneath — the label still exists as a
    // semantics announcement so screen readers get it even though sighted
    // users don't see it.
    return Semantics(
      label: item.badgeCount > 0 ? '${item.label}, ${item.badgeCount} unread' : item.label,
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  color: selected ? AppColors.violet600 : AppColors.grey300,
                  size: 24,
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: _Badge(count: item.badgeCount),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    // A plain dot up to a couple of unread items; beyond that a glance at
    // a dot doesn't tell you much, so switch to a number.
    if (count <= 2) {
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: const Color(0xFFE5484D),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 1.5),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE5484D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
