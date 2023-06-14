import 'package:battery_plus/battery_plus.dart';
import 'package:memoplanner/ui/all.dart';

class BatteryLevel extends StatelessWidget {
  final Battery battery;
  const BatteryLevel({required this.battery, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    return StreamBuilder(
      stream: battery.onBatteryStateChanged,
      builder: (context, _) => FutureBuilder<List<dynamic>>(
        // ignore: discarded_futures
        future: Future.wait([battery.batteryLevel, battery.batteryState]),
        builder: (context, snapshot) {
          final batteryLevel = snapshot.data?[0] ?? 0;
          final batteryState = snapshot.data?[1] ?? BatteryState.unknown;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(t.battery),
              Tts.data(
                data: '$batteryLevel%',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: layout.formPadding.largeHorizontalItemDistance,
                    ),
                    Icon(
                      batteryState == BatteryState.charging
                          ? AbiliaIcons.batteryCharging
                          : _batteryLevelIcon(batteryLevel),
                      size: layout.icon.large,
                    ),
                    SizedBox(width: layout.formPadding.groupHorizontalDistance),
                    Text(
                      batteryLevel > 0 ? '$batteryLevel%' : '',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
