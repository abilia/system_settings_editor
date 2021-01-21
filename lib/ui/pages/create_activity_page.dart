import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/basic_activity_picker_page.dart';

class CreateActivityPage extends StatefulWidget {
  final DateTime day;
  const CreateActivityPage({
    Key key,
    @required this.day,
  }) : super(key: key);

  @override
  _CreateActivityPageState createState() => _CreateActivityPageState(false);
}

class _CreateActivityPageState extends State<CreateActivityPage>
    with SingleTickerProviderStateMixin {
  bool pickBasicActivityView;

  _CreateActivityPageState(this.pickBasicActivityView);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: translate.createActivity,
        iconData: AbiliaIcons.plus,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioField(
                key: TestKey.newActivityChoice,
                leading: Icon(AbiliaIcons.new_icon),
                text: Text(translate.newActivityChoice),
                value: false,
                groupValue: pickBasicActivityView,
                onChanged: (v) => setState(() => pickBasicActivityView = v)),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.basicActivityChoice,
              leading: Icon(AbiliaIcons.folder),
              text: Text(translate.fromBasicActivity),
              value: true,
              groupValue: pickBasicActivityView,
              onChanged: (v) => setState(() => pickBasicActivityView = v),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: GreyButton(
          icon: AbiliaIcons.close_program,
          text: translate.cancel,
          onPressed: Navigator.of(context).maybePop,
        ),
        forwardNavigationWidget: NextButton(
          onPressed: () async {
            if (pickBasicActivityView) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: BlocProvider<SortableArchiveBloc<BasicActivityData>>(
                      create: (_) => SortableArchiveBloc<BasicActivityData>(
                        sortableBloc: BlocProvider.of<SortableBloc>(context),
                      ),
                      child: BasicActivityPickerPage(day: widget.day),
                    ),
                  ),
                ),
              );
            } else {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: authContext,
                    child: BlocProvider<EditActivityBloc>(
                      create: (_) => EditActivityBloc.newActivity(
                        activitiesBloc:
                            BlocProvider.of<ActivitiesBloc>(authContext),
                        clockBloc: BlocProvider.of<ClockBloc>(authContext),
                        memoplannerSettingBloc:
                            BlocProvider.of<MemoplannerSettingBloc>(
                                authContext),
                        day: widget.day,
                      ),
                      child: EditActivityPage(
                        day: widget.day,
                        title: translate.newActivity,
                      ),
                    ),
                  ),
                  settings:
                      RouteSettings(name: 'EditActivityPage new activity'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
