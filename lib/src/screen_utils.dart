// lib/ruki_utils.dart
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';

/// Responsive utilities for sizing, typography, spacing and platform checks.
///
/// Key improvements vs. the original:
/// - No `dart:io` import => web-safe (uses `defaultTargetPlatform` + `kIsWeb`).
/// - Optional configuration of baseline and multipliers via `configure(...)`.
/// - Gentler scaling (no ceil jitter).
/// - Safe-area helpers and percentage sizing.
/// - Tablet detection tweak and refresh when orientation/dimensions change (opt-in).
class ScreenUtils with WidgetsBindingObserver {
  static final ScreenUtils instance = ScreenUtils._internal();

  // ---- Runtime state ---------------------------------------------------------
  late double width;
  late double height;
  late double _baseWidth;
  late double _baseHeight;

  /// Average of width/baseWidth and height/baseHeight
  late double _avgBase;

  /// Global scale factor derived from dimensions and multipliers
  late double scaleFactor;

  /// Heuristic tablet flag
  late bool isTablet;

  /// Optional multipliers (tuned for your design language)
  double fontMultiplierPhone;
  double fontMultiplierTablet;
  double iconMultiplierPhone;
  double iconMultiplierTablet;
  double alignmentTabletBias; // 0..1 (drifts alignments toward center on tablets)

  bool _listeningForMetrics = false;

  // ---- Defaults --------------------------------------------------------------
  static const double _defaultGuidelineBaseWidth = 360.0;
  static const double _defaultGuidelineBaseHeight = 640.0;

  ScreenUtils._internal({
    // ignore: unused_element_parameter
    this.fontMultiplierPhone = 1.0,
    // ignore: unused_element_parameter
    this.fontMultiplierTablet = 0.9,
    // ignore: unused_element_parameter
    this.iconMultiplierPhone = 1.0,
    // ignore: unused_element_parameter
    this.iconMultiplierTablet = 1.1,
    // ignore: unused_element_parameter
    this.alignmentTabletBias = 0.85,
  }) {
    _baseWidth = _defaultGuidelineBaseWidth;
    _baseHeight = _defaultGuidelineBaseHeight;
    _recomputeFromCurrentView();
  }

  // ---- Public configuration --------------------------------------------------

  /// Configure baselines and optional multipliers (call early, e.g. in `main`).
  ///
  /// You can call this more than once; it will recompute factors immediately.
  static void configure({
    double? baseWidth,
    double? baseHeight,
    double? fontMultiplierPhone,
    double? fontMultiplierTablet,
    double? iconMultiplierPhone,
    double? iconMultiplierTablet,
    double? alignmentTabletBias,
    bool listenForMetrics = false,
  }) {
    final s = ScreenUtils.instance;
    if (baseWidth != null) s._baseWidth = baseWidth;
    if (baseHeight != null) s._baseHeight = baseHeight;
    if (fontMultiplierPhone != null) s.fontMultiplierPhone = fontMultiplierPhone;
    if (fontMultiplierTablet != null) s.fontMultiplierTablet = fontMultiplierTablet;
    if (iconMultiplierPhone != null) s.iconMultiplierPhone = iconMultiplierPhone;
    if (iconMultiplierTablet != null) s.iconMultiplierTablet = iconMultiplierTablet;
    if (alignmentTabletBias != null) s.alignmentTabletBias = alignmentTabletBias.clamp(0.0, 1.0);

    s._recomputeFromCurrentView();

    if (listenForMetrics && !s._listeningForMetrics) {
      WidgetsBinding.instance.addObserver(s);
      s._listeningForMetrics = true;
    } else if (!listenForMetrics && s._listeningForMetrics) {
      WidgetsBinding.instance.removeObserver(s);
      s._listeningForMetrics = false;
    }
  }

  /// Recompute with a specific BuildContext (useful after orientation changes).
  void refresh(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _assignSize(size);
  }

  // ---- WidgetsBindingObserver (optional live updates) ------------------------
  @override
  void didChangeMetrics() {
    // Re-read from the active view when metrics change (rotation, resize, etc.)
    _recomputeFromCurrentView();
  }

  // ---- Core math -------------------------------------------------------------

  void _recomputeFromCurrentView() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    final size = views.isNotEmpty
        ? views.first.physicalSize / views.first.devicePixelRatio
        : const Size(_defaultGuidelineBaseWidth, _defaultGuidelineBaseHeight);
    _assignSize(size);
  }

  void _assignSize(Size size) {
    // Normalize so width is the smaller edge (portrait logic for baselines)
    width = min(size.width, size.height);
    height = max(size.width, size.height);

    final baseW = width / _baseWidth;
    final baseH = height / _baseHeight;
    _avgBase = (baseW + baseH) / 2.0;

    isTablet = _detectTablet(_avgBase, width);

    // Gentler factor:
    // Use the average directly, then slightly deflate on tablets to avoid oversizing text.
    final deviceFactor = _avgBase * (isTablet ? 0.95 : 1.0);

    scaleFactor = deviceFactor;
  }

  bool _detectTablet(double avgBase, double logicalWidth) {
    // Keeps your original intent but smooths the threshold a bit
    return avgBase > 1.2 || logicalWidth >= 600.0;
  }

  // ---- Public scalars --------------------------------------------------------

  /// General scalar
  double scale(double value) => value * scaleFactor;

  /// Fonts
  double font(double value) => scale(value * (isTablet ? fontMultiplierTablet : fontMultiplierPhone));

  /// Icons
  double icon(double value) => scale(value * (isTablet ? iconMultiplierTablet : iconMultiplierPhone));

  /// Offsets (e.g., animated positions)
  Offset offset(double dx, double dy) => Offset(scale(dx), scale(dy));

  /// Alignment regulation (makes -1..1 drift toward center a bit on tablets)
  Alignment alignment(double x, double y) {
    final f = isTablet ? alignmentTabletBias : 1.0;
    return Alignment(x * f, y * f);
  }

  /// Scaled padding/insets
  EdgeInsets padding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.fromLTRB(scale(left), scale(top), scale(right), scale(bottom));

  // ---- Percent helpers -------------------------------------------------------

  /// width * [pct] where pct in 0..1
  double wPct(double pct) => width * pct.clamp(0.0, 1.0);

  /// height * [pct] where pct in 0..1
  double hPct(double pct) => height * pct.clamp(0.0, 1.0);

  // ---- Safe-area helpers -----------------------------------------------------

  EdgeInsets viewPaddingOf(BuildContext context) => MediaQuery.viewPaddingOf(context);
  EdgeInsets viewInsetsOf(BuildContext context) => MediaQuery.viewInsetsOf(context);

  // ---- Platform helpers (web-safe) ------------------------------------------

  bool get isWeb => kIsWeb;
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get isTV {
    // Flutter doesn't expose TV explicitly; adapt if you target Apple TV/Android TV.
    return false;
  }

  bool get isPad => isIos && isTablet;
}

// ---- Top-level convenience getters (kept for compatibility) ------------------

bool get isAndroid => ScreenUtils.instance.isAndroid;
bool get isIos => ScreenUtils.instance.isIos;
bool get isWeb => ScreenUtils.instance.isWeb;
bool get isTV => ScreenUtils.instance.isTV;
bool get isPad => ScreenUtils.instance.isPad;

bool get isTablet => ScreenUtils.instance.isTablet;

double get kDeviceHeight => ScreenUtils.instance.height;
double get kDeviceWidth => ScreenUtils.instance.width;

// ---- Extensions --------------------------------------------------------------

extension ScreenNumExtensions on num {
  double get responsive => ScreenUtils.instance.scale(toDouble());
  double get responsiveFont => ScreenUtils.instance.font(toDouble());
  double get responsiveIcon => ScreenUtils.instance.icon(toDouble());

  /// Percentage-of-width (0..1) => logical pixels
  double get vw => ScreenUtils.instance.wPct(toDouble());
  /// Percentage-of-height (0..1) => logical pixels
  double get vh => ScreenUtils.instance.hPct(toDouble());
}

extension ScreenOffsetExtensions on Offset {
  Offset get responsive => ScreenUtils.instance.offset(dx, dy);
}

extension ScreenEdgeInsetsExtensions on EdgeInsets {
  EdgeInsets get responsive => ScreenUtils.instance.padding(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
}

extension ScreenAlignmentExtensions on Alignment {
  Alignment get responsive => ScreenUtils.instance.alignment(x, y);
}