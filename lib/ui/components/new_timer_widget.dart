import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class NewTimerWidget extends StatelessWidget with TimerNavigation {
  const NewTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    return Column(
      children: [
        PickField(
          key: TestKey.newTimerChoice,
          leading: const Icon(AbiliaIcons.stopWatch),
          text: Text(t.newTimer),
          onTap: () => navigateToEditTimerPage(context, authProviders),
        ).pad(layout.templates.m1.withoutBottom),
        PickField(
          key: TestKey.basicTimerChoice,
          leading: const Icon(AbiliaIcons.basicTimers),
          text: Text(t.fromTemplate),
          onTap: () => navigateToBasicTimerPage(context, authProviders),
        ).pad(m1ItemPadding),
      ],
    );
  }
}
