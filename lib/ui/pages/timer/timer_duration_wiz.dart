import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerDurationWiz extends StatelessWidget {
  const TimerDurationWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.about,
        title: 'Set timer time',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                onChanged: (t) => context
                    .read<TimerWizardCubit>()
                    .updateDuration(Duration(minutes: int.parse(t))),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () {
            Navigator.of(context).maybePop();
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
