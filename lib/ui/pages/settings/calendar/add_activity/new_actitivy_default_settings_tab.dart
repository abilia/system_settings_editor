import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class NewActivityDefaultSettingsTab extends StatelessWidget {
  const NewActivityDefaultSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsTab(
      children: [
        Tts(child: Text(t.defaults)),
        RadioField(
          value: ALARM_SOUND,
          groupValue: ALARM_SOUND,
          onChanged: (v) {},
          text: Text(t.alarm),
          leading: Icon(
            AbiliaIcons.handi_alarm_vibration,
          ),
        ),
        RadioField(
          value: ALARM_SILENT,
          groupValue: ALARM_SOUND,
          onChanged: (v) {},
          text: Text(t.silentAlarm),
          leading: Icon(
            AbiliaIcons.handi_alarm,
          ),
        ),
        RadioField(
          value: NO_ALARM,
          groupValue: ALARM_SOUND,
          onChanged: (v) {},
          text: Text(t.noAlarm),
          leading: Icon(
            AbiliaIcons.handi_no_alarm_vibration,
          ),
        ),
        Divider(),
        SwitchField(
          text: Text(t.vibration),
          leading: Icon(AbiliaIcons.handi_vibration),
          value: true,
          onChanged: (v) {},
        ),
        SwitchField(
          text: Text(t.alarmOnlyAtStartTime),
          leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          value: true,
          onChanged: (v) {},
        ),
      ],
    );
  }
}
