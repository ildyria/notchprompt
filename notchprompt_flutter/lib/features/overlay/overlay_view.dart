import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../prompter/prompter_provider.dart';
import '../prompter/prompter_state.dart';
import '../settings/settings_provider.dart';
import 'controls_hud.dart';
import 'countdown_view.dart';
import 'notch_clipper.dart';
import 'scrolling_text_view.dart';

/// Root widget rendered inside the always-on-top overlay window.
///
/// Layer order (bottom → top):
///   1. Black HSL-full fill clipped to platform shape
///   2. Subtle top-edge border stroke
///   3. [ScrollingTextView] padded inside the visible area
///   4. [ControlsHud] pinned to bottom-center
///   5. [CountdownView] full-frame when counting down
class OverlayView extends ConsumerWidget {
  const OverlayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final prompter = ref.watch(prompterProvider);

    final w = settings.overlayWidth;
    final h = settings.overlayHeight;
    final clipper = overlayClipper();

    return SizedBox(
      width: w,
      height: h,
      child: ClipPath(
        clipper: clipper,
        child: Stack(
          children: [
            // ── 1. Background ────────────────────────────────────────────────
            const Positioned.fill(
              child: ColoredBox(color: Colors.black),
            ),

            // ── 2. Top stroke border (hidden at very top edge) ────────────────
            Positioned(
              top: kTopStrokeMaskHeight,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),

            // ── 3. Scrolling text ────────────────────────────────────────────
            Positioned(
              top: 58,
              left: 18,
              right: 18,
              bottom: 16,
              child: ScrollingTextView(
                text: settings.script,
                fontSize: settings.fontSize,
                speedPointsPerSecond: settings.speedPointsPerSecond,
                isRunning:
                    prompter.transportState == TransportState.running,
                hasStartedSession: prompter.hasStartedSession,
                resetToken: prompter.resetToken,
                jumpBackToken: prompter.jumpBackToken,
                jumpBackDistancePoints: prompter.jumpBackDistancePoints,
                fadeFraction: kEdgeFadeFraction,
              ),
            ),

            // ── 4. HUD controls ───────────────────────────────────────────────
            const Positioned.fill(
              child: ControlsHud(),
            ),

            // ── 5. Countdown overlay (shown conditionally inside widget) ──────
            const Positioned.fill(
              child: CountdownView(),
            ),
          ],
        ),
      ),
    );
  }
}
