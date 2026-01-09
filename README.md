

# ruki_utils

Responsive sizing + platform-aware helpers for Flutter.  
Scale widgets, text, icons, paddings, and alignments consistently across phones, tablets, and web — with a tiny API and zero boilerplate.

<p align="left">
  <a href="https://github.com/RookiePlayers/ruki_utils/actions"><img alt="CI" src="https://img.shields.io/badge/CI-GitHub_Actions-informational.svg"></a>
  <a href="https://opensource.org/licenses/MIT"><img alt="License" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-%E2%9D%A4-02569B.svg">
</p>

---

## Features

- 📐 **Responsive scale** for any numeric value: sizes, radii, spacing.
- 🔤 **Typography & icons** scale with device size (tablet-aware multipliers).
- 🧭 **Platform helpers**: `isWeb`, `isAndroid`, `isIos`, `isTablet`, `isPad`.
- 📏 **Percent helpers**: `0.6.vw`, `0.2.vh` (width/height percentages).
- 🧱 **EdgeInsets / Alignment / Offset** responsive extensions.
- 🧰 **Configurable baseline** & multipliers via `ScreenUtils.configure(...)`.
- 🔄 **Live updates** (optional) on rotation/resize.
- 🎨 **Color helpers**: shade/tint, contrast text, and hex utilities.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ruki_utils: ^1.0.0
```

Then:

```bash
flutter pub get
```

---

## Quick start

Call `configure(...)` early (optional), then use the extensions anywhere.

```dart
import 'package:flutter/material.dart';
import 'package:ruki_utils/ruki_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: tune baselines & behavior for your design system.
  ScreenUtils.configure(
    baseWidth: 375,  // e.g. iPhone X
    baseHeight: 812,
    listenForMetrics: true, // auto-refresh on rotation / window resize
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 0.6.vw,              // 60% of logical screen width
            height: 48.responsive,      // scaled height
            alignment: Alignment.center.responsive,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12.responsive),
            ),
            child: Text(
              'Responsive!',
              style: TextStyle(fontSize: 16.responsiveFont),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                .responsive,
            decoration: BoxDecoration(
              color: Colors.teal.withTint(0.2),
              borderRadius: BorderRadius.circular(8.responsive),
            ),
            child: Text(
              'Tinted color + contrast text',
              style: TextStyle(
                color: Colors.teal.withTint(0.2).contrastText,
                fontSize: 12.responsiveFont,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## API

### `ScreenUtils` (singleton)

- `scale(double value)` → double  
  General scalar for any numeric value.
- `font(double value)` → double  
  Scales for text using phone/tablet multipliers.
- `icon(double value)` → double  
  Scales for icons using phone/tablet multipliers.
- `offset(double dx, double dy)` → `Offset`  
- `alignment(double x, double y)` → `Alignment`  
  Tablet bias subtly recenters alignment (`alignmentTabletBias`).
- `padding({left, top, right, bottom})` → `EdgeInsets`
- `wPct(double pct)` / `hPct(double pct)` → double  
  Percent of width/height (0..1).
- `viewPaddingOf(context)` / `viewInsetsOf(context)` → `EdgeInsets`
- Dimensions: `width`, `height`
- Flags: `isTablet`, `isWeb`, `isAndroid`, `isIos`, `isPad`

### Color utilities

```dart
// extension helpers
final color = Colors.blue.withShade(0.15);
final readable = color.contrastText;
final hex = color.toHex();

// static helpers
final fromHex = ColorExtention.fromHex('#1e88e5');
final named = ColorMisc.nameToColor('Ruki');
```

### Configuration

```dart
ScreenUtils.configure(
  baseWidth: 360,
  baseHeight: 640,
  fontMultiplierPhone: 1.0,
  fontMultiplierTablet: 0.9,
  iconMultiplierPhone: 1.0,
  iconMultiplierTablet: 1.1,
  alignmentTabletBias: 0.85, // 0..1
  listenForMetrics: true,     // auto recompute on rotation/resize
);
```

You can call `configure` multiple times (e.g., per route/app section) or use `ScreenUtils.instance.refresh(context)` to recompute with a specific `BuildContext`.

---

## Extensions

```dart
// numbers
10.responsive;       // general scalar
16.responsiveFont;   // text
24.responsiveIcon;   // icons

// percentages
0.5.vw;              // 50% of screen width
0.25.vh;             // 25% of screen height

// paddings, alignments, offsets
const EdgeInsets.all(12).responsive;
const Alignment(1, -1).responsive;
const Offset(10, 20).responsive;
```

---

## Platform helpers

```dart
if (isWeb)  ...
if (isAndroid) ...
if (isIos) ...
if (isTablet) ...
if (isPad) ...
```

Also available:

```dart
kDeviceWidth;   // logical width (shorter edge)
kDeviceHeight;  // logical height (longer edge)
```

---

## Example app

See [`example/lib/main.dart`](./example/lib/main.dart) for a minimal runnable demo that showcases:
- configuration via `ScreenUtils.configure(...)`
- responsive text, icons, paddings, and percentages
- safe-area handling

Run it with:

```bash
flutter run --target=example/lib/main.dart
```

---

## Testing

Add the Flutter test SDK and run tests.

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

```bash
flutter test
```

> A sample suite is provided in `test/ruki_utils_test.dart`, covering scaling, tablet detection, percent helpers, alignment bias, and safe-area helpers.

---

## Notes & design choices

- No `dart:io` usage → **web-safe** platform checks (`kIsWeb` + `defaultTargetPlatform`).
- Scaling is **smooth** (no `ceilToDouble`), better for animations.
- Tablet heuristic uses average of base factors + width threshold (`>= 600dp`).
- Alignment “drift” (`alignmentTabletBias`) keeps large screens from feeling overly stretched.

---

## License

MIT © Olamide Olamide Ogunlade
