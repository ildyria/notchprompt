import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


/// Ticker-driven scrolling text view.
///
/// Driven at the native display refresh rate via [Ticker].
/// Reacts to [resetToken] and [jumpBackToken] string changes rather than
/// re-parenting, keeping animation inside the widget layer.
class ScrollingTextView extends StatefulWidget {
  const ScrollingTextView({
    required this.text,
    required this.fontSize,
    required this.speedPointsPerSecond,
    required this.isRunning,
    required this.hasStartedSession,
    required this.resetToken,
    required this.jumpBackToken,
    required this.jumpBackDistancePoints,
    required this.fadeFraction,
    super.key,
  });

  final String text;
  final double fontSize;
  final double speedPointsPerSecond;
  final bool isRunning;
  final bool hasStartedSession;
  final String resetToken;
  final String jumpBackToken;
  final double jumpBackDistancePoints;

  /// Fraction of viewport height to fade at top and bottom edges.
  final double fadeFraction;

  @override
  State<ScrollingTextView> createState() => _ScrollingTextViewState();
}

class _ScrollingTextViewState extends State<ScrollingTextView>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _offset = 0;
  Duration _lastElapsed = Duration.zero;

  // Cached token values to detect changes without rebuilding.
  String _lastResetToken = '';
  String _lastJumpToken = '';

  // Content height measured by the inner layout.
  double _contentHeight = 0;
  static const double _loopGap = 24;

  @override
  void initState() {
    super.initState();
    _lastResetToken = widget.resetToken;
    _lastJumpToken = widget.jumpBackToken;

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(ScrollingTextView old) {
    super.didUpdateWidget(old);

    // Reset token fired — jump to top.
    if (widget.resetToken != _lastResetToken) {
      _lastResetToken = widget.resetToken;
      _offset = 0;
      _lastElapsed = Duration.zero;
    }

    // Jump-back token fired — subtract distance, clamp to 0.
    if (widget.jumpBackToken != _lastJumpToken) {
      _lastJumpToken = widget.jumpBackToken;
      _offset = (_offset - widget.jumpBackDistancePoints).clamp(0, double.infinity);
    }

    // Pause / idle: reset elapsed baseline so we don't jump on resume.
    if (!widget.isRunning && old.isRunning) {
      _lastElapsed = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (!widget.isRunning) {
      _lastElapsed = elapsed;
      return;
    }

    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    final delta = widget.speedPointsPerSecond * dt;
    final cycleLength = (_contentHeight + _loopGap).clamp(1, double.infinity);

    setState(() {
      _offset = (_offset + delta) % cycleLength;
    });
  }

  bool get _hasContent =>
      widget.text.trim().isNotEmpty;

  double get _clampedFade =>
      widget.fadeFraction.clamp(0.0, 0.49);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: Stack(
            children: [
              // ── Scrolling content ───────────────────────────────────────
              if (_hasContent && widget.hasStartedSession)
                _buildScrollingCopies(constraints)
              else
                _buildStaticPlaceholder(),

              // ── Edge fade gradient ──────────────────────────────────────
              if (_clampedFade > 0) _buildFadeMask(constraints),
            ],
          ),
        );
      },
    );
  }

  /// Renders enough repeated copies of the text to fill the viewport
  /// continuously, loop-scrolling indefinitely.
  Widget _buildScrollingCopies(BoxConstraints constraints) {
    final cycleLength =
        (_contentHeight + _loopGap).clamp(1.0, double.infinity);
    final copies =
        (constraints.maxHeight / cycleLength).ceil() + 2;

    // Effective upward offset (text scrolls up = offset increases).
    final dy = -(_offset % cycleLength);

    return Transform.translate(
      offset: Offset(0, dy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          copies,
          (i) => Padding(
            padding: EdgeInsets.only(
              bottom: i < copies - 1 ? _loopGap : 0,
            ),
            child: _buildTextBlock(),
          ),
        ),
      ),
    );
  }

  Widget _buildTextBlock() {
    return MeasureSize(
      onChange: (size) {
        if (size.height != _contentHeight) {
          _contentHeight = size.height;
        }
      },
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.white,
          height: 1.55,
          letterSpacing: 0.2,
        ),
        softWrap: true,
      ),
    );
  }

  Widget _buildStaticPlaceholder() {
    final message = _hasContent
        ? 'Ready to prompt.\nPress Start to begin.'
        : 'No script yet.\nOpen Settings and paste your script.';
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: (widget.fontSize * 0.72).clamp(12, 20),
          color: Colors.white54,
          height: 1.5,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFadeMask(BoxConstraints constraints) {
    final fadeH = (constraints.maxHeight * _clampedFade).clamp(
      0,
      constraints.maxHeight / 2,
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0,
                fadeH / constraints.maxHeight,
                1 - (fadeH / constraints.maxHeight),
                1,
              ],
              colors: const [
                Color(0xFF000000),
                Color(0x00000000),
                Color(0x00000000),
                Color(0xFF000000),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MeasureSize helper ───────────────────────────────────────────────────────

/// Calls [onChange] whenever the child's rendered size changes.
class MeasureSize extends StatefulWidget {
  const MeasureSize({
    required this.onChange,
    required this.child,
    super.key,
  });

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final _key = GlobalKey();
  Size _last = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure([_]) {
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    if (size != _last) {
      _last = size;
      widget.onChange(size);
      WidgetsBinding.instance.addPostFrameCallback(_measure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
