import 'package:auto_size_text/auto_size_text.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

typedef OnAddButtonPressed = Future Function(
  BuildContext context, {
  bool showActivities,
  bool showTimers,
});

enum _ButtonType {
  none,
  mpgo,
  activity,
  timer,
  activityAndTimer,
}

class AddButton extends StatelessWidget
    with ActivityNavigation, TimerNavigation {
  const AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasMP4Session = context.read<SessionsCubit>().state.hasMP4Session;
    final buttonType = context.select((MemoplannerSettingsBloc bloc) =>
        _buttonType(bloc.state.functions.display, hasMP4Session));
    switch (buttonType) {
      case _ButtonType.none:
        return SizedBox(width: layout.actionButton.size);
      case _ButtonType.mpgo:
        return _AddButtonMPGO(_onAddButtonPressed);
      case _ButtonType.activity:
        return _AddActivityButton(_onAddButtonPressed);
      case _ButtonType.timer:
        return _AddTimerButton(_onAddButtonPressed);
      case _ButtonType.activityAndTimer:
        return _AddActivityOrTimerButtons(_onAddButtonPressed);
    }
  }

  static _ButtonType _buttonType(
    DisplaySettings settings,
    bool hasMP4Session, // no timers for mp3 users
  ) {
    final newTimer = settings.newTimer;
    final newActivity = settings.newActivity;
    if (Config.isMPGO) {
      final displayNewTimer = hasMP4Session && newTimer;
      final useGoButton = newActivity || displayNewTimer;
      return useGoButton ? _ButtonType.mpgo : _ButtonType.none;
    }
    return newActivity && newTimer
        ? _ButtonType.activityAndTimer
        : newActivity
            ? _ButtonType.activity
            : newTimer
                ? _ButtonType.timer
                : _ButtonType.none;
  }

  Future _onAddButtonPressed(
    BuildContext context, {
    bool showActivities = true,
    bool showTimers = true,
  }) {
    final authProviders = copiedAuthProviders(context);
    final settings = context.read<MemoplannerSettingsBloc>().state;
    final basicActivityOption = settings.addActivity.basicActivityOption;
    final newActivityOption = settings.addActivity.newActivityOption;
    final showOnlyActivities = showActivities && !showTimers;

    if (showOnlyActivities && Config.isMP) {
      if (newActivityOption && !basicActivityOption) {
        return navigateToActivityWizardWithContext(context, authProviders);
      } else if (basicActivityOption && !newActivityOption) {
        return navigateToBasicActivityPicker(
            context, authProviders, settings.addActivity.defaults);
      }
    }

    return _navigateToCreateNewPage(
      context,
      authProviders,
      showActivities,
      showTimers,
    );
  }

  Future _navigateToCreateNewPage(
    BuildContext context,
    List<BlocProvider> authProviders,
    bool showActivities,
    bool showTimers,
  ) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: authProviders,
            child: CreateNewPage(
              showActivities: showActivities,
              showTimers: showTimers,
            ),
          ),
          settings: (CreateNewPage).routeSetting(
            properties: {
              'Show Activities': showActivities,
              'Show Timers': showTimers,
            },
          ),
        ),
      );
}

class _AddButtonMPGO extends StatelessWidget {
  final OnAddButtonPressed onAddButtonPressed;

  const _AddButtonMPGO(this.onAddButtonPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconActionButton(
      key: TestKey.addActivityButton,
      style: actionButtonStyleLight,
      ttsData: Translator.of(context).translate.add,
      onPressed: () async => onAddButtonPressed(
        context,
        showActivities: true,
        showTimers: context
            .read<SessionsCubit>()
            .state
            .hasMP4Session, // no timers for mp3 users
      ),
      child: const Icon(AbiliaIcons.plus),
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  final OnAddButtonPressed onAddButtonPressed;

  const _AddActivityButton(this.onAddButtonPressed, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      Translator.of(context).translate.activity,
      AbiliaIcons.plus,
      key: TestKey.addActivityButton,
      ttsData: Translator.of(context).translate.addActivity,
      onPressed: () async => onAddButtonPressed(
        context,
        showActivities: true,
        showTimers: false,
      ),
    );
  }
}

class _AddTimerButton extends StatelessWidget {
  final OnAddButtonPressed onAddButtonPressed;

  const _AddTimerButton(this.onAddButtonPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      Translator.of(context).translate.timer,
      AbiliaIcons.stopWatch,
      key: TestKey.addTimerButton,
      ttsData: Translator.of(context).translate.addTimer,
      onPressed: () async => onAddButtonPressed(
        context,
        showActivities: false,
        showTimers: true,
      ),
    );
  }
}

class _AddActivityOrTimerButtons extends StatelessWidget {
  final OnAddButtonPressed onAddButtonPressed;

  const _AddActivityOrTimerButtons(this.onAddButtonPressed, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,
      shape: ligthShapeBorder.copyWith(
        side: ligthShapeBorder.side.copyWith(
          width: layout.tabBar.item.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AddTab(
            key: TestKey.addActivityButton,
            text: translate.activity,
            icon: AbiliaIcons.plus,
            position: _AddTabPosition.left,
            ttsData: Translator.of(context).translate.addActivity,
            onTap: () async => onAddButtonPressed(
              context,
              showActivities: true,
              showTimers: false,
            ),
          ),
          SizedBox(
            width: layout.tabBar.item.border,
          ),
          _AddTab(
            key: TestKey.addTimerButton,
            text: translate.timer,
            icon: AbiliaIcons.stopWatch,
            position: _AddTabPosition.right,
            ttsData: Translator.of(context).translate.addTimer,
            onTap: () async => onAddButtonPressed(
              context,
              showActivities: false,
              showTimers: true,
            ),
          ),
        ],
      ),
    );
  }
}

enum _AddTabPosition { left, right }

class _AddTab extends StatelessWidget {
  const _AddTab({
    required this.text,
    required this.icon,
    required this.position,
    required this.onTap,
    this.ttsData,
    Key? key,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final _AddTabPosition position;
  final VoidCallback onTap;
  final String? ttsData;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        (Theme.of(context).textTheme.bodySmall ?? bodySmall).copyWith(
      color: AbiliaColors.white,
      height: 1,
    );
    final iconTheme = IconTheme.of(context).copyWith(
      color: AbiliaColors.white,
      size: layout.actionButton.withTextIconSize,
    );
    final borderSide = ligthShapeBorder.side.copyWith(
      width: layout.tabBar.item.border,
    );
    final isLeft = position == _AddTabPosition.left;

    return Tts.data(
      data: ttsData ?? text,
      child: SizedBox(
        height: layout.actionButton.size,
        width: layout.actionButton.size,
        child: Ink(
          decoration: BoxDecoration(
            border: Border(
              left: borderSide.copyWith(
                color: Colors.transparent,
                width: isLeft ? null : 0,
              ),
              right: borderSide.copyWith(
                color: Colors.transparent,
                width: isLeft ? 0 : null,
              ),
            ),
            color: AbiliaColors.transparentWhite20,
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: layout.actionButton.withTextPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: textStyle.fontSize,
                    child: Center(
                      child: AutoSizeText(
                        text,
                        minFontSize: 12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      ),
                    ),
                  ),
                  SizedBox(height: layout.actionButton.spacing),
                  IconTheme(
                    data: iconTheme,
                    child: Icon(icon),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
