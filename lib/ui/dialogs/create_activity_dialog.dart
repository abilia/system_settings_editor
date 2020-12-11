import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CreateActivityDialogResponse {
  final BasicActivityDataItem basicActivityData;

  CreateActivityDialogResponse({this.basicActivityData});
}

class CreateActivityDialog extends StatefulWidget {
  const CreateActivityDialog({Key key}) : super(key: key);

  @override
  _CreateActivityDialogState createState() => _CreateActivityDialogState(false);
}

class _CreateActivityDialogState extends State<CreateActivityDialog>
    with SingleTickerProviderStateMixin {
  bool pickBasicActivityView;

  _CreateActivityDialogState(this.pickBasicActivityView);
  @override
  Widget build(BuildContext context) {
    return pickBasicActivityView
        ? buildPickBasicActivity()
        : buildSelectNewOrBase();
  }

  Widget buildPickBasicActivity() {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveBloc<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (innerContext, sortableArchiveState) => ViewDialog(
        verticalPadding: 0,
        backButton: sortableArchiveState.currentFolderId == null
            ? null
            : SortableLibraryBackButton<BasicActivityData>(),
        heading: getSortableArchiveHeading(sortableArchiveState),
        child: SortableLibrary<BasicActivityData>(
          (Sortable<BasicActivityData> s) => BasicActivityLibraryItem(
            basicActivityData: s.data,
          ),
          translate.noBasicActivities,
        ),
      ),
    );
  }

  Text getSortableArchiveHeading(SortableArchiveState state) {
    final folderName = state.allById[state.currentFolderId]?.data?.title() ??
        Translator.of(context).translate.basicActivities;
    return Text(folderName, style: abiliaTheme.textTheme.headline6);
  }

  Widget buildSelectNewOrBase() {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      heading: Text(
        translate.createActivity,
        style: abiliaTextTheme.headline6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            key: TestKey.newActivityButton,
            leading: Icon(
              AbiliaIcons.new_icon,
              size: smallIconSize,
            ),
            text: Text(
              translate.newActivityChoice,
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async => await Navigator.of(context)
                .maybePop(CreateActivityDialogResponse()),
          ),
          SizedBox(height: 8.0),
          PickField(
            key: TestKey.selectBasicActivityButton,
            leading: Icon(AbiliaIcons.day, size: smallIconSize),
            text: Text(
              translate.fromBasicActivity,
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async => setState(
              () {
                pickBasicActivityView = true;
              },
            ),
          ),
        ],
      ),
    );
  }
}
