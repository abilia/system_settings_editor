import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class SelectInfoTypePage extends StatefulWidget {
  final Type infoItemType;
  final bool showNote, showChecklist;

  const SelectInfoTypePage({
    required this.infoItemType,
    required this.showNote,
    required this.showChecklist,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SelectInfoTypePageState();
}

class _SelectInfoTypePageState extends State<SelectInfoTypePage> {
  late Type infoItemType;

  @override
  void initState() {
    super.initState();
    infoItemType = widget.infoItemType;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final videoFeatureToggle = context
        .read<FeatureToggleCubit>()
        .state
        .isToggleEnabled(FeatureToggle.videoInActivity);
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.addAttachment,
        title: translate.selectInfoType,
      ),
      body: Padding(
        padding: layout.templates.m1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField(
              key: TestKey.infoItemNoneRadio,
              groupValue: infoItemType,
              onChanged: setSelectedType,
              value: NoInfoItem,
              leading: Icon(
                AbiliaIcons.information,
                size: layout.icon.small,
              ),
              text: Text(translate.infoTypeNone),
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            if (widget.showChecklist) ...[
              RadioField(
                key: TestKey.infoItemChecklistRadio,
                groupValue: infoItemType,
                onChanged: setSelectedType,
                value: Checklist,
                leading: const Icon(AbiliaIcons.ok),
                text: Text(translate.addChecklist),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
            ],
            if (widget.showNote) ...[
              RadioField(
                key: TestKey.infoItemNoteRadio,
                groupValue: infoItemType,
                onChanged: setSelectedType,
                value: NoteInfoItem,
                leading: const Icon(AbiliaIcons.edit),
                text: Text(translate.addNote),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
            ],
            if (videoFeatureToggle)
              RadioField(
                groupValue: infoItemType,
                onChanged: setSelectedType,
                value: VideoInfoItem,
                leading: const Icon(AbiliaIcons.videoCall),
                text: const Text('Add video'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(infoItemType),
        ),
      ),
    );
  }

  void setSelectedType(Type? t) {
    if (t != null) setState(() => infoItemType = t);
  }
}
