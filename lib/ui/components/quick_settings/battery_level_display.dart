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
            _batteryLevelIcon(_batteryLevel),
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

  Widget _batteryLevelIcon(int batteryLevel) {
    if (batteryLevel > 90) {
      return const BatteryIcon100();
    }
    if (batteryLevel > 70) {
      return const BatteryIcon80();
    }
    if (batteryLevel > 50) {
      return const BatteryIcon60();
    }
    if (batteryLevel > 30) {
      return const BatteryIcon40();
    }
    if (batteryLevel > 10) {
      return const BatteryIcon20();
    }
    if (batteryLevel > 5) {
      return const BatteryIcon10();
    }
    if (batteryLevel > 0) {
      return const BatteryIconCritical();
    }
    return const SizedBox();
  }

  @override
  void dispose() {
    super.dispose();
    _batterySubscription?.cancel();
  }
}

class BatteryIconCritical extends StatelessWidget {
  const BatteryIconCritical({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevelCritical,
      size: largeIconSize,
    );
  }
}

class BatteryIcon10 extends StatelessWidget {
  const BatteryIcon10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_10,
      size: largeIconSize,
    );
  }
}

class BatteryIcon20 extends StatelessWidget {
  const BatteryIcon20({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_20,
      size: largeIconSize,
    );
  }
}

class BatteryIcon40 extends StatelessWidget {
  const BatteryIcon40({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_40,
      size: largeIconSize,
    );
  }
}

class BatteryIcon60 extends StatelessWidget {
  const BatteryIcon60({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_60,
      size: largeIconSize,
    );
  }
}

class BatteryIcon80 extends StatelessWidget {
  const BatteryIcon80({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_80,
      size: largeIconSize,
    );
  }
}

class BatteryIcon100 extends StatelessWidget {
  const BatteryIcon100({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AbiliaIcons.batteryLevel_100,
      size: largeIconSize,
    );
  }
}
