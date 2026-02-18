import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../prompter/prompter_provider.dart';
import '../prompter/prompter_state.dart';
import '../settings/settings_provider.dart';

/// Floating HUD with transport and speed controls.
///
/// Two capsule-shaped clusters:
///   Left  → [play/pause] [jump-back 5 s]
///   Right → [speed −]    [speed +]
///
/// Hidden while counting down.
class ControlsHud extends ConsumerStatefulWidget {
  const ControlsHud({super.key});

  @override
  ConsumerState<ControlsHud> createState() => _ControlsHudState();
}

class _ControlsHudState extends ConsumerState<ControlsHud> {
  // Timers for repeat-while-pressed on speed buttons.
  Timer? _repeatTimer;
  Timer? _initialDelayTimer;

  static const Duration _initialDelay = Duration(milliseconds: 280);
  static const Duration _repeatInterval = Duration(milliseconds: 85);
  static const double _buttonSize = 26;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _initialDelayTimer?.cancel();
    super.dispose();
  }

  // ─── Pointer handlers ────────────────────────────────────────────────────

  void _startRepeat(void Function() action) {
    action();
    _initialDelayTimer = Timer(_initialDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) => action());
    });
  }

  void _stopRepeat() {
    _initialDelayTimer?.cancel();
    _repeatTimer?.cancel();
    _initialDelayTimer = null;
    _repeatTimer = null;
  }

  void _speedDown() =>
      ref.read(settingsProvider.notifier).adjustSpeed(-kSpeedStep);

  void _speedUp() =>
      ref.read(settingsProvider.notifier).adjustSpeed(kSpeedStep);

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final transport = ref.watch(
      prompterProvider.select((s) => s.transportState),
    );

    if (transport == TransportState.countingDown) {
      return const SizedBox.shrink();
    }

    final isRunning = transport == TransportState.running;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Transport cluster ─────────────────────────────────────────
            _Capsule(
              children: [
                _HudButton(
                  size: _buttonSize,
                  icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  tooltip: isRunning ? 'Pause' : 'Play',
                  onTap: () =>
                      ref.read(prompterProvider.notifier).toggleRunning(),
                ),
                _HudButton(
                  size: _buttonSize,
                  icon: Icons.replay_5_rounded,
                  tooltip: 'Jump back 5 s',
                  onTap: () =>
                      ref.read(prompterProvider.notifier).jumpBack(),
                ),
              ],
            ),

            const SizedBox(width: 10),

            // ── Speed cluster ─────────────────────────────────────────────
            _Capsule(
              children: [
                _HoldButton(
                  size: _buttonSize,
                  icon: Icons.remove_rounded,
                  tooltip: 'Speed −',
                  onPressStart: () => _startRepeat(_speedDown),
                  onPressEnd: _stopRepeat,
                ),
                _HoldButton(
                  size: _buttonSize,
                  icon: Icons.add_rounded,
                  tooltip: 'Speed +',
                  onPressStart: () => _startRepeat(_speedUp),
                  onPressEnd: _stopRepeat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _Capsule extends StatelessWidget {
  const _Capsule({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// Tap-once button.
class _HudButton extends StatelessWidget {
  const _HudButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: size * 0.72),
        ),
      ),
    );
  }
}

/// Tap-and-hold repeat button.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.icon,
    required this.tooltip,
    required this.onPressStart,
    required this.onPressEnd,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: GestureDetector(
          onTapDown: (_) => onPressStart(),
          onTapUp: (_) => onPressEnd(),
          onTapCancel: onPressEnd,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.72),
          ),
        ),
      ),
    );
  }
}
