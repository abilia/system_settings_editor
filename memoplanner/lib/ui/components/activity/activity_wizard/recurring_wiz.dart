import 'package:memoplanner/ui/all.dart';

class RecurringWiz extends StatelessWidget {
  const RecurringWiz({super.key});

  @override
  Widget build(BuildContext context) => WizardScaffold(
        title: Lt.of(context).recurrence,
        iconData: AbiliaIcons.repeat,
        body: const RecurrenceTab(),
      );
}
