import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/buttons/play_sound_button.dart';
import 'package:seagull/ui/pages/settings/select_sound_page.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) {
        final widgets = [
          AlarmSelector(
            selectedName: t.nonCheckableActivities,
            heading: t.nonCheckableActivities,
            sound: memoSettingsState.nonCheckableAlarm,
            onChanged: (sound) {},
          )
        ];
        return Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.alarmSettings,
            iconData: AbiliaIcons.handi_alarm_vibration,
          ),
          body: ListView.separated(
            padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
            itemBuilder: (context, i) => widgets[i],
            itemCount: widgets.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.0.s),
          ),
          bottomNavigationBar: const BottomNavigation(
            backNavigationWidget: CancelButton(),
            forwardNavigationWidget: OkButton(),
          ),
        );
      },
    );
  }
}

class AlarmSelector extends StatelessWidget {
  final String selectedName;
  final String heading;
  final Sound sound;
  final ValueChanged<Sound> onChanged;
  const AlarmSelector({
    Key key,
    @required this.selectedName,
    @required this.heading,
    @required this.sound,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(heading),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: PickField(
                key: TestKey.availibleFor,
                text: Text(sound.displayName(t)),
                onTap: () async {
                  final result = await Navigator.of(context).push<Sound>(
                    MaterialPageRoute(
                      builder: (context) => SelectSoundPage(
                        sound: sound,
                        appBarIcon: AbiliaIcons.handi_uncheck,
                        appBarTitle: t.nonCheckableActivities,
                      ),
                    ),
                  );
                  if (result != null && result != sound) {
                    onChanged(sound);
                  }
                },
              ),
            ),
            SizedBox(
              width: 12.s,
            ),
            PlaySoundButton(sound: sound),
          ],
        ),
      ],
    );
  }
}
