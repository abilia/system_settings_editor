import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicActivityStepPage extends StatefulWidget {
  const BasicActivityStepPage({Key? key}) : super(key: key);

  @override
  _BasicActivityStepPageState createState() => _BasicActivityStepPageState();
}

class _BasicActivityStepPageState extends State<BasicActivityStepPage> {
  bool pickBasicActivityView = false;

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
            RadioField<bool>(
              key: TestKey.newActivityChoice,
              leading: Icon(AbiliaIcons.new_icon),
              text: Text(translate.newActivityChoice),
              value: false,
              groupValue: pickBasicActivityView,
              onChanged: (v) => setState(() => pickBasicActivityView = v!),
            ),
            SizedBox(height: 8.0.s),
            RadioField<bool>(
              key: TestKey.basicActivityChoice,
              leading: Icon(AbiliaIcons.folder),
              text: Text(translate.fromBasicActivity),
              value: true,
              groupValue: pickBasicActivityView,
              onChanged: (v) => setState(() => pickBasicActivityView = v!),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomNavigation(
        beforeOnNext: pickBasicActivityView
            ? () async {
                final b = await Navigator.of(context).push<BasicActivityData>(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child:
                          BlocProvider<SortableArchiveBloc<BasicActivityData>>(
                        create: (_) => SortableArchiveBloc<BasicActivityData>(
                          sortableBloc: BlocProvider.of<SortableBloc>(context),
                        ),
                        child: BasicActivityPickerPage(),
                      ),
                    ),
                  ),
                );
                if (b is BasicActivityDataItem) {
                  context.read<EditActivityBloc>().add(AddBasiActivity(b));
                  return true;
                }
                return false;
              }
            : null,
      ),
    );
  }
}
