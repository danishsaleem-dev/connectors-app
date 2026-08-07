import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../theme/colors.dart';

/// The "how we work with you" numbered card list — sequential within the
/// filtered subset shown, same reasoning as AudienceDivisions.tsx on the
/// site (a global 02/06/07 reads as broken once only a few divisions apply).
class DivisionGrid extends StatelessWidget {
  final List<Division> divisions;

  const DivisionGrid({super.key, required this.divisions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < divisions.length; i++) ...[
          if (i > 0) const SizedBox(height: 1),
          _DivisionCard(division: divisions[i], number: i + 1),
        ],
      ],
    );
  }
}

class _DivisionCard extends StatelessWidget {
  final Division division;
  final int number;

  const _DivisionCard({required this.division, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number.toString().padLeft(2, '0'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.violet600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(division.navLabel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            division.short,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
