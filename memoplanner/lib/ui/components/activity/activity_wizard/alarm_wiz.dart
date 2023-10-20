import 'package:memoplanner/ui/all.dart';

class AlarmWiz extends StatelessWidget {
  const AlarmWiz({super.key});

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.attention,
      title: Lt.of(context).alarm,
      body: const SelectAlarmWizPage(),
    );
  }
}

class SelectAlarmWizPage extends StatelessWidget {
  const SelectAlarmWizPage({super.key});

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
