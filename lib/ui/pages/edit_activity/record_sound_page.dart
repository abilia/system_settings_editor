import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

class RecordSoundPage extends StatelessWidget {
  const RecordSoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.speech,
        iconData: AbiliaIcons.speak_text,
      ),
      body: RecordingWidget(),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () {
            final recordState = context.read<RecordSoundCubit>().state;
            if (recordState is NewRecordedSoundState) {
              return Navigator.of(context).pop(recordState.unstoredAbiliaFile);
            }
            return Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
