import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicActivityPickerPage extends StatelessWidget {
  const BasicActivityPickerPage({
    Key key,
    @required this.day,
  }) : super(key: key);
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveBloc<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (innerContext, state) => Scaffold(
        appBar: NewAbiliaAppBar(
          iconData: AbiliaIcons.basic_activity,
          title: state.allById[state.currentFolderId]?.data?.title() ??
              translate.basicActivities,
        ),
        body: SortableLibrary<BasicActivityData>(
          (Sortable<BasicActivityData> s) =>
              BasicActivityLibraryItem(sortable: s),
          translate.noBasicActivities,
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: GreyButton(
            text: translate.back,
            icon: AbiliaIcons.navigation_previous,
            onPressed: state.currentFolderId == null
                ? Navigator.of(context).maybePop
                : () => BlocProvider.of<SortableArchiveBloc<BasicActivityData>>(
                        context)
                    .add(NavigateUp()),
          ),
          forwardNavigationWidget: NextButton(
            onPressed:
                state.isSelected ? () => b(context, state.selected.data) : null,
          ),
        ),
      ),
    );
  }

  Future b(BuildContext context, BasicActivityData basicActivity) async =>
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: BlocProvider<EditActivityBloc>(
              create: (_) => EditActivityBloc.newActivity(
                activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                clockBloc: BlocProvider.of<ClockBloc>(context),
                memoplannerSettingBloc:
                    BlocProvider.of<MemoplannerSettingBloc>(context),
                day: day,
                basicActivityData: basicActivity,
              ),
              child: EditActivityPage(
                day: day,
                title: Translator.of(context).translate.newActivity,
              ),
            ),
          ),
          settings: RouteSettings(name: 'EditActivityPage new basic activity'),
        ),
        (r) => r.isFirst,
      );
}
