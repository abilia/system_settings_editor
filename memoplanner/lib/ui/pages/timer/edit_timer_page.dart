import 'package:flutter/services.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class EditTimerPage extends StatelessWidget {
  const EditTimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return _EditTimerPage(
      title: t.newTimer,
      icon: AbiliaIcons.stopWatch,
      bottomNavigation: BottomNavigation(
        backNavigationWidget: const PreviousButton(),
        forwardNavigationWidget:
            BlocSelector<EditTimerCubit, EditTimerState, Duration>(
          selector: (state) => state.duration,
          builder: (context, duration) => StartButton(
            onPressed: duration.inMinutes > 0
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
    );
  }
}

class EditBasicTimerPage extends StatelessWidget {
  final String title;

  const EditBasicTimerPage({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return _EditTimerPage(
      title: title,
      icon: AbiliaIcons.basicTimers,
      bottomNavigation: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget:
            BlocSelector<EditTimerCubit, EditTimerState, Duration>(
          selector: (state) => state.duration,
          builder: (context, duration) => SaveButton(
            onPressed: duration.inMinutes > 0
                ? () => context.read<EditTimerCubit>().save()
                : () => showViewDialog(
                      context: context,
                      builder: (context) => ErrorDialog(
                        text: t.timerInvalidDuration,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class _EditTimerPage extends StatelessWidget {
  const _EditTimerPage({
    required this.bottomNavigation,
    required this.title,
    required this.icon,
    Key? key,
  }) : super(key: key);

  final BottomNavigation bottomNavigation;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTimerCubit, EditTimerState>(
      listener: (context, state) {
        if (state is SavedTimerState) {
          return Navigator.pop(context, state.savedTimer);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AbiliaAppBar(
          iconData: icon,
          title: title,
        ),
        body: Padding(
          padding: layout.templates.m3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _TimerInfoInput(),
              Expanded(
                child: BlocSelector<EditTimerCubit, EditTimerState, Duration>(
                  selector: (state) => state.duration,
                  builder: (context, duration) => TimerWheel.interactive(
                    lengthInSeconds: duration.inSeconds,
                    onMinutesSelectedChanged: (minutesSelected) {
                      HapticFeedback.selectionClick();
                      context.read<EditTimerCubit>().updateDuration(
                            Duration(minutes: minutesSelected),
                          );
                    },
                  ).pad(layout.editTimer.wheelPadding),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigation,
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
                          final editTimerCubit = context.read<EditTimerCubit>();
                          final duration =
                              await Navigator.of(context).push<Duration>(
                            PersistentMaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: authProviders,
                                child: EditTimerDurationPage(
                                  initialDuration: state.duration,
                                ),
                              ),
                            ),
                          );
                          if (duration != null) {
                            editTimerCubit.updateDuration(duration);
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
