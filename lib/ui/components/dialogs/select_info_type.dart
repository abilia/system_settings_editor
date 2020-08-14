import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class SelectInfoTypeDialog extends StatelessWidget {
  final Type infoItemType;

  const SelectInfoTypeDialog({Key key, @required this.infoItemType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.selectInfoType, style: theme.textTheme.headline6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            key: TestKey.infoItemNoneRadio,
            groupValue: infoItemType,
            onChanged: Navigator.of(context).maybePop,
            value: NoInfoItem,
            child: Row(
              children: <Widget>[
                const Icon(
                  AbiliaIcons.information,
                  size: smallIconSize,
                ),
                const SizedBox(width: 12),
                Text(translate.infoTypeNone),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.infoItemChecklistRadio,
            groupValue: infoItemType,
            onChanged: Navigator.of(context).maybePop,
            value: Checklist,
            child: Row(
              children: <Widget>[
                const Icon(
                  AbiliaIcons.ok,
                  size: smallIconSize,
                ),
                const SizedBox(width: 12),
                Text(translate.infoTypeChecklist),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.infoItemNoteRadio,
            groupValue: infoItemType,
            onChanged: Navigator.of(context).maybePop,
            value: NoteInfoItem,
            child: Row(
              children: <Widget>[
                const Icon(
                  AbiliaIcons.edit,
                  size: smallIconSize,
                ),
                const SizedBox(width: 12),
                Text(translate.infoTypeNote),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
