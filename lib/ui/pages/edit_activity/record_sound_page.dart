import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/timer/ticker.dart';
import 'package:seagull/ui/all.dart';

class RecordSoundPage extends StatefulWidget {
  final AbiliaFile originalSoundFile;

  RecordSoundPage({required this.originalSoundFile});

  @override
  State<StatefulWidget> createState() {
    return RecordSoundPageState(recordedSoundFile: originalSoundFile);
  }
}

class RecordSoundPageState extends State<RecordSoundPage> {
  AbiliaFile recordedSoundFile = AbiliaFile.empty;

  RecordSoundPageState({required this.recordedSoundFile});

  @override
  Widget build(BuildContext context) {
    return _RecordSpeechPage(
        originalSoundFile: widget.originalSoundFile,
        save: recordedSoundFile != widget.originalSoundFile
            ? () => Navigator.of(context).maybePop(recordedSoundFile)
            : null,
        onSoundRecorded: (s) {
          setState(() {
            recordedSoundFile = s;
          });
        });
  }
}

class _RecordSpeechPage extends StatelessWidget {
  final GestureTapCallback? save;
  final ValueChanged<AbiliaFile> onSoundRecorded;
  final AbiliaFile originalSoundFile;

  _RecordSpeechPage(
      {required this.originalSoundFile,
      this.save,
      required this.onSoundRecorded});

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
                    .copyWith(subtitle1: abiliaTextTheme.headline4)),
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => TimerBloc(ticker: AudioTicker()),
                ),
                BlocProvider(
                  create: (context) => RecordSoundCubit(
                    onSoundRecorded: onSoundRecorded,
                    recordedFile: originalSoundFile,
                  ),
                ),
              ],
              child: RecordingWidget(
                state: RecordSoundState(RecordState.Stopped, originalSoundFile),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: save,
        ),
      ),
    );
  }
}
