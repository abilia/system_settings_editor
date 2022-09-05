import 'package:auto_size_text/auto_size_text.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

enum _AddButtonConfiguration {
  none,
  mpGo,
  onlyNewActivity,
  onlyNewTimer,
  newActivityAndNewTimer,
}

class AddButton extends StatelessWidget {
  const AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
        _AddButtonConfiguration>(
      selector: (state) => _configuration(state.settings.functions.display),
      builder: (context, configuration) {
        switch (configuration) {
          case _AddButtonConfiguration.none:
            return SizedBox(width: layout.actionButton.size);
          case _AddButtonConfiguration.mpGo:
            return const _AddButtonMPGO();
          case _AddButtonConfiguration.onlyNewActivity:
            return const _AddActivityButton();
          case _AddButtonConfiguration.onlyNewTimer:
            return const _AddTimerButton();
          case _AddButtonConfiguration.newActivityAndNewTimer:
            return const _AddActivityOrTimerButtons();
        }
      },
    );
  }

  static double width(DisplaySettings settings) {
    switch (_configuration(settings)) {
      case _AddButtonConfiguration.none:
      case _AddButtonConfiguration.mpGo:
      case _AddButtonConfiguration.onlyNewActivity:
      case _AddButtonConfiguration.onlyNewTimer:
        return layout.actionButton.size;
      case _AddButtonConfiguration.newActivityAndNewTimer:
        return _AddActivityOrTimerButtons.width;
    }
  }

  static _AddButtonConfiguration _configuration(
    DisplaySettings settings,
  ) {
    if (Config.isMPGO) {
      return settings.newActivity || settings.newTimer
          ? _AddButtonConfiguration.mpGo
          : _AddButtonConfiguration.none;
    }
    return settings.newActivity && settings.newTimer
        ? _AddButtonConfiguration.newActivityAndNewTimer
        : settings.newActivity
            ? _AddButtonConfiguration.onlyNewActivity
            : settings.newTimer
                ? _AddButtonConfiguration.onlyNewTimer
                : _AddButtonConfiguration.none;
  }
}

class _AddButtonMPGO extends StatelessWidget {
  const _AddButtonMPGO({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      Translator.of(context).translate.activity,
      AbiliaIcons.plus,
      key: TestKey.addActivityButton,
      ttsData: Translator.of(context).translate.addActivity,
      onPressed: () => _onAddButtonPressed(context: context),
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  const _AddActivityButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      Translator.of(context).translate.activity,
      AbiliaIcons.plus,
      key: TestKey.addActivityButton,
      ttsData: Translator.of(context).translate.addActivity,
      onPressed: () => _onAddButtonPressed(
        context: context,
        showTimers: false,
      ),
    );
  }
}

class _AddTimerButton extends StatelessWidget {
  const _AddTimerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      Translator.of(context).translate.timer,
      AbiliaIcons.stopWatch,
      key: TestKey.addTimerButton,
      ttsData: Translator.of(context).translate.addTimer,
      onPressed: () => _onAddButtonPressed(
        context: context,
        showActivities: false,
      ),
    );
  }
}

class _AddActivityOrTimerButtons extends StatelessWidget {
  const _AddActivityOrTimerButtons({Key? key}) : super(key: key);

  static final width = layout.actionButton.size * 2 + layout.tabBar.item.border;

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
        children: [
          _AddTab(
            key: TestKey.addActivityButton,
            text: translate.activity,
            icon: AbiliaIcons.plus,
            position: _AddTabPosition.left,
            ttsData: Translator.of(context).translate.addActivity,
            onTap: () => _onAddButtonPressed(
              context: context,
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
            onTap: () => _onAddButtonPressed(
              context: context,
              showActivities: false,
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
    final textStyle = (Theme.of(context).textTheme.caption ?? caption).copyWith(
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

Future _onAddButtonPressed({
  required BuildContext context,
  bool showActivities = true,
  bool showTimers = true,
}) {
  final authProviders = copiedAuthProviders(context);
  final addActivity =
      context.read<MemoplannerSettingBloc>().state.settings.addActivity;
  final basicActivityOption = addActivity.basicActivityOption;
  final newActivityOption = addActivity.newActivityOption;
  final showOnlyActivities = showActivities && !showTimers;

  if (showOnlyActivities && Config.isMP) {
    if (newActivityOption && !basicActivityOption) {
      return CreateNewPage.navigateToActivityWizardWithContext(
          context, authProviders);
    } else if (basicActivityOption && !newActivityOption) {
      return CreateNewPage.navigateToBasicActivityPicker(
          context, authProviders, addActivity.defaults);
    }
  }

  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: authProviders,
        child: CreateNewPage(
          showActivities: showActivities,
          showTimers: showTimers,
        ),
      ),
    ),
  );
}
