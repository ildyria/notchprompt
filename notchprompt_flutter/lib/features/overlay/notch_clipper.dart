import 'package:flutter/widgets.dart';

import '../../core/constants.dart';
import '../../core/platform.dart';

/// Returns the correct overlay clipper for the current platform.
///
/// macOS → [NotchClipper] (Apple notch geometry)
/// Others → [RoundedBottomClipper] (simple rounded-bottom bar)
CustomClipper<Path> overlayClipper() =>
    hasNotch ? const NotchClipper() : const RoundedBottomClipper();

// ─── macOS Notch Shape ────────────────────────────────────────────────────────

/// Replicates the Apple MacBook notch contour:
/// - flat top edge, square top corners
/// - straight side walls for [kNotchSideWallDepthRatio] of the height
/// - rounded lower corners with radius [kNotchBottomCornerRadiusRatio] × height
class NotchClipper extends CustomClipper<Path> {
  const NotchClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final depthRatio = kNotchSideWallDepthRatio.clamp(0.60, 0.95);
    final lowerArcStartY = h * depthRatio;
    final maxFromDepth = h - lowerArcStartY;
    final maxFromWidth = w * 0.5;
    final target = h * kNotchBottomCornerRadiusRatio;
    final r = target.clamp(0.0, maxFromDepth.clamp(0.0, maxFromWidth));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - r)
      ..arcToPoint(
        Offset(w - r, h),
        radius: Radius.circular(r),
      )
      ..lineTo(r, h)
      ..arcToPoint(
        Offset(0, h - r),
        radius: Radius.circular(r),
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(NotchClipper old) => false;
}

// ─── Linux / Windows rounded-bottom bar ──────────────────────────────────────

/// Simple top-anchored floating bar with rounded lower corners.
class RoundedBottomClipper extends CustomClipper<Path> {
  const RoundedBottomClipper({this.radius = kBarCornerRadius});

  final double radius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius.clamp(0.0, (w / 2).clamp(0.0, h / 2));

    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..close();
  }

  @override
  bool shouldReclip(RoundedBottomClipper old) => old.radius != radius;
}
