import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'reveal.dart';

/// One step in a [ProcessSteps] timeline.
class ProcessStep {
  final String title;
  final String body;

  const ProcessStep({required this.title, required this.body});
}

/// A numbered "how it works" timeline — a different rhythm from the app's
/// tile grids, used where a screen is explaining a sequence rather than
/// listing a set of peers.
class ProcessSteps extends StatelessWidget {
  final List<ProcessStep> steps;

  const ProcessSteps({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Reveal(
            index: i,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
                        child: Text(
                          '${i + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.white),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.4,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.grey200,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < steps.length - 1 ? AppSpacing.xl : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(steps[i].title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 3),
                          Text(
                            steps[i].body,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
