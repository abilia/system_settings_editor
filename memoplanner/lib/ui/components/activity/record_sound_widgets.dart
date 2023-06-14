import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class RecordSoundWidget extends StatelessWidget {
  const RecordSoundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Lt.of(context);
    final permission = context.select(
        (PermissionCubit cubit) => cubit.state.status[Permission.microphone]);
    final activity =
        context.select((EditActivityCubit cubit) => cubit.state.activity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SubHeading(translator.speech),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BlocProvider<SoundBloc>(
                    create: (context) => SoundBloc(
                      storage: GetIt.I<FileStorage>(),
                      userFileBloc: context.read<UserFileBloc>(),
                    ),
                    child: SelectOrPlaySoundWidget(
                      label: translator.speechOnStart,
                      permissionStatus: permission,
                      recordedAudio: activity.extras.startTimeExtraAlarm,
                      onResult: (AbiliaFile result) =>
                          context.read<EditActivityCubit>().replaceActivity(
                                activity.copyWith(
                                  extras: activity.extras.copyWith(
                                    startTimeExtraAlarm: result,
                                  ),
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  BlocProvider<SoundBloc>(
                    create: (context) => SoundBloc(
                      storage: GetIt.I<FileStorage>(),
                      userFileBloc: context.read<UserFileBloc>(),
                    ),
                    child: SelectOrPlaySoundWidget(
                      label: translator.speechOnEnd,
                      permissionStatus: permission,
                      recordedAudio: activity.extras.endTimeExtraAlarm,
                      onResult: (AbiliaFile result) =>
                          context.read<EditActivityCubit>().replaceActivity(
                                activity.copyWith(
                                  extras: activity.extras.copyWith(
                                    endTimeExtraAlarm: result,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            if (permission == PermissionStatus.permanentlyDenied)
              Padding(
                padding: EdgeInsets.only(
                  left: layout.formPadding.horizontalItemDistance,
                ),
                child: InfoButton(
                  onTap: () async => showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) => const PermissionInfoDialog(
                      permission: Permission.microphone,
                    ),
                    routeSettings: (PermissionInfoDialog).routeSetting(
                      properties: {
                        'permission': Permission.microphone.toString(),
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class SelectOrPlaySoundWidget extends StatelessWidget {
  final PermissionStatus? permissionStatus;
  final String label;
  final AbiliaFile recordedAudio;
  final ValueChanged<AbiliaFile> onResult;

  const SelectOrPlaySoundWidget({
    required this.permissionStatus,
    required this.label,
    required this.recordedAudio,
    required this.onResult,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: PickField(
            leading: Icon(recordedAudio.isEmpty
                ? AbiliaIcons.noRecord
                : AbiliaIcons.smsSound),
            text: Text(label),
            onTap: permissionStatus == PermissionStatus.permanentlyDenied
                ? null
                : permissionStatus == PermissionStatus.denied
                    ? () async {
                        await context
                            .read<PermissionCubit>()
                            .requestPermissions([Permission.microphone]);
                      }
                    : () async {
                        final authProviders = copiedAuthProviders(context);
                        final navigator = Navigator.of(context);
                        final soundBloc = context.read<SoundBloc>();
                        final userFileBloc = context.read<UserFileBloc>();
                        final audio = recordedAudio;
                        final file = audio is UnstoredAbiliaFile
                            ? audio.file
                            : recordedAudio.isNotEmpty
                                ? await soundBloc.resolveFile(recordedAudio)
                                : null;

                        final result = await navigator.push<AbiliaFile>(
                          PersistentMaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: authProviders,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: soundBloc),
                                  BlocProvider(
                                    create: (_) => RecordSoundCubit(
                                      originalSoundFile: recordedAudio,
                                    )..setFile(file),
                                  ),
                                ],
                                child: RecordSoundPage(
                                  initialRecording: recordedAudio,
                                  title: label,
                                ),
                              ),
                            ),
                            settings: (RecordSoundPage).routeSetting(),
                          ),
                        );
                        soundBloc.add(const StopSound());
                        if (result is UnstoredAbiliaFile) {
                          userFileBloc.add(FileAdded(result));
                        }
                        if (result != null) {
                          onResult.call(result);
                        }
                      },
          ),
        ),
        if (recordedAudio.isNotEmpty)
          BlocBuilder<UserFileBloc, UserFileState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(
                    left: layout.formPadding.largeHorizontalItemDistance),
                child: PlaySoundButton(sound: recordedAudio),
              );
            },
          ),
      ],
    );
  }
}

class RecordingWidget extends StatelessWidget {
  const RecordingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.templates.l5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(Lt.of(context).duration),
              const _TimeDisplay(),
            ],
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          const _Progress(),
          SizedBox(height: layout.formPadding.groupTopDistance),
          const _RecordActionRow(),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.recording.thumbRadius),
      child: BlocBuilder<SoundBloc, SoundState>(
        buildWhen: (prev, curr) =>
            curr is SoundPlaying || prev.runtimeType != curr.runtimeType,
        builder: (context, soundState) =>
            BlocBuilder<RecordSoundCubit, RecordSoundState>(
          buildWhen: (prev, curr) =>
              curr is RecordingSoundState ||
              prev.runtimeType != curr.runtimeType,
          builder: (context, recordState) {
            final progress = recordState is RecordingSoundState
                ? recordState.progress
                : soundState is SoundPlaying
                    ? soundState.progress
                    : 0.0;
            final color = recordState is RecordingSoundState ||
                    recordState is EmptyRecordSoundState
                ? AbiliaColors.red
                : AbiliaColors.black;
            return SliderTheme(
              data: SliderThemeData(
                disabledActiveTickMarkColor: color,
                disabledActiveTrackColor: color,
                disabledThumbColor: color,
                disabledInactiveTrackColor: AbiliaColors.white120,
                trackHeight: layout.recording.trackHeight,
                thumbShape: AbiliaThumbShape(
                  disabledThumbRadius: layout.recording.thumbRadius,
                  elevation: layout.slider.elevation,
                  outerBorder: layout.slider.outerBorder,
                  borderColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                trackShape: _NotPaddedRoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: progress,
                onChanged: null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotPaddedRoundedRectSliderTrackShape
    extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _RecordActionRow extends StatelessWidget {
  const _RecordActionRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoundBloc, SoundState>(
      builder: (context, soundState) {
        return BlocBuilder<RecordSoundCubit, RecordSoundState>(
          builder: (context, recordState) {
            return Row(
              children: [
                if (recordState is RecordedSoundState)
                  if (soundState is SoundPlaying)
                    Expanded(
                      child: StopButton(
                        onPressed: () =>
                            context.read<SoundBloc>().add(const StopSound()),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: PlayRecordingButton(recordState.recordedFile),
                    ),
                    SizedBox(
                        width: layout.formPadding.largeHorizontalItemDistance),
                    const DeleteButton()
                  ],
                if (recordState is RecordingSoundState)
                  Expanded(
                    child: StopButton(
                      onPressed: context.read<RecordSoundCubit>().stopRecording,
                    ),
                  )
                else if (recordState is EmptyRecordSoundState)
                  const Expanded(child: RecordAudioButton())
              ],
            );
          },
        );
      },
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout.timeInput.width,
      height: layout.timeInput.height,
      alignment: Alignment.center,
      decoration: disabledBoxDecoration,
      child: BlocBuilder<SoundBloc, SoundState>(
        builder: (context, soundState) =>
            BlocBuilder<RecordSoundCubit, RecordSoundState>(
          builder: (context, recordState) => Text(
            _formatTime(
              _resolveDuration(recordState, soundState),
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  Duration _resolveDuration(
      RecordSoundState recordState, SoundState soundState) {
    if (recordState is RecordingSoundState) {
      return recordState.duration;
    }
    if (soundState is SoundPlaying) {
      return soundState.position;
    }
    return recordState.duration;
  }

  String _formatTime(Duration d) {
    final min = '${d.inMinutes}'.padLeft(2, '0');
    final s = '${d.inSeconds}'.padLeft(2, '0');
    return '$min:$s';
  }
}

class RecordAudioButton extends StatelessWidget {
  const RecordAudioButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => RedButton(
        text: Lt.of(context).record,
        icon: AbiliaIcons.dictaphone,
        onPressed: context.read<RecordSoundCubit>().startRecording,
      );
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconActionButtonDark(
        onPressed: () async {
          context.read<SoundBloc>().add(const ResetPlayer());
          await context.read<RecordSoundCubit>().deleteRecording();
        },
        child: const Icon(AbiliaIcons.deleteAllClear),
      );
}

class StopButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StopButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkGreyButton(
      text: Lt.of(context).stop,
      icon: AbiliaIcons.stop,
      onPressed: onPressed,
    );
  }
}

class PlayRecordingButton extends StatelessWidget {
  final AbiliaFile sound;

  const PlayRecordingButton(
    this.sound, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkGreyButton(
      text: Lt.of(context).play,
      icon: AbiliaIcons.playSound,
      onPressed: () => context.read<SoundBloc>().add(PlaySound(sound)),
    );
  }
}
