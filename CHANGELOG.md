# Changelog
All notable changes to **ruki_utils** will be documented in this file.

## [0.1.0] - 2025-11-05
### Added
- `ScreenUtils` singleton with responsive scaling for sizes, fonts, icons, paddings, offsets, and alignments.
- Web-safe platform checks using `kIsWeb` + `defaultTargetPlatform` (no `dart:io`).
- `ScreenUtils.configure(...)` to set baseline, multipliers, and optional live metric listening.
- Percentage helpers: `num.vw` (width %) and `num.vh` (height %).
- Safe-area helpers: `viewPaddingOf(context)`, `viewInsetsOf(context)`.
- Tablet detection heuristic and alignment bias control (`alignmentTabletBias`).
- Extensions for `num`, `EdgeInsets`, `Alignment`, and `Offset`.
- Example app under `example/` showcasing usage.
- Test suite (`test/screen_utils_test.dart`) covering scaling math, tablet detection, percent helpers, alignment bias, EdgeInsets/Offset scaling, and safe-area helpers.
- Documentation: comprehensive `README.md`.
- License: `MIT`.

### Changed
- Smoother scaling (removed `ceilToDouble()` to avoid animation/layout jitter).

### Fixed
- Safer fallbacks when no view is available; recomputation hooks for metric changes.