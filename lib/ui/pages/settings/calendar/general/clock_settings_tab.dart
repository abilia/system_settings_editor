import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ClockSettingsTab extends StatelessWidget {
  const ClockSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      builder: (context, state) {
        final onClockChanged = (v) => context
            .read<GeneralCalendarSettingsCubit>()
            .changeFunctionSettings(state.copyWith(clockType: v));
        return SettingsTab(
          children: [
            Tts(child: Text(t.clock)),
            Center(
              child: SizedBox(
                height: 90.s,
                width: 72.s,
                child: FittedBox(
                  child: AbiliaClockType(
                    state.clockType,
                  ),
                ),
              ),
            ),
            RadioField(
              text: Text(t.analogueDigital),
              value: ClockType.analogueDigital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(t.analogue),
              value: ClockType.analogue,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(t.digital),
              value: ClockType.digital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            const Divider(),
            Tts(child: Text(t.timeline)),
          ],
        );
      },
    );
  }
}
