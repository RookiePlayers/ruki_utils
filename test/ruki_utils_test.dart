import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruki_utils/ruki_utils.dart';

/// A tiny harness that lets us control logical size + safe-area values.
class _Harness extends StatelessWidget {
  final Size size;
  final EdgeInsets viewPadding;
  final Widget Function(BuildContext) builder;

  const _Harness({
    required this.size,
    required this.builder,
    this.viewPadding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryData(
      size: size,
      viewPadding: viewPadding,
    );
    return MediaQuery(
      data: mq,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: builder),
      ),
    );
  }
}

void main() {
  // Use a very small epsilon for floating-point comparison.
  const eps = 1e-6;

  setUp(() {
    // Reset to a known baseline before every test.
    ScreenUtils.configure(
      baseWidth: 360,
      baseHeight: 640,
      fontMultiplierPhone: 1.0,
      fontMultiplierTablet: 0.9,
      iconMultiplierPhone: 1.0,
      iconMultiplierTablet: 1.1,
      alignmentTabletBias: 0.85,
      listenForMetrics: false,
    );
  });

  testWidgets('Phone-sized screen has scaleFactor ~ 1.0 and not tablet',
      (tester) async {
    const size = Size(360, 640); // portrait logic baseline

    await tester.pumpWidget(_Harness(
      size: size,
      builder: (context) {
        // Recompute using the current BuildContext.
        ScreenUtils.instance.refresh(context);

        expect(isTablet, isFalse);
        expect((kDeviceWidth - 360).abs() < eps, isTrue);
        expect((kDeviceHeight - 640).abs() < eps, isTrue);

        // At baseline, 10.responsive should be ~10
        expect((10.responsive - 10).abs() < eps, isTrue);
        expect((16.responsiveFont - 16).abs() < eps, isTrue);
        expect((24.responsiveIcon - 24).abs() < eps, isTrue);

        // Alignment should be unchanged on phone
        final a = const Alignment(1, -1).responsive;
        expect((a.x - 1.0).abs() < eps, isTrue);
        expect((a.y + 1.0).abs() < eps, isTrue);

        // EdgeInsets/Offset scaling at baseline = identity
        final pad = const EdgeInsets.fromLTRB(4, 8, 12, 16).responsive;
        expect((pad.left - 4).abs() < eps, isTrue);
        expect((pad.top - 8).abs() < eps, isTrue);
        expect((pad.right - 12).abs() < eps, isTrue);
        expect((pad.bottom - 16).abs() < eps, isTrue);

        final off = const Offset(10, 20).responsive;
        expect((off.dx - 10).abs() < eps, isTrue);
        expect((off.dy - 20).abs() < eps, isTrue);

        // Percent helpers
        expect((0.5.vw - (kDeviceWidth * 0.5)).abs() < eps, isTrue);
        expect((0.25.vh - (kDeviceHeight * 0.25)).abs() < eps, isTrue);

        return const SizedBox.shrink();
      },
    ));
  });

  testWidgets('Tablet-sized screen: tablet=true, font/icon multipliers applied',
      (tester) async {
        // Simulate an 800x1280 logical screen.
        const size = Size(800, 1280);

        await tester.pumpWidget(_Harness(
          size: size,
          builder: (context) {
            ScreenUtils.instance.refresh(context);

            expect(isTablet, isTrue);

            // Replicate the package’s scale calculation to assert numerically
            // baseWidth=360, baseHeight=640 as set in setUp
            final width = kDeviceWidth;  // min(800, 1280) => 800
            final height = kDeviceHeight; // 1280
            final baseW = width / 360.0;  // 800/360 = 2.222...
            final baseH = height / 640.0; // 1280/640 = 2.0
            final avgBase = (baseW + baseH) / 2.0; // ~2.11111
            final deviceFactor = avgBase * 0.95;   // tablet deflate in impl

            // General scale
            expect(
              (10.responsive - (10 * deviceFactor)).abs() < 1e-4,
              isTrue,
            );

            // Font uses tablet multiplier 0.9
            expect(
              (20.responsiveFont - (20 * deviceFactor * 0.9)).abs() < 1e-4,
              isTrue,
            );

            // Icon uses tablet multiplier 1.1
            expect(
              (30.responsiveIcon - (30 * deviceFactor * 1.1)).abs() < 1e-4,
              isTrue,
            );

            // Alignment bias (0.85) on tablets
            final a = const Alignment(1, -1).responsive;
            expect((a.x - 0.85).abs() < eps, isTrue);
            expect((a.y + 0.85).abs() < eps, isTrue);

            // Percent helpers use the raw width/height
            expect((0.6.vw - (width * 0.6)).abs() < eps, isTrue);
            expect((0.1.vh - (height * 0.1)).abs() < eps, isTrue);

            // EdgeInsets scale
            final pad = const EdgeInsets.all(10).responsive;
            final expected = 10 * deviceFactor;
            expect((pad.left - expected).abs() < 1e-4, isTrue);
            expect((pad.top - expected).abs() < 1e-4, isTrue);
            expect((pad.right - expected).abs() < 1e-4, isTrue);
            expect((pad.bottom - expected).abs() < 1e-4, isTrue);

            // Offset scale
            final off = const Offset(4, 6).responsive;
            expect((off.dx - 4 * deviceFactor).abs() < 1e-4, isTrue);
            expect((off.dy - 6 * deviceFactor).abs() < 1e-4, isTrue);

            return const SizedBox.shrink();
          },
        ));
      });

  testWidgets('Safe-area helpers return MediaQuery.viewPadding',
      (tester) async {
    const size = Size(390, 844);
    const vp = EdgeInsets.only(top: 24, bottom: 34);

    await tester.pumpWidget(_Harness(
      size: size,
      viewPadding: vp,
      builder: (context) {
        ScreenUtils.instance.refresh(context);

        final got = ScreenUtils.instance.viewPaddingOf(context);
        expect(got, equals(vp));

        // Also ensure padding extension composes with safe area nicely
        final contentPad = const EdgeInsets.all(16).responsive.add(vp).resolve(TextDirection.ltr);
        expect((contentPad.top - (16.responsive + 24)).abs() < 1e-4, isTrue);
        expect((contentPad.bottom - (16.responsive + 34)).abs() < 1e-4, isTrue);
        return const SizedBox.shrink();
      },
    ));
  });

  testWidgets('configure(...) updates baselines and recomputes scale',
      (tester) async {
    const size = Size(400, 800);

    await tester.pumpWidget(_Harness(
      size: size,
      builder: (context) {
        // First with the default baseline 360x640
        ScreenUtils.instance.refresh(context);
        final width = kDeviceWidth;  // 400
        final height = kDeviceHeight; // 800

        double baseW = width / 360.0;    // 1.11111
        double baseH = height / 640.0;   // 1.25
        double avg = (baseW + baseH) / 2.0;
        final defaultFactor = avg * (isTablet ? 0.95 : 1.0);

        final v1 = 12.responsive;

        // Now update baseline to 375x812 and re-refresh
        ScreenUtils.configure(baseWidth: 375, baseHeight: 812);
        ScreenUtils.instance.refresh(context);

        baseW = width / 375.0;  // 1.066666...
        baseH = height / 812.0; // 0.985221...
        avg = (baseW + baseH) / 2.0;
        final newFactor = avg * (isTablet ? 0.95 : 1.0);

        final v2 = 12.responsive;

        // The values should reflect the change in factor
        expect((v1 - (12 * defaultFactor)).abs() < 1e-4, isTrue);
        expect((v2 - (12 * newFactor)).abs() < 1e-4, isTrue);

        return const SizedBox.shrink();
      },
    ));
  });
}