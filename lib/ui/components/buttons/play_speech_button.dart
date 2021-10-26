import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

class PlaySpeechButton extends StatelessWidget {
  final AbiliaFile speech;
  const PlaySpeechButton({
    Key? key,
    required this.speech,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => SoundCubit(
          storage: GetIt.I<FileStorage>(),
          userFileBloc: context.read<UserFileBloc>(),
        ),
        child: PlaySoundButton(
          sound: speech,
        ),
      );
}
