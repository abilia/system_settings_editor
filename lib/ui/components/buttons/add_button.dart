import 'package:auto_size_text/auto_size_text.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

enum _addButtonConfiguration {
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
        _addButtonConfiguration>(
      selector: (state) => _configuration(
        state.displayNewActivity,
        state.displayNewTimer,
      ),
      builder: (context, configuration) {
        switch (configuration) {
          case _addButtonConfiguration.none:
            return SizedBox(width: layout.actionButton.size);
          case _addButtonConfiguration.mpGo:
            return const _AddButtonMPGO();
          case _addButtonConfiguration.onlyNewActivity:
            return const _AddActivityButton();
          case _addButtonConfiguration.onlyNewTimer:
            return const _AddTimerButton();
          case _addButtonConfiguration.newActivityAndNewTimer:
            return const _AddActivityOrTimerButtons();
        }
      },
    );
  }

  static double width(
    bool displayNewActivity,
    bool displayNewTimer,
  ) {
    switch (_configuration(displayNewActivity, displayNewTimer)) {
      case _addButtonConfiguration.none:
      case _addButtonConfiguration.mpGo:
      case _addButtonConfiguration.onlyNewActivity:
      case _addButtonConfiguration.onlyNewTimer:
        return layout.actionButton.size;
      case _addButtonConfiguration.newActivityAndNewTimer:
        return _AddActivityOrTimerButtons.width;
    }
  }

  static _addButtonConfiguration _configuration(
    bool displayNewActivity,
    bool displayNewTimer,
  ) {
    if (Config.isMPGO) {
      return displayNewActivity || displayNewTimer
          ? _addButtonConfiguration.mpGo
          : _addButtonConfiguration.none;
    }
    return displayNewActivity && displayNewTimer
        ? _addButtonConfiguration.newActivityAndNewTimer
        : displayNewActivity
            ? _addButtonConfiguration.onlyNewActivity
            : displayNewTimer
                ? _addButtonConfiguration.onlyNewTimer
                : _addButtonConfiguration.none;
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
      onPressed: () => _navigateToCreateNewPage(context: context),
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
      onPressed: () => _navigateToCreateNewPage(
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
      onPressed: () => _navigateToCreateNewPage(
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
            onTap: () => _navigateToCreateNewPage(
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
            onTap: () => _navigateToCreateNewPage(
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
    Key? key,
    required this.text,
    required this.icon,
    required this.position,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final _AddTabPosition position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = (Theme.of(context).textTheme.caption ?? caption).copyWith(
      height: 1,
      color: AbiliaColors.white,
    );
    final iconTheme = IconTheme.of(context).copyWith(
      color: AbiliaColors.white,
      size: layout.icon.small,
    );
    final borderSide = ligthShapeBorder.side.copyWith(
      width: layout.tabBar.item.border,
    );
    final isLeft = position == _AddTabPosition.left;

    return SizedBox(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                text,
                minFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
              SizedBox(height: layout.actionButton.spacing),
              IconTheme(
                data: iconTheme,
                child: Icon(
                  icon,
                  size: layout.icon.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _navigateToCreateNewPage({
  required BuildContext context,
  bool showActivities = true,
  bool showTimers = true,
}) {
  final authProviders = copiedAuthProviders(context);

  Navigator.of(context).push(
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
