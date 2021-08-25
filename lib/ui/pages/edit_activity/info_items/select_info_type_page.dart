import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectInfoTypePage extends StatefulWidget {
  final Type infoItemType;

  const SelectInfoTypePage({Key? key, required this.infoItemType})
      : super(key: key);

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
        iconData: AbiliaIcons.add_attachment,
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
                size: smallIconSize,
              ),
              text: Text(translate.infoTypeNone),
            ),
            SizedBox(height: 8.0.s),
            RadioField(
              key: TestKey.infoItemChecklistRadio,
              groupValue: infoItemType,
              onChanged: setSelectedType,
              value: Checklist,
              leading: const Icon(AbiliaIcons.ok),
              text: Text(translate.infoTypeChecklist),
            ),
            SizedBox(height: 8.0.s),
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
        backNavigationWidget: CancelButton(),
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
