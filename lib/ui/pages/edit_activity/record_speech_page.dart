import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/record_speech_cubit.dart';
import 'package:seagull/models/user_file.dart';
import 'package:seagull/ui/components/activity/record_speech.dart';

import '../../all.dart';

class RecordSpeechPage extends StatefulWidget {
  final String originalSoundFile;

  RecordSpeechPage({required this.originalSoundFile});

  @override
  State<StatefulWidget> createState() {
    return RecordSpeechPageState(originalSoundFile: originalSoundFile);
  }
}

class RecordSpeechPageState extends State<RecordSpeechPage> {
  String originalSoundFile;
  String _recordedSoundFile = '';

  RecordSpeechPageState({this.originalSoundFile = ''});

  @override
  Widget build(BuildContext context) {
    return _RecordSpeechPage(
        originalSoundFile: originalSoundFile,
        save: _recordedSoundFile != widget.originalSoundFile
            ? () => Navigator.of(context)
                .maybePop(_createUserFile(_recordedSoundFile))
            : null,
        onSoundRecorded: (s) {
          setState(() {
            _recordedSoundFile = s;
          });
        });
  }

  UserFile _createUserFile(String recordedSoundFile) {
    return UserFile(
      contentType: SOUND_EXTENSION,
      deleted: false,
      fileSize: 1,
      id: recordedSoundFile
          .split('/')
          .last
          .replaceFirst(SOUND_NAME_PREAMBLE, '')
          .replaceFirst('.$SOUND_EXTENSION', ''),
      md5: '',
      path: recordedSoundFile,
      sha1: '',
      fileLoaded: true,
    );
  }
}

class _RecordSpeechPage extends StatelessWidget {
  final GestureTapCallback? save;
  final ValueChanged<String> onSoundRecorded;
  final String originalSoundFile;

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
                recordedFilePath: originalSoundFile,
              ),
              child: RecordingWidget(
                  state: originalSoundFile != ''
                      ? RecordPageState.StoppedNotEmpty
                      : RecordPageState.StoppedEmpty,
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
