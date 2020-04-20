import 'dart:convert';

class InfoItem {
  final InfoItemType type;
  final InfoItemData infoItemData;

  InfoItem(this.type, this.infoItemData);

  static InfoItem fromBase64(String base64) {
    try {
      final jsonString = utf8.decode(base64Decode(base64));
      final json = jsonDecode(jsonString);
      final infoItem = json['info-item'][0];
      final type = infoItem['type'];
      if (type == 'note') {
        return NoteInfoItem(NoteData(infoItem['data']['text']));
      }
    } catch (e) {
      print('Exception when trying to create info item from base 64 string');
    }
    return null;
  }
}

class NoteInfoItem extends InfoItem {
  NoteInfoItem(NoteData noteData) : super(InfoItemType.NOTE, noteData);
}

class InfoItemData {}

class NoteData extends InfoItemData {
  final String text;

  NoteData(this.text);
}

enum InfoItemType {
  NOTE,
}
