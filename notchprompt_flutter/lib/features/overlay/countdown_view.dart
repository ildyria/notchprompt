import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prompter/prompter_provider.dart';
import '../prompter/prompter_state.dart';

/// Full-size overlay shown during the countdown phase.
///
/// Displays a large centred numeral counting down from N to 1.
/// Fades over the entire overlay area with a semi-opaque black fill so the
/// underlying scroll view is visible but receded.
class CountdownView extends ConsumerWidget {
  const CountdownView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prompterProvider);

    if (state.transportState != TransportState.countingDown) {
      return const SizedBox.shrink();
    }

    final remaining = state.countdownRemaining;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.72, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _CountdownFill(key: ValueKey<int>(remaining), remaining: remaining),
    );
  }
}

class _CountdownFill extends StatelessWidget {
  const _CountdownFill({required this.remaining, super.key});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.92),
      ),
      child: Center(
        child: Text(
          '$remaining',
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
