import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerNameWiz extends StatelessWidget {
  const TimerNameWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.edit,
        title: t.enterNameForTimer,
      ),
      body: Padding(
        padding: ordinaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(t.name),
            BlocBuilder<TimerWizardCubit, TimerWizardState>(
              builder: (context, state) {
                return TextField(
                  controller: TextEditingController(text: state.name),
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.bodyText1,
                  autofocus: true,
                  onChanged: (text) =>
                      context.read<TimerWizardCubit>().updateName(text),
                  maxLines: 1,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () {
            context.read<TimerWizardCubit>().previous();
          },
        ),
        forwardNavigationWidget: NextButton(
          onPressed: () {
            context.read<TimerWizardCubit>().next();
          },
        ),
      ),
    );
  }
}
