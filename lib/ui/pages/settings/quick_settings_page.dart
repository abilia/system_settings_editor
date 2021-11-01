import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class QuickSettingsPage extends StatelessWidget {
  const QuickSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: t.quickSettingsMenu.singleLine,
        iconData: AbiliaIcons.settings,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.s, 20.s, 16.s, 20.s),
            child: const BatteryLevelDisplay(),
          ),
          const QuickSettingsGroup(children: [
            BrightnessSlider(),
          ]),
        ],
      ),
      bottomNavigationBar:
          const BottomNavigation(backNavigationWidget: PreviousButton()),
    );
  }
}

class QuickSettingsGroup extends StatelessWidget {
  const QuickSettingsGroup({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 20.s),
          child: Column(
            children: [
              ...children,
            ],
          ),
        )
      ],
    );
  }
}

class BrightnessSlider extends StatefulWidget {
  const BrightnessSlider({Key? key}) : super(key: key);

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider>
    with WidgetsBindingObserver {
  final _log = Logger((_BrightnessSliderState).toString());
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initBrightness();
    }
  }

  void initBrightness() async {
    try {
      final b = await SystemSettingsEditor.brightness;
      setState(() {
        _brightness = b ?? 0;
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get brightness', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubHeading(t.screenBrightness),
            AbiliaSlider(
                leading: const Icon(AbiliaIcons.brightnessNormal),
                value: _brightness,
                onChanged: (double b) {
                  setState(() {
                    _brightness = b;
                    SystemSettingsEditor.setBrightness(b);
                  });
                }),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

class BatteryLevelDisplay extends StatefulWidget {
  const BatteryLevelDisplay({Key? key}) : super(key: key);

  @override
  State<BatteryLevelDisplay> createState() => _BatteryLevelDisplayState();
}

class _BatteryLevelDisplayState extends State<BatteryLevelDisplay> {
  int _batteryLevel = -1;
  final battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    initBatteryLevel();
  }

  void initBatteryLevel() async {
    final b = await battery.batteryLevel;
    setState(() {
      _batteryLevel = b;
    });

    _batterySubscription =
        battery.onBatteryStateChanged.listen((BatteryState state) async {
      final b = await battery.batteryLevel;
      setState(() {
        _batteryLevel = b;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(
          t.battery,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 18.s,
            ),
            Icon(
              _batteryLevelIcon(_batteryLevel),
              size: largeIconSize,
            ),
            SizedBox(
              width: 16.s,
            ),
            Text(
              _batteryLevel > 0 ? '$_batteryLevel%' : '',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ],
    );
  }

  IconData? _batteryLevelIcon(int batteryLevel) {
    if (batteryLevel > 90) {
      return AbiliaIcons.batteryLevel_100;
    }
    if (batteryLevel > 70) {
      return AbiliaIcons.batteryLevel_80;
    }
    if (batteryLevel > 50) {
      return AbiliaIcons.batteryLevel_60;
    }
    if (batteryLevel > 30) {
      return AbiliaIcons.batteryLevel_40;
    }
    if (batteryLevel > 10) {
      return AbiliaIcons.batteryLevel_20;
    }
    if (batteryLevel > 5) {
      return AbiliaIcons.batteryLevel_10;
    }
    if (batteryLevel > 0) {
      return AbiliaIcons.batteryLevelCritical;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _batterySubscription?.cancel();
  }
}
