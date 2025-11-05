import 'package:flutter/material.dart';
import 'package:ruki_utils/ruki_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: configure baselines & multipliers for your design system.
  ScreenUtils.configure(
    baseWidth: 375, // iPhone X baseline
    baseHeight: 812,
    fontMultiplierTablet: 0.95,
    listenForMetrics: true, // auto-refresh when orientation or size changes
  );

  runApp(const RukiExampleApp());
}

class RukiExampleApp extends StatelessWidget {
  const RukiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ruki_utils Example',
      theme: ThemeData.dark(),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe-area info
    final safePadding = ScreenUtils.instance.viewPaddingOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ruki_utils Demo'),
      ),
      body: Padding(
        padding: safePadding.add(const EdgeInsets.all(16).responsive),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Demonstrate responsive box
            Container(
              width: 0.6.vw, // 60% of screen width
              height: 0.1.vh, // 10% of screen height
              alignment: Alignment.center.responsive,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.responsive),
              ),
              child: Text(
                'Responsive Box',
                style: TextStyle(
                  fontSize: 16.responsiveFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.responsive),
            // Demonstrate font scaling
            Text(
              'This text scales with screen size',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.responsiveFont,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20.responsive),
            Icon(
              Icons.star_rounded,
              size: 32.responsiveIcon,
              color: Colors.amberAccent,
            ),
            const Spacer(),
            Text(
              'Device Info: ${isWeb ? "Web" : isAndroid ? "Android" : isIos ? "iOS" : "Unknown"}\n'
              'Tablet: $isTablet | Width: ${kDeviceWidth.toStringAsFixed(0)} | Height: ${kDeviceHeight.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.responsiveFont),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
