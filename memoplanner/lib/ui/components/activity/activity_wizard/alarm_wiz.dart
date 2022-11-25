import 'package:memoplanner/ui/all.dart';

class AlarmWiz extends StatelessWidget {
  const AlarmWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.attention,
      title: Translator.of(context).translate.alarm,
      body: const SelectAlarmWizPage(),
    );
  }
}

class SelectAlarmWizPage extends StatelessWidget {
  const SelectAlarmWizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectAlarmTypeBody(
      trailing: [
        const SizedBox(),
        const Divider(),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        const AlarmOnlyAtStartSwitch(),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        const Divider(),
        SizedBox(height: layout.formPadding.groupTopDistance),
        const RecordSoundWidget(),
      ],
    );
  }
}
