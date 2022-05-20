import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, editActivityState) {
        final activity = editActivityState.activity;
        return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          buildWhen: (previous, current) =>
              previous.showCategories != current.showCategories ||
              previous.settings.editActivity != current.settings.editActivity,
          builder: (context, memoSettingsState) => ScrollArrows.vertical(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: layout.templates.m1.bottom),
              children: <Widget>[
                const ActivityNameAndPictureWidget().pad(m1WithZeroBottom),
                const Divider().pad(dividerPadding),
                const DateAndTimeWidget().pad(m1WithZeroBottom),
                if (memoSettingsState.showCategories ||
                    memoSettingsState.settings.editActivity.type)
                  CollapsableWidget(
                    collapsed: activity.fullDay,
                    child: Column(
                      children: [
                        const Divider().pad(dividerPadding),
                        CategoryWidget(activity).pad(m1WithZeroBottom),
                      ],
                    ),
                  ),
                if (memoSettingsState.settings.editActivity.checkable ||
                    memoSettingsState.settings.editActivity.removeAfter) ...[
                  const Divider().pad(dividerPadding),
                  CheckableAndDeleteAfterWidget(activity).pad(m1WithZeroBottom),
                ],
                if (memoSettingsState.settings.editActivity.availability) ...[
                  const Divider().pad(dividerPadding),
                  AvailableForWidget(activity).pad(m1WithZeroBottom),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
