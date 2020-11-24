import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key key,
    @required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      key: TestKey.addActivity,
      child: Icon(AbiliaIcons.plus),
      onPressed: () async {
        final response = await showViewDialog<CreateActivityDialogResponse>(
          context: context,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<SortableArchiveBloc<BasicActivityData>>(
                create: (_) => SortableArchiveBloc<BasicActivityData>(
                  sortableBloc: BlocProvider.of<SortableBloc>(context),
                ),
              ),
              BlocProvider<UserFileBloc>.value(
                value: BlocProvider.of<UserFileBloc>(context),
              ),
            ],
            child: CreateActivityDialog(),
          ),
        );
        if (response != null) {
          await Navigator.of(context).push(
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
                    basicActivityData: response.basicActivityData,
                  ),
                  child: EditActivityPage(
                    day: day,
                    title: Translator.of(context).translate.newActivity,
                  ),
                ),
              ),
              settings: RouteSettings(name: 'EditActivityPage new activity'),
            ),
          );
        }
      },
    );
  }
}
