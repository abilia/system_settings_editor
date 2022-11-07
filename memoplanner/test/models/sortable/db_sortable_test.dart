import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';

void main() {
  testWidgets('checklist folder fromDbMap', (tester) async {
    DbSortable.fromDbMap({
      'id': '08487d21-d5d8-4f22-a6e9-16339604ead3',
      'revision': 761,
      'deleted': 0,
      'type': 'checklist',
      'data': '{"name":"NEW FOLDRE","icon":""}',
      'is_group': 1,
      'group_id': null,
      'sort_order': 'T',
      'visible': 1,
      'dirty': 0
    });
  });

  testWidgets('note fromDbMap', (tester) async {
    DbSortable.fromDbMap({
      'id': '235a0e63-33a3-40b0-b51c-07344caacac5',
      'revision': 788,
      'deleted': 0,
      'type': 'note',
      'data':
          '{"name":"FOPLAKT","icon":"/handi/user/picture/arnold.jpg","fileId":"43f000c8-e13d-412c-9a33-ddf3333849f7"}',
      'is_group': 1,
      'group_id': null,
      'sort_order': 'I',
      ' visible': 1,
      'dirty': 0
    });
  });

  testWidgets('checklist subfolder fromDbMap', (tester) async {
    DbSortable.fromDbMap({
      'id': 'cfa56b5a-9c35-4d94-a3d5-524029abaded',
      'revision': 764,
      'deleted': 0,
      'type': 'checklist',
      'data': '{"name":"Subfolder","icon":""}',
      'is_group': 1,
      'group_id': '98f9d92f-e239-4820-87b4-19a2e1bd5ffb',
      'sort_order': 'T',
      'visible': 1,
      'dirty': 0
    });
  });

  testWidgets('checklist from json, to db from fromDbMap', (tester) async {
    final raw = DbSortable.fromJson({
      'id': '9df7773f-f79c-44e5-9cef-8079fc069362',
      'owner': 195,
      'revision': 737,
      'revision_time': 1580116946121,
      'deleted': false,
      'type': 'checklist',
      'data':
          '{"image":"/Handi/User/Picture/remember.gif","name":"Remember","checkItems":[{"imageName":"/Handi/User/Picture/key.gif","name":"key","id":0,"fileId":"e930aa61-b938-481a-8e54-f045abf21b1e"},{"imageName":"/Handi/User/Picture/purse.gif","name":"purse","id":1,"fileId":"b06d0856-50dc-4767-8ee7-160af151df8b"},{"imageName":"/Handi/User/Picture/mobile phone.gif","name":"mobile phone","id":2,"fileId":"a27ad820-4362-440a-8256-2cb9e6743fa6"},{"imageName":"/Handi/User/Picture/fruit.gif","name":"fruit","id":3,"fileId":"4a6762c6-f1e9-46dc-bbef-2b7c444345ac"}],"fileId":"c4e93180-defa-40b3-b962-0eb608ec1c29"}',
      'is_group': false,
      'group_id': null,
      'sort_order': 'R',
      'visible': true
    });
    final dbMap = raw.toMapForDb();
    final item = DbSortable.fromDbMap(dbMap);
    expect(item.model.data, isA<ChecklistData>());
    final checkistData = item.model.data as ChecklistData;
    expect(
      checkistData.checklist.image,
      '/Handi/User/Picture/remember.gif',
    );
    expect(
      checkistData.checklist.fileId,
      'c4e93180-defa-40b3-b962-0eb608ec1c29',
    );
    expect(
      checkistData.checklist.name,
      'Remember',
    );

    expect(
      checkistData.checklist.questions,
      const [
        Question(
          image: '/Handi/User/Picture/key.gif',
          name: 'key',
          id: 0,
          fileId: 'e930aa61-b938-481a-8e54-f045abf21b1e',
        ),
        Question(
          image: '/Handi/User/Picture/purse.gif',
          name: 'purse',
          id: 1,
          fileId: 'b06d0856-50dc-4767-8ee7-160af151df8b',
        ),
        Question(
          image: '/Handi/User/Picture/mobile phone.gif',
          name: 'mobile phone',
          id: 2,
          fileId: 'a27ad820-4362-440a-8256-2cb9e6743fa6',
        ),
        Question(
          image: '/Handi/User/Picture/fruit.gif',
          name: 'fruit',
          id: 3,
          fileId: '4a6762c6-f1e9-46dc-bbef-2b7c444345ac',
        ),
      ],
    );
  });
}
