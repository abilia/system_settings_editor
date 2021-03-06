import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MainTab extends StatefulWidget {
  MainTab({
    Key key,
    @required this.editActivityState,
    @required this.memoplannerSettingsState,
    @required this.day,
  }) : super(key: key);

  final EditActivityState editActivityState;
  final MemoplannerSettingsState memoplannerSettingsState;
  final DateTime day;

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with EditActivityTab {
  ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.editActivityState.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
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
            if (widget.memoplannerSettingsState.showCategories)
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
