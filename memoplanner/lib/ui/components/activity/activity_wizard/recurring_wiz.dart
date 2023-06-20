import 'package:memoplanner/ui/all.dart';

class RecurringWiz extends StatelessWidget {
  const RecurringWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WizardScaffold(
        title: Translator.of(context).translate.recurrence,
        iconData: AbiliaIcons.repeat,
        body: const RecurrenceTab(),
      );
}
