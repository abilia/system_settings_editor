import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class RecordSoundPage extends StatelessWidget {
  final String title;
  final AbiliaFile initialRecording;

  const RecordSoundPage({
    required this.title,
    required this.initialRecording,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recordSoundCubit = context.watch<RecordSoundCubit>();
    final recordingChanged =
        initialRecording != recordSoundCubit.state.recordedFile;
    final isRecording = recordSoundCubit.state is RecordingSoundState;
    return PopAwareDiscardListener(
      showDiscardDialogCondition: (_) => recordingChanged || isRecording,
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: title,
          iconData: AbiliaIcons.dictaphone,
        ),
        body: const RecordingWidget(),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: recordingChanged && !isRecording
                ? () => _onSave(context)
                : null,
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context) {
    final recordState = context.read<RecordSoundCubit>().state;
    if (recordState is NewRecordedSoundState) {
      return Navigator.of(context).pop(recordState.unstoredAbiliaFile);
    } else if (recordState is EmptyRecordSoundState) {
      return Navigator.of(context).pop(AbiliaFile.empty);
    }
    return Navigator.of(context).pop();
  }
}
