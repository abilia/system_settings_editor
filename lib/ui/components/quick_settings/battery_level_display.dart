import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/battery/battery_cubit.dart';
import 'package:seagull/ui/all.dart';

class BatteryLevel extends StatelessWidget {
  const BatteryLevel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BatteryCubit>(
      create: (context) => BatteryCubit(),
      child: const BatteryLevelDisplay(),
    );
  }
}

class BatteryLevelDisplay extends StatelessWidget {
  const BatteryLevelDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<BatteryCubit, int>(
      builder: (context, batteryState) => Column(
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
                _batteryLevelIcon(batteryState),
                size: largeIconSize,
              ),
              SizedBox(
                width: 16.s,
              ),
              Text(
                batteryState > 0 ? '$batteryState%' : '',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          )
        ],
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
    if (batteryLevel > 0) {
      return AbiliaIcons.batteryLevelCritical;
    }
  }
}
