import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class NewTimerWidget extends StatelessWidget with TimerNavigation {
  const NewTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Lt.of(context);
    return Column(
      children: [
        PickField(
          key: TestKey.newTimerChoice,
          leading: const Icon(AbiliaIcons.stopWatch),
          text: Text(t.newTimer),
          onTap: () async => navigateToEditTimerPage(context, authProviders),
        ).pad(layout.templates.m1.withoutBottom),
        PickField(
          key: TestKey.basicTimerChoice,
          leading: const Icon(AbiliaIcons.basicTimers),
          text: Text(t.fromTemplate),
          onTap: () async => navigateToBasicTimerPage(context, authProviders),
        ).pad(m1ItemPadding),
      ],
    );
  }
}
