import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/abilia_file.dart';

import 'package:memoplanner/ui/all.dart';

class RecordSoundPage extends StatelessWidget {
  final String title;

  const RecordSoundPage({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialRecording =
        context.read<RecordSoundCubit>().state.recordedFile;
    return PopAwareDiscardListener(
      showDiscardDialogCondition: (context) {
        final recordSoundState = context.read<RecordSoundCubit>().state;
        final fileChanged = initialRecording != recordSoundState.recordedFile;
        final isRecording = recordSoundState is RecordingSoundState;
        return fileChanged || isRecording;
      },
      child: Scaffold(
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
                return Navigator.of(context)
                    .pop(recordState.unstoredAbiliaFile);
              } else if (recordState is EmptyRecordSoundState) {
                return Navigator.of(context).pop(AbiliaFile.empty);
              }
              return Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
