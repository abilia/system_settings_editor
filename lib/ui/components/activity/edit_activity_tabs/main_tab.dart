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
              previous.activityTypeEditable != current.activityTypeEditable,
          builder: (context, memoSettingsState) => ScrollArrows.vertical(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: layout.formPadding.m1Bottom),
              children: <Widget>[
                const ActivityNameAndPictureWidget().pad(m1TopPadding),
                const Divider().pad(dividerPadding),
                const DateAndTimeWidget().pad(m1TopPadding),
                if (memoSettingsState.showCategories)
                  CollapsableWidget(
                    collapsed: activity.fullDay ||
                        !memoSettingsState.activityTypeEditable,
                    child: Column(
                      children: [
                        const Divider().pad(dividerPadding),
                        CategoryWidget(activity).pad(m1TopPadding),
                      ],
                    ),
                  ),
                const Divider().pad(dividerPadding),
                CheckableAndDeleteAfterWidget(activity).pad(m1TopPadding),
                const Divider().pad(dividerPadding),
                AvailableForWidget(activity).pad(m1TopPadding),
              ],
            ),
          ),
        );
      },
    );
  }
}
