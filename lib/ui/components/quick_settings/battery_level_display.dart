import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:seagull/ui/all.dart';

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
