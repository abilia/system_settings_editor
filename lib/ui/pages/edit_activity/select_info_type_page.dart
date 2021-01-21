import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectInfoTypePage extends StatefulWidget {
  final Type infoItemType;

  const SelectInfoTypePage({Key key, @required this.infoItemType})
      : super(key: key);

  @override
  _SelectInfoTypePageState createState() => _SelectInfoTypePageState();
}

class _SelectInfoTypePageState extends State<SelectInfoTypePage> {
  Type infoItemType;

  @override
  void initState() {
    super.initState();
    infoItemType = widget.infoItemType;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        iconData: AbiliaIcons.add_attachment,
        title: translate.selectInfoType,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField(
              key: TestKey.infoItemNoneRadio,
              groupValue: infoItemType,
              onChanged: onChanged,
              value: NoInfoItem,
              leading: const Icon(
                AbiliaIcons.information,
                size: smallIconSize,
              ),
              text: Text(translate.infoTypeNone),
            ),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.infoItemChecklistRadio,
              groupValue: infoItemType,
              onChanged: onChanged,
              value: Checklist,
              leading: const Icon(AbiliaIcons.ok),
              text: Text(translate.infoTypeChecklist),
            ),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.infoItemNoteRadio,
              groupValue: infoItemType,
              onChanged: onChanged,
              value: NoteInfoItem,
              leading: const Icon(AbiliaIcons.edit),
              text: Text(translate.infoTypeNote),
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
        forwardNavigationWidget: GreenButton(
          icon: AbiliaIcons.ok,
          text: translate.ok,
          onPressed: () => Navigator.of(context).maybePop(infoItemType),
        ),
      ),
    );
  }

  void onChanged(Type t) => setState(() => infoItemType = t);
}
