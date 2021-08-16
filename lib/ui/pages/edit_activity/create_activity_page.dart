// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CreateActivityPage extends StatefulWidget {
  final DateTime day;
  const CreateActivityPage({
    Key key,
    @required this.day,
  }) : super(key: key);

  @override
  _CreateActivityPageState createState() => _CreateActivityPageState(false);
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  bool pickBasicActivityView;

  _CreateActivityPageState(this.pickBasicActivityView);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.createActivity,
        iconData: AbiliaIcons.plus,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0.s, horizontal: 16.0.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioField(
              key: TestKey.newActivityChoice,
              leading: Icon(AbiliaIcons.new_icon),
              text: Text(translate.newActivityChoice),
              value: false,
              groupValue: pickBasicActivityView,
              onChanged: (v) => setState(() => pickBasicActivityView = v),
            ),
            SizedBox(height: 8.0.s),
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
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: NextButton(onPressed: nextButtonPressed),
      ),
    );
  }

  Future nextButtonPressed() async {
    if (pickBasicActivityView) {
      final basicActivity = await Navigator.of(context).push<BasicActivityData>(
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
      if (basicActivity != null) {
        await navigateToEditActivityPage(basicActivity);
      }
    } else {
      await navigateToEditActivityPage();
    }
  }

  Future navigateToEditActivityPage([BasicActivityData basicActivity]) async {
    final saved = await Navigator.of(context).push(
      EditActivityPage.route(context, widget.day, basicActivity),
    );
    if (saved != null) {
      await Navigator.of(context).maybePop();
    }
  }
}
