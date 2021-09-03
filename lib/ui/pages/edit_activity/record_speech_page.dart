import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class RecordSpeechPage extends StatefulWidget {
  final AbiliaFile originalSoundFile;

  RecordSpeechPage({required this.originalSoundFile});

  @override
  State<StatefulWidget> createState() {
    return RecordSpeechPageState();
  }
}

class RecordSpeechPageState extends State<RecordSpeechPage> {
  AbiliaFile _recordedSoundFile = AbiliaFile.empty;

  RecordSpeechPageState();

  @override
  Widget build(BuildContext context) {
    return _RecordSpeechPage(
        originalSoundFile: widget.originalSoundFile,
        save: _recordedSoundFile != widget.originalSoundFile
            ? () => Navigator.of(context).maybePop(_recordedSoundFile)
            : null,
        onSoundRecorded: (s) {
          setState(() {
            _recordedSoundFile = s;
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
            child: BlocProvider(
              create: (context) => RecordSpeechCubit(
                onSoundRecorded: onSoundRecorded,
                recordedFile: originalSoundFile,
              ),
              child: RecordingWidget(
                  state: originalSoundFile.isNotEmpty
                      ? RecordState.StoppedNotEmpty
                      : RecordState.StoppedEmpty,
                  originalSoundFile: originalSoundFile,
                  onSoundRecorded: onSoundRecorded),
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
