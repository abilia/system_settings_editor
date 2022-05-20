import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class EditTimerPage extends StatelessWidget {
  const EditTimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocListener<EditTimerCubit, EditTimerState>(
      listener: (context, state) {
        if (state is SavedTimerState) {
          return Navigator.pop(context, state.savedTimer);
        }
      },
      child: BlocBuilder<EditTimerCubit, EditTimerState>(
        builder: (context, state) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.stopWatch,
            title: t.newTimer,
          ),
          body: Padding(
            padding: layout.templates.m3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _TimerInfoInput(),
                Expanded(
                  child: TimerWheel.interactive(
                    lengthInSeconds: state.duration.inSeconds,
                    onMinutesSelectedChanged: (minutesSelected) {
                      HapticFeedback.selectionClick();
                      context.read<EditTimerCubit>().updateDuration(
                            Duration(minutes: minutesSelected),
                          );
                    },
                  ).pad(layout.editTimer.wheelPadding),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: Navigator.of(context).pop,
            ),
            forwardNavigationWidget: StartButton(
              onPressed: state.duration.inMinutes > 0
                  ? context.read<EditTimerCubit>().start
                  : () => showViewDialog(
                        context: context,
                        builder: (context) => ErrorDialog(
                          text: t.timerInvalidDuration,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerInfoInput extends StatelessWidget {
  const _TimerInfoInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTimerCubit, EditTimerState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectPictureWidget(
                  selectedImage: state.image,
                  isLarge: true,
                  onImageSelected: (selectedImage) {
                    BlocProvider.of<EditTimerCubit>(context)
                        .updateImage(selectedImage);
                  },
                ),
                SizedBox(width: layout.formPadding.largeVerticalItemDistance),
                Expanded(
                  child: Column(
                    children: [
                      NameInput(
                        key: TestKey.timerNameText,
                        text: state.name,
                        onEdit: (text) {
                          if (state.name != text) {
                            BlocProvider.of<EditTimerCubit>(context)
                                .updateName(text);
                          }
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        inputHeading:
                            Translator.of(context).translate.enterNameForTimer,
                      ),
                      SizedBox(height: layout.formPadding.verticalItemDistance),
                      PickField(
                        onTap: () async {
                          final authProviders = copiedAuthProviders(context);
                          final duration =
                              await Navigator.of(context).push<Duration>(
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: authProviders,
                                child: EditTimerDurationPage(
                                  initialDuration: state.duration,
                                ),
                              ),
                            ),
                          );
                          if (duration != null) {
                            context
                                .read<EditTimerCubit>()
                                .updateDuration(duration);
                          }
                        },
                        leading: const Icon(AbiliaIcons.clock),
                        text: Text(
                          state.duration
                              .toString()
                              .split('.')
                              .first
                              .padLeft(8, '0'),
                        ),
                        trailing: PickField.trailingArrow,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}