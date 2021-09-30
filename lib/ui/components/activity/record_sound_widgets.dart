import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class RecordSoundWidget extends StatelessWidget {
  final Activity activity;
  final ValueChanged<Activity>? soundChanged;

  const RecordSoundWidget({
    Key? key,
    required this.activity,
    this.soundChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) {
        final permission = permissionState.status[Permission.microphone];
        return BlocProvider<SoundCubit>(
          create: (context) => SoundCubit(),
          child: Column(
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
                        SelectOrPlaySoundWidget(
                          label: translator.speechOnStart,
                          permissionStatus: permission,
                          recordedAudio: activity.extras.startTimeExtraAlarm,
                          onResult: (AbiliaFile result) {
                            BlocProvider.of<EditActivityBloc>(context).add(
                              ReplaceActivity(
                                activity.copyWith(
                                  extras: activity.extras.copyWith(
                                    startTimeExtraAlarm: result,
                                  ),
                                ),
                              ),
                            );
                            soundChanged?.call(
                              activity.copyWith(
                                extras: activity.extras.copyWith(
                                  startTimeExtraAlarm: result,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8.0.s),
                        SelectOrPlaySoundWidget(
                          label: translator.speechOnEnd,
                          permissionStatus: permission,
                          recordedAudio: activity.extras.endTimeExtraAlarm,
                          onResult: (AbiliaFile result) {
                            Activity newActivity = activity.copyWith(
                              extras: activity.extras.copyWith(
                                endTimeExtraAlarm: result,
                              ),
                            );
                            BlocProvider.of<EditActivityBloc>(context).add(
                              ReplaceActivity(newActivity),
                            );
                            soundChanged?.call(newActivity);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (permission == PermissionStatus.permanentlyDenied)
                    Padding(
                      padding: EdgeInsets.only(left: 8.0.s),
                      child: InfoButton(
                        onTap: () => showViewDialog(
                          useSafeArea: false,
                          context: context,
                          builder: (context) => PermissionInfoDialog(
                              permission: Permission.microphone),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectOrPlaySoundWidget extends StatelessWidget {
  final PermissionStatus? permissionStatus;
  final String label;
  final AbiliaFile recordedAudio;
  final ValueChanged<AbiliaFile> onResult;

  const SelectOrPlaySoundWidget({
    Key? key,
    required this.permissionStatus,
    required this.label,
    required this.recordedAudio,
    required this.onResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: PickField(
            leading: Icon(recordedAudio.isEmpty
                ? AbiliaIcons.no_record
                : AbiliaIcons.sms_sound),
            text: Text(label),
            onTap: permissionStatus == PermissionStatus.permanentlyDenied
                ? null
                : permissionStatus == PermissionStatus.denied
                    ? () async {
                        context
                            .read<PermissionBloc>()
                            .add(RequestPermissions([Permission.microphone]));
                      }
                    : () async {
                        final result =
                            await Navigator.of(context).push<AbiliaFile>(
                          MaterialPageRoute(
                            builder: (_) => CopiedAuthProviders(
                              blocContext: context,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (_) => SoundCubit()),
                                  BlocProvider(
                                    create: (_) => RecordSoundCubit(
                                      originalSoundFile: recordedAudio,
                                    ),
                                  ),
                                ],
                                child: const RecordSoundPage(),
                              ),
                            ),
                            settings: RouteSettings(name: 'SelectSpeechPage'),
                          ),
                        );
                        if (result is UnstoredAbiliaFile) {
                          context.read<UserFileBloc>().add(FileAdded(result));
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
                padding: EdgeInsets.only(left: 12.s),
                child: PlaySoundButton(
                  sound: state.getFile(
                    recordedAudio,
                    GetIt.I<FileStorage>(),
                  ),
                ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.s),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(Translator.of(context).translate.duration),
              _TimeDisplay(),
            ],
          ),
          SizedBox(height: 8.0.s),
          _Progress(),
          SizedBox(height: 24.0.s),
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
      padding: EdgeInsets.symmetric(horizontal: 12.s),
      child: BlocBuilder<SoundCubit, SoundState>(
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
                trackHeight: 4.s,
                thumbShape: RoundSliderThumbShape(
                  disabledThumbRadius: 12.s,
                  elevation: 0,
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
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
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
    return BlocBuilder<SoundCubit, SoundState>(
      builder: (context, soundState) {
        return BlocBuilder<RecordSoundCubit, RecordSoundState>(
          builder: (context, recordState) {
            return Row(
              children: [
                if (recordState is RecordedSoundState)
                  if (soundState is SoundPlaying)
                    Expanded(
                      child: StopButton(
                        onPressed: context.read<SoundCubit>().stopSound,
                      ),
                    )
                  else ...[
                    Expanded(
                      child: PlayRecordingButton(recordState.recordedFile),
                    ),
                    SizedBox(width: 12.s),
                    const DeleteButton()
                  ],
                if (recordState is RecordingSoundState)
                  Expanded(
                    child: StopButton(
                      onPressed: context.read<RecordSoundCubit>().stopRecording,
                    ),
                  )
                else if (recordState is EmptyRecordSoundState)
                  Expanded(child: const RecordAudioButton())
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
      width: 120.s,
      height: 64.s,
      alignment: Alignment.center,
      decoration: disabledBoxDecoration,
      child: BlocBuilder<SoundCubit, SoundState>(
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            prev is SoundPlaying &&
                curr is SoundPlaying &&
                curr.position.inSeconds != prev.position.inSeconds,
        builder: (context, soundState) =>
            BlocBuilder<RecordSoundCubit, RecordSoundState>(
          buildWhen: (prev, curr) =>
              prev.runtimeType != curr.runtimeType ||
              prev is RecordingSoundState &&
                  curr is RecordingSoundState &&
                  prev.duration.inSeconds != curr.duration.inSeconds,
          builder: (context, recordState) => Text(
            _formatTime(
              recordState is RecordingSoundState
                  ? recordState.duration
                  : soundState is SoundPlaying
                      ? soundState.position
                      : Duration.zero,
            ),
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
    );
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
  Widget build(BuildContext context) => IconAndTextButton(
        text: Translator.of(context).translate.record,
        icon: AbiliaIcons.dictaphone,
        onPressed: context.read<RecordSoundCubit>().startRecording,
        style: iconTextButtonStyleRed,
      );
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ActionButtonDark(
        onPressed: () => context.read<RecordSoundCubit>().deleteRecording(),
        child: Icon(AbiliaIcons.delete_all_clear),
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
      text: Translator.of(context).translate.stop,
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
      text: Translator.of(context).translate.play,
      icon: AbiliaIcons.play_sound,
      onPressed: () {
        if (sound is UnstoredAbiliaFile) {
          context.read<SoundCubit>().play(sound);
        } else {
          context.read<SoundCubit>().play(
                context
                    .read<UserFileBloc>()
                    .state
                    .getFile(sound, GetIt.I<FileStorage>())!,
              );
        }
      },
    );
  }
}