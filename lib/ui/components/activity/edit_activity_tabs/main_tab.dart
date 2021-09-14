import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MainTab extends StatefulWidget {
  MainTab({
    Key? key,
    required this.editActivityState,
  }) : super(key: key);

  final EditActivityState editActivityState;

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with EditActivityTab {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.editActivityState.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.showCategories != current.showCategories ||
          previous.activityTypeEditable != current.activityTypeEditable,
      builder: (context, memoSettingsState) => VerticalScrollArrows(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding:
              EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
          children: <Widget>[
            separatedAndPadded(
                ActivityNameAndPictureWidget(widget.editActivityState)),
            separatedAndPadded(DateAndTimeWidget(widget.editActivityState)),
            if (memoSettingsState.showCategories)
              CollapsableWidget(
                collapsed:
                    activity.fullDay || !memoSettingsState.activityTypeEditable,
                child: separatedAndPadded(CategoryWidget(activity)),
              ),
            separatedAndPadded(CheckableAndDeleteAfterWidget(activity)),
            padded(AvailableForWidget(activity)),
          ],
        ),
      ),
    );
  }
}
