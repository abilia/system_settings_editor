import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, editActivityState) {
        final activity = editActivityState.activity;
        return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          buildWhen: (previous, current) =>
              previous.showCategories != current.showCategories ||
              previous.activityTypeEditable != current.activityTypeEditable,
          builder: (context, memoSettingsState) =>
              ArrowScrollable.verticalScrollArrows(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              padding: EditActivityTab.rightPadding
                  .add(EditActivityTab.bottomPadding),
              children: <Widget>[
                separatedAndPadded(const ActivityNameAndPictureWidget()),
                separatedAndPadded(const DateAndTimeWidget()),
                if (memoSettingsState.showCategories)
                  CollapsableWidget(
                    collapsed: activity.fullDay ||
                        !memoSettingsState.activityTypeEditable,
                    child: separatedAndPadded(CategoryWidget(activity)),
                  ),
                separatedAndPadded(CheckableAndDeleteAfterWidget(activity)),
                padded(AvailableForWidget(activity)),
              ],
            ),
          ),
        );
      },
    );
  }
}
