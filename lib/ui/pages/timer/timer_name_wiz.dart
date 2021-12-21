import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

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
        child: BlocBuilder<TimerWizardCubit, TimerWizardState>(
            builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubHeading(t.name),
              TextField(
                controller: TextEditingController(
                    text: state.name.isNotEmpty
                        ? state.name
                        : state.duration.toDurationString(
                            Translator.of(context).translate,
                            shortMin: false)),
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyText1,
                autofocus: true,
                onChanged: (text) =>
                    context.read<TimerWizardCubit>().updateName(text),
                maxLines: 1,
              ),
            ],
          );
        }),
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
