import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_file.dart';

import 'package:seagull/ui/all.dart';

class RecordSoundPage extends StatelessWidget {
  final String title;

  const RecordSoundPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: title,
        iconData: AbiliaIcons.dictaphone,
      ),
      body: const RecordingWidget(),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () {
            final recordState = context.read<RecordSoundCubit>().state;
            if (recordState is NewRecordedSoundState) {
              return Navigator.of(context).pop(recordState.unstoredAbiliaFile);
            } else if (recordState is EmptyRecordSoundState) {
              return Navigator.of(context).pop(AbiliaFile.empty);
            }
            return Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
