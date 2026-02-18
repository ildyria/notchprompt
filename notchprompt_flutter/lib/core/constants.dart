// ─── Speed ───────────────────────────────────────────────────────────────────

/// Default scroll speed in logical pixels per second.
const double kDefaultSpeed = 80;

/// Minimum allowed scroll speed.
const double kMinSpeed = 10;

/// Maximum allowed scroll speed.
const double kMaxSpeed = 300;

/// Increment applied by speed +/- controls and hotkeys.
const double kSpeedStep = 5;

/// Slow speed preset (pts/sec).
const double kSpeedPresetSlow = 55;

/// Normal speed preset (pts/sec).
const double kSpeedPresetNormal = 85;

/// Fast speed preset (pts/sec).
const double kSpeedPresetFast = 125;

// ─── Font ─────────────────────────────────────────────────────────────────────

/// Default font size in logical pixels.
const double kDefaultFontSize = 20;
const double kMinFontSize = 12;
const double kMaxFontSize = 40;

// ─── Overlay geometry ─────────────────────────────────────────────────────────

/// Default overlay width in logical pixels.
const double kDefaultOverlayWidth = 600;
const double kMinOverlayWidth = 400;
const double kMaxOverlayWidth = 1200;

/// Default overlay height in logical pixels.
const double kDefaultOverlayHeight = 150;
const double kMinOverlayHeight = 120;
const double kMaxOverlayHeight = 300;

// ─── Countdown ────────────────────────────────────────────────────────────────

/// Default countdown duration in seconds (0 = disabled).
const int kDefaultCountdownSeconds = 3;
const int kMinCountdownSeconds = 0;
const int kMaxCountdownSeconds = 10;

// ─── Scroll engine ────────────────────────────────────────────────────────────

/// Fraction of the viewport height that fades at top and bottom edges.
const double kEdgeFadeFraction = 0.20;

/// Jump-back duration in seconds (applied to current speed to get px distance).
const double kJumpBackSeconds = 5.0;

// ─── Persistence debounce ─────────────────────────────────────────────────────

/// Milliseconds to wait after last settings change before writing to disk.
const int kSaveDebounceMs = 250;

// ─── Visuals ─────────────────────────────────────────────────────────────────

/// Pure black used for notch-blending on macOS.
const int kNotchBlackARGB = 0xFF000000;

/// Notch shape: fraction of height at which straight side walls end.
const double kNotchSideWallDepthRatio = 0.82;

/// Notch shape: lower corner radius as fraction of height.
const double kNotchBottomCornerRadiusRatio = 0.18;

/// Rounded-bottom bar corner radius used on Linux / Windows.
const double kBarCornerRadius = 8.0;

/// Top stroke mask height — hides the border along the very top edge.
const double kTopStrokeMaskHeight = 2.0;

// ─── Default script ───────────────────────────────────────────────────────────

const String kDefaultScript = '''Paste your script here.

Tip: Use the menu bar icon to start/pause or reset the scroll.''';
