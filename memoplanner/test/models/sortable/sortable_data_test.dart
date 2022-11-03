import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';

void main() {
  test(
      'BUG SGC-1518 No ids on checklist from base items gives all items same id',
      () {
    const testJsonWithoutIds = '{'
        '"name":"Remember",'
        '"fileId":"17c463bb-344b-4fef-b84b-afa8809d600b",'
        '"image":"/Handi/User/Picture/remember.gif",'
        '"icon":"/Handi/User/Picture/remember.gif",'
        '"checkItems":'
        '['
        '{'
        '"name":"key",'
        '"fileId":"aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e",'
        '"image":"/Handi/User/Picture/key.gif"},'
        '{'
        '"name":"purse","fileId":"e119ccd3-8949-4d82-8249-f4bdf1423afb",'
        '"image":"/Handi/User/Picture/purse.gif"'
        '},'
        '{'
        '"name":"mobile phone",'
        '"fileId":"289fadbd-df10-4bb9-b9e0-692b343932b7",'
        '"image":"/Handi/User/Picture/mobile phone.gif"'
        '},'
        '{'
        '"name":"fruit","fileId":"9965aa32-3be0-46b6-bf12-53c7b33842a6",'
        '"image":"/Handi/User/Picture/fruit.gif"'
        '}'
        ']'
        '}';

    final sortableData = ChecklistData.fromJson(testJsonWithoutIds);
    final ids = sortableData.checklist.questions.map((q) => q.id);
    expect(ids.length, ids.toSet().length);
  });
}
