import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class RecordSoundPage extends StatelessWidget {
  final AbiliaFile originalSoundFile;

  RecordSoundPage({
    required this.originalSoundFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;

    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.speech,
        iconData: AbiliaIcons.speak_text,
      ),
      body: Stack(
        children: [
          Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme
                  .copyWith(subtitle1: abiliaTextTheme.headline4),
            ),
            child: BlocProvider(
              create: (context) => TimerBloc(),
              // builder: (context) {
              //   return
              child: BlocListener<RecordSoundCubit, RecordSoundState>(
                listenWhen: (_, current) => current is SaveRecordingState,
                listener: (context, state) =>
                    (state as SaveRecordingState).newRecording
                        ? Navigator.of(context).maybePop(state.recordedFile)
                        : Navigator.of(context).maybePop(null),
                child: RecordingWidget(
                  state: StoppedSoundState(originalSoundFile),
                ),
              ),
              // },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => context.read<RecordSoundCubit>().saveRecording(),
        ),
      ),
    );
  }
}
