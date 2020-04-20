import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/info_item.dart';

void main() {
  test('Parse note info item', () {
    final testString =
        'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJub3RlIiwiZGF0YSI6eyJ0ZXh0IjoiVGVzdCJ9fV19';
    final infoItem = InfoItem.fromBase64(testString);
    expect(infoItem.type, InfoItemType.NOTE);
    expect((infoItem.infoItemData as NoteData).text, 'Test');
  });
}
