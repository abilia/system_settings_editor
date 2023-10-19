import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class NewTimerWidget extends StatelessWidget with TimerNavigation {
  const NewTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final translate = Lt.of(context);
    return Column(
      children: [
        PickField(
          key: TestKey.newTimerChoice,
          leading: const Icon(AbiliaIcons.stopWatch),
          text: Text(translate.newTimer),
          onTap: () async => navigateToEditTimerPage(context, authProviders),
        ).pad(layout.templates.m1.withoutBottom),
        PickField(
          key: TestKey.basicTimerChoice,
          leading: const Icon(AbiliaIcons.basicTimers),
          text: Text(translate.fromTemplate),
          onTap: () async => navigateToBasicTimerPage(context, authProviders),
        ).pad(m1ItemPadding),
      ],
    );
  }
}
