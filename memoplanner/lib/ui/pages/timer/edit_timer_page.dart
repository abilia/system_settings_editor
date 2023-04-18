import 'dart:async';

import 'package:flutter/services.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class EditTimerPage extends StatelessWidget {
  const EditTimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return PopAwareDiscardListener(
      showDiscardDialogCondition: (context) =>
          !context.read<EditTimerCubit>().state.unchanged,
      child: _EditTimerPage(
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
                  : () async => showViewDialog(
                        context: context,
                        builder: (context) =>
                            const InvalidTimerDurationDialog(),
                        routeSettings:
                            (InvalidTimerDurationDialog).routeSetting(),
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
    return PopAwareDiscardListener(
      showDiscardDialogCondition: (context) =>
          !context.read<EditTimerCubit>().state.unchanged,
      child: _EditTimerPage(
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
                  : () async => showViewDialog(
                        context: context,
                        builder: (context) =>
                            const InvalidTimerDurationDialog(),
                        routeSettings:
                            (InvalidTimerDurationDialog).routeSetting(),
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
            children: const [
              _TimerInfoInput(),
              Expanded(
                child: EditTimerWheel(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigation,
      ),
    );
  }
}

@visibleForTesting
class EditTimerWheel extends StatefulWidget {
  const EditTimerWheel({Key? key}) : super(key: key);

  @override
  State<EditTimerWheel> createState() => EditTimerWheelState();
}

@visibleForTesting
class EditTimerWheelState extends State<EditTimerWheel>
    with TickerProviderStateMixin {
  static const _initialDelay = Duration(milliseconds: 1000);
  static const _forwardDuration = Duration(milliseconds: 1000);
  static const _reverseDuration = Duration(milliseconds: 600);
  static const _delayBetweenAnimations = Duration(milliseconds: 2500);
  static const _midAnimationDelay = Duration(milliseconds: 400);
  late bool animate =
      context.read<EditTimerCubit>().state.duration == Duration.zero;
  Timer? animationTimer;

  late final AnimationController _animationController = AnimationController(
    duration: _forwardDuration,
    reverseDuration: _reverseDuration,
    vsync: this,
    animationBehavior: AnimationBehavior.preserve,
  )..addStatusListener((status) async {
      if (!animate) {
        _animationController.stop();
      }
      if (status == AnimationStatus.dismissed) {
        animationTimer = Timer(_delayBetweenAnimations, () {
          if (mounted) _animationController.forward();
        });
      }
      if (status == AnimationStatus.completed) {
        animationTimer = Timer(_midAnimationDelay, () {
          if (mounted) _animationController.reverse();
        });
      }
    });

  @override
  void initState() {
    super.initState();
    animationTimer = Timer(_initialDelay, () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.select((EditTimerCubit c) => c.state.duration);

    return BlocListener<EditTimerCubit, EditTimerState>(
      listenWhen: (previous, current) => previous.duration != current.duration,
      listener: (_, state) {
        _animationController.stop();
        animate = false;
      },
      child: ValueListenableBuilder(
        valueListenable: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ),
        builder: (_, value, __) {
          return TimerWheel.interactive(
            lengthInSeconds:
                animate ? (value * 120).toInt() : duration.inSeconds,
            onMinutesSelectedChanged: (minutesSelected) async {
              setState(() {
                _animationController.stop();
                animate = false;
              });
              context.read<EditTimerCubit>().updateDuration(
                    Duration(minutes: minutesSelected),
                    TimerSetType.wheel,
                  );
              await HapticFeedback.selectionClick();
            },
          ).pad(layout.editTimer.wheelPadding);
        },
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
                  onImageSelected: (imageAndName) {
                    BlocProvider.of<EditTimerCubit>(context)
                        .updateImage(imageAndName.image);
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
                              settings: (EditTimerDurationPage).routeSetting(),
                              builder: (_) => MultiBlocProvider(
                                providers: authProviders,
                                child: EditTimerDurationPage(
                                  initialDuration: state.duration,
                                ),
                              ),
                            ),
                          );
                          if (duration != null) {
                            editTimerCubit.updateDuration(
                              duration,
                              TimerSetType.inputField,
                            );
                          }
                        },
                        leading: const Icon(AbiliaIcons.clock),
                        text: Text(state.durationText),
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
