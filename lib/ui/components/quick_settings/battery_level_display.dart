import 'package:battery_plus/battery_plus.dart';

import 'package:seagull/ui/all.dart';

class BatteryLevel extends StatelessWidget {
  final Battery battery;
  const BatteryLevel({required this.battery, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return StreamBuilder(
      stream: battery.onBatteryStateChanged,
      builder: (context, _) => FutureBuilder<int>(
        future: battery.batteryLevel,
        builder: (context, snapshot) {
          final batteryLevel = snapshot.data ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(t.battery),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: layout.formPadding.largeHorizontalItemDistance,
                  ),
                  Icon(
                    _batteryLevelIcon(batteryLevel),
                    size: layout.icon.large,
                  ),
                  SizedBox(width: layout.formPadding.groupHorizontalDistance),
                  Text(
                    batteryLevel > 0 ? batteryLevel.toString() + '%' : '',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            ],
          );
        },
      ),
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
    if (batteryLevel >= 0) {
      return AbiliaIcons.batteryLevelCritical;
    }
    return null;
  }
}
