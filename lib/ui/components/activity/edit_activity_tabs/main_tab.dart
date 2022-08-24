import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final activity = context
        .select<EditActivityCubit, Activity>((cubit) => cubit.state.activity);
    final editActivitySettings =
        context.select<MemoplannerSettingBloc, EditActivitySettings>(
            (cubit) => cubit.state.settings.addActivity.editActivity);
    final showCategories = context.select<MemoplannerSettingBloc, bool>(
        (cubit) => cubit.state.settings.calendar.categories.show);

    return ScrollArrows.vertical(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: layout.templates.m1.bottom),
        children: <Widget>[
          const ActivityNameAndPictureWidget()
              .pad(layout.templates.m1.withoutBottom),
          const Divider().pad(dividerPadding),
          const DateAndTimeWidget().pad(layout.templates.m1.withoutBottom),
          if (showCategories)
            CollapsableWidget(
              collapsed: activity.fullDay,
              child: Column(
                children: [
                  const Divider().pad(dividerPadding),
                  CategoryWidget(activity)
                      .pad(layout.templates.m1.withoutBottom),
                ],
              ),
            ),
          if (editActivitySettings.checkable ||
              editActivitySettings.removeAfter) ...[
            const Divider().pad(dividerPadding),
            CheckableAndDeleteAfterWidget(activity)
                .pad(layout.templates.m1.withoutBottom),
          ],
          if (editActivitySettings.availability) ...[
            const Divider().pad(dividerPadding),
            AvailableForWidget(activity).pad(layout.templates.m1.withoutBottom),
          ],
        ],
      ),
    );
  }
}
