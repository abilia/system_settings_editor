import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/info_item.dart';

void main() {
  test('Parse note info item', () {
    const testString =
        'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJub3RlIiwiZGF0YSI6eyJ0ZXh0IjoiVGVzdCJ9fV19';
    final infoItem = InfoItem.fromBase64(testString);
    expect((infoItem as NoteInfoItem).text, 'Test');
  });

  test('Parse null', () {
    const testString = null;
    final infoItem = InfoItem.fromBase64(testString);
    expect(infoItem, isInstanceOf<NoInfoItem>());
  });

  test('Parse empty', () {
    const testString = '';
    final infoItem = InfoItem.fromBase64(testString);
    expect(infoItem, isInstanceOf<NoInfoItem>());
  });

  test('Deserialize NoInfoItem', () {
    const infoItem = NoInfoItem();
    final json = infoItem.toJson();
    final base64 = infoItem.toBase64();
    expect(json, anyOf(isNull, isEmpty));
    expect(base64, anyOf(isNull, isEmpty));
  });

  test('Parse checklist', () {
    const testString =
        'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJjaGVja2xpc3QiLCJkYXRhIjp7ImNoZWNrZWQiOnsiMjAyMDA1MDYiOlsxLDRdfSwicXVlc3Rpb25zIjpbeyJpZCI6MCwibmFtZSI6InNob3J0cyIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS9zaG9ydHMuanBnIiwiZmlsZUlkIjoiOGM1ZDE0YTItYzIzZi00YTI0LTg0ZGItYmE5NjBhMGVjYjM4IiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjEsIm5hbWUiOiJ0LXRyw7ZqYSIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS90LXRyw7ZqYS5qcGciLCJmaWxlSWQiOiIxOGNlODhlOS04Zjc4LTRiZjQtYWM0Yy0wY2JhYmZlMmI3NzQiLCJjaGVja2VkIjp0cnVlfSx7ImlkIjoyLCJuYW1lIjoic3RydW1wb3IiLCJpbWFnZSI6Ii9IYW5kaS9Vc2VyL1BpY3R1cmUvc3RydW1wb3IuanBnIiwiZmlsZUlkIjoiYjdmY2YwYWMtNmQwYS00MzVlLWFlNTYtMzNlYzE0NDVmOTc5IiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjMsIm5hbWUiOiJneW1uYXN0aWtza29yIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2d5bW5hc3Rpa3Nrb3IuanBnIiwiZmlsZUlkIjoiZjIyYWMxZDgtYmNjNi00YTQ2LWE4ZWQtOGQ4OGExNjU1MjlkIiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjQsIm5hbWUiOiJ2YXR0ZW5mbGFza2EiLCJpbWFnZSI6Ii9IYW5kaS9Vc2VyL1BpY3R1cmUvdmF0dGVuZmxhc2thLmpwZyIsImZpbGVJZCI6IjMzYTBmMmE0LTRlYzktNDFmOC05MGU0LWU2YmU4OTdlNjcxZCIsImNoZWNrZWQiOnRydWV9LHsiaWQiOjUsIm5hbWUiOiJoYW5kZHVrIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2hhbmRkdWsuanBnIiwiZmlsZUlkIjoiNjgwZGQxOTEtMzBiMS00NDU0LTk5Y2YtMzNiN2I5OTVmYTMwIiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjYsIm5hbWUiOiJ0dsOlbCIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS9mbHl0YW5kZSB0dsOlbC5qcGciLCJmaWxlSWQiOiJmODI0OTQ3Ny0zYWRmLTRkODgtOWIxZS1lZWY4M2I0NzY0ZTEiLCJjaGVja2VkIjpmYWxzZX0seyJuYW1lIjoia2Fsc29uZ2VyXG5rYWxzb25nZXJcbmthbHNvbmdlclxua2Fsc29uZ2VyIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2thbHNvbmdlci5qcGciLCJmaWxlSWQiOiIwMDA1NmYxNi02OWJmLTRlZjEtOTBjNi1lOTFiNjY5MjliYWYiLCJpZCI6NywiY2hlY2tlZCI6ZmFsc2V9XX19XX0=';
    final infoItem = InfoItem.fromBase64(testString);
    expect(infoItem, isInstanceOf<Checklist>());
    final checklist = (infoItem as Checklist);
    expect(checklist.checked, {
      '20200506': [1, 4]
    });
    expect(checklist.questions, hasLength(8));
    expect(
      checklist.questions.first,
      const Question(
        id: 0,
        fileId: '8c5d14a2-c23f-4a24-84db-ba960a0ecb38',
        image: '/Handi/User/Picture/shorts.jpg',
        name: 'shorts',
        checked: false,
      ),
    );
  });

  test('BUG SGC-439 JSON without checked map checklist test', () {
    const testJson =
        '{"info-item":[{"type":"checklist","data":{"name":"Remember","fileId":"17c463bb-344b-4fef-b84b-afa8809d600b","image":"/Handi/User/Picture/remember.gif","questions":[{"name":"key","fileId":"aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e","id":0,"image":"/Handi/User/Picture/key.gif"},{"name":"purse","fileId":"e119ccd3-8949-4d82-8249-f4bdf1423afb","id":1,"image":"/Handi/User/Picture/purse.gif"},{"name":"mobile phone","fileId":"289fadbd-df10-4bb9-b9e0-692b343932b7","id":2,"image":"/Handi/User/Picture/mobile phone.gif"},{"name":"fruit","fileId":"9965aa32-3be0-46b6-bf12-53c7b33842a6","id":3,"image":"/Handi/User/Picture/fruit.gif"}]}}]}';
    final infoItem = InfoItem.fromJsonString(testJson);
    expect(infoItem, isInstanceOf<Checklist>());
    final checklist = infoItem as Checklist;
    expect(checklist.checked, isEmpty);
    expect(checklist.questions, hasLength(4));
    expect(
      checklist.questions.first,
      const Question(
        id: 0,
        fileId: 'aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e',
        image: '/Handi/User/Picture/key.gif',
        name: 'key',
        checked: false,
      ),
    );
  });

  test('BUG SGC-439 JSON without checked map checklist test, check test', () {
    const testJson =
        '{"info-item":[{"type":"checklist","data":{"name":"Remember","fileId":"17c463bb-344b-4fef-b84b-afa8809d600b","image":"/Handi/User/Picture/remember.gif","questions":[{"name":"key","fileId":"aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e","id":0,"image":"/Handi/User/Picture/key.gif"},{"name":"purse","fileId":"e119ccd3-8949-4d82-8249-f4bdf1423afb","id":1,"image":"/Handi/User/Picture/purse.gif"},{"name":"mobile phone","fileId":"289fadbd-df10-4bb9-b9e0-692b343932b7","id":2,"image":"/Handi/User/Picture/mobile phone.gif"},{"name":"fruit","fileId":"9965aa32-3be0-46b6-bf12-53c7b33842a6","id":3,"image":"/Handi/User/Picture/fruit.gif"}]}}]}';
    final decoded = jsonDecode(testJson)['info-item'][0]['data'];

    final infoItem = InfoItem.fromJsonString(testJson);
    final day = DateTime(2002, 11, 30);
    final checklist = (infoItem as Checklist);
    final checkedList = checklist.signOff(checklist.questions.first, day);
    final json = checkedList.toJson();
    expect(json['name'], decoded['name']);
    expect(json['fileId'], decoded['fileId']);
    expect(json['image'], decoded['image']);
    int nextId = 0;
    final jQ =
        (json['questions'] as List).map((j) => Question.fromJson(j, nextId++));
    final dQ = (decoded['questions'] as List)
        .map((j) => Question.fromJson(j, nextId++));
    expect(dQ, jQ);

    expect(json['checked'], hasLength(1));
  });

  test('json parse checklist no nulls', () {
    const testJson =
        '{"info-item":[{"type":"checklist","data":{"name":null,"fileId":null,"image":null,"questions":[{"name":null,"fileId":"aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e","id":0,"image":"/Handi/User/Picture/key.gif"},{"name":"purse","fileId":null,"id":1,"image":"/Handi/User/Picture/purse.gif"},{"name":"mobile phone","fileId":"289fadbd-df10-4bb9-b9e0-692b343932b7","id":2,"image":null}]}}]}';

    final infoItem = InfoItem.fromJsonString(testJson);
    expect(infoItem is Checklist, isTrue);
    expect(infoItem.typeId, Checklist.typeName);
    expect(infoItem.isEmpty, isFalse);
    final checklist = infoItem as Checklist;
    expect(checklist.name, isNotNull);
    expect(checklist.fileId, isNotNull);
    expect(checklist.image, isNotNull);
    final q0 = checklist.questions[0];
    final q1 = checklist.questions[1];
    final q2 = checklist.questions[2];
    expect(q0.name, isNotNull);
    expect(q0.fileId, isNotNull);
    expect(q0.image, isNotNull);
    expect(q1.name, isNotNull);
    expect(q1.fileId, isNotNull);
    expect(q1.image, isNotNull);
    expect(q2.name, isNotNull);
    expect(q2.fileId, isNotNull);
    expect(q2.image, isNotNull);
  });

  test('serialize and deserialize minimal checklist', () {
    final checkList = Checklist(
        questions: const [Question(id: 0, name: 'b')], checked: const {});
    final base64 = checkList.toBase64();
    final infoItem = InfoItem.fromBase64(base64);
    expect(checkList, infoItem);
  });

  test('serialize and deserialize checklist', () {
    final checkList = Checklist(questions: const [
      Question(
        id: 0,
        fileId: '8c5d14a2-c23f-4a24-84db-ba960a0ecb38',
        image: '/Handi/User/Picture/shorts.jpg',
        name: 'shorts',
      ),
      Question(
        id: 1,
        name: 't-tröja',
        image: '/Handi/User/Picture/t-tröja.jpg',
        fileId: '18ce88e9-8f78-4bf4-ac4c-0cbabfe2b774',
      ),
      Question(
        id: 2,
        name: 'strumpor',
        image: '/Handi/User/Picture/strumpor.jpg',
        fileId: 'b7fcf0ac-6d0a-435e-ae56-33ec1445f979',
      ),
      Question(
        id: 3,
        name: 'gymnastikskor',
        image: '/Handi/User/Picture/gymnastikskor.jpg',
        fileId: 'f22ac1d8-bcc6-4a46-a8ed-8d88a165529d',
      ),
      Question(
        id: 4,
        name: 'vattenflaska',
        image: '/Handi/User/Picture/vattenflaska.jpg',
        fileId: '33a0f2a4-4ec9-41f8-90e4-e6be897e671d',
      ),
      Question(
        id: 5,
        name: 'handduk',
        image: '/Handi/User/Picture/handduk.jpg',
        fileId: '680dd191-30b1-4454-99cf-33b7b995fa30',
      ),
      Question(
        id: 6,
        name: 'tvål',
        image: '/Handi/User/Picture/flytande tvål.jpg',
        fileId: 'f8249477-3adf-4d88-9b1e-eef83b4764e1',
      ),
      Question(
        name: 'kalsonger\nkalsonger\nkalsonger\nkalsonger',
        image: '/Handi/User/Picture/kalsonger.jpg',
        fileId: '00056f16-69bf-4ef1-90c6-e91b66929baf',
        id: 7,
      )
    ], checked: const {
      '20200506': {1, 4},
      '20200507': {0, 1, 2, 3, 4, 5, 6, 7},
      '20200508': {7},
    });
    final base64 = checkList.toBase64();
    final infoItem = InfoItem.fromBase64(base64);
    expect(checkList, infoItem);
  });

  test('Check item from checkist checklist', () {
    const question = Question(id: 0, name: 'b');
    final day = DateTime(2002, 02, 02);
    final checkList = Checklist(questions: const [question], checked: const {});
    final checkedList = checkList.signOff(question, day);
    expect(checkList == checkedList, isFalse);
    expect(checkList.isSignedOff(question, day), isFalse);
    expect(checkedList.isSignedOff(question, day), isTrue);
  });

  test('Uncheck item from checklist', () {
    const question = Question(id: 0, name: 'b');
    final day = DateTime(2002, 02, 02);
    final checkedList = Checklist(questions: const [
      question
    ], checked: const {
      '20020202': {0}
    });
    final uncheckedList = checkedList.signOff(question, day);
    expect(checkedList == uncheckedList, isFalse);
    expect(uncheckedList.isSignedOff(question, day), isFalse);
    expect(checkedList.isSignedOff(question, day), isTrue);
  });

  test('Not correct item from checklist checked', () {
    const question = Question(id: 0, name: 'b');
    final day = DateTime(2002, 02, 02);
    final checkedList = Checklist(questions: const [
      question
    ], checked: const {
      '20040202': {0},
      '20020202': {1}
    });

    expect(checkedList.isSignedOff(question, day), isFalse);
  });

  test(
      'BUG SGC-1518 No ids on checklist from base items gives all items same id',
      () {
    const testJsonWithoutIds = '{"info-item":['
        '{"type":"checklist",'
        '"data":'
        '{"name":"Remember",'
        '"fileId":"17c463bb-344b-4fef-b84b-afa8809d600b",'
        '"image":"/Handi/User/Picture/remember.gif",'
        '"questions":'
        '[{"name":"key",'
        '"fileId":"aef629ce-dbc1-4e8d-b3a8-0c4499a39b0e",'
        '"image":"/Handi/User/Picture/key.gif"},'
        '{"name":"purse","fileId":"e119ccd3-8949-4d82-8249-f4bdf1423afb",'
        '"image":"/Handi/User/Picture/purse.gif"},'
        '{"name":"mobile phone",'
        '"fileId":"289fadbd-df10-4bb9-b9e0-692b343932b7",'
        '"image":"/Handi/User/Picture/mobile phone.gif"},'
        '{"name":"fruit","fileId":"9965aa32-3be0-46b6-bf12-53c7b33842a6",'
        '"image":"/Handi/User/Picture/fruit.gif"}]}}]}';

    final infoItem = InfoItem.fromJsonString(testJsonWithoutIds) as Checklist;
    final ids = infoItem.questions.map((q) => q.id);
    expect(ids.length, ids.toSet().length);
  });
}
