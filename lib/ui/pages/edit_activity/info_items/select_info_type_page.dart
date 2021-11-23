import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectInfoTypePage extends StatefulWidget {
  final Type infoItemType;
  final bool showNote, showChecklist;

  const SelectInfoTypePage({
    Key? key,
    required this.infoItemType,
    required this.showNote,
    required this.showChecklist,
  }) : super(key: key);

  @override
  _SelectInfoTypePageState createState() => _SelectInfoTypePageState();
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
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.addAttachment,
        title: translate.selectInfoType,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
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
                size: layout.iconSize.small,
              ),
              text: Text(translate.infoTypeNone),
            ),
            SizedBox(height: 8.0.s),
            if (widget.showChecklist) ...[
              RadioField(
                key: TestKey.infoItemChecklistRadio,
                groupValue: infoItemType,
                onChanged: setSelectedType,
                value: Checklist,
                leading: const Icon(AbiliaIcons.ok),
                text: Text(translate.infoTypeChecklist),
              ),
              SizedBox(height: 8.0.s),
            ],
            if (widget.showNote)
              RadioField(
                key: TestKey.infoItemNoteRadio,
                groupValue: infoItemType,
                onChanged: setSelectedType,
                value: NoteInfoItem,
                leading: const Icon(AbiliaIcons.edit),
                text: Text(translate.infoTypeNote),
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
