import 'dart:convert';
import 'package:meta/meta.dart';

class InfoItem {
  static InfoItem fromBase64(String base64) {
    try {
      final jsonString = utf8.decode(base64Decode(base64));
      final json = jsonDecode(jsonString);
      final infoItem = json['info-item'][0];
      final type = infoItem['type'];
      final data = infoItem['data'];
      switch (type) {
        case 'note':
          return NoteInfoItem(data['text']);
        case 'checklist':
          return Checklist.fromJson(data);
          break;
        default:
      }
    } catch (e) {
      print('Exception when trying to create info item from base 64 string');
    }
    return null;
  }
}

class NoteInfoItem extends InfoItem {
  final String text;
  NoteInfoItem(this.text);
}

class Checklist extends InfoItem {
  final String image;
  final String name;
  final List<Question> questions;
  final Map<String, List<int>> checked;
  final String fileId;

  Checklist({
    @required this.image,
    @required this.name,
    @required this.questions,
    @required this.checked,
    @required this.fileId,
  });

  Checklist copyWith({
    String image,
    String name,
    List<Question> questions,
    Map<String, List<int>> checked,
    String fileId,
  }) =>
      Checklist(
        image: image ?? this.image,
        name: name ?? this.name,
        questions: questions ?? this.questions,
        checked: checked ?? this.checked,
        fileId: fileId ?? this.fileId,
      );

  String toRawJson() => json.encode(toJson());

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        image: json['image'],
        name: json['name'],
        questions: List<Question>.from(
            json['questions'].map((x) => Question.fromJson(x))),
        checked: Map.from(json['checked']).map((k, v) =>
            MapEntry<String, List<int>>(k, List<int>.from(v.map((x) => x)))),
        fileId: json['fileId'],
      );

  Map<String, dynamic> toJson() => {
        'image': image,
        'name': name,
        'questions': List<dynamic>.from(questions.map((x) => x.toJson())),
        'checked': Map.from(checked).map((k, v) =>
            MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
        'fileId': fileId,
      };
}

class Question {
  final String image;
  final String name;
  final int id;
  final String fileId;
  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (image?.isNotEmpty ?? false);

  Question({
    @required this.image,
    @required this.name,
    @required this.id,
    @required this.fileId,
  });

  Question copyWith({
    String image,
    String name,
    int id,
    String fileId,
  }) =>
      Question(
        image: image ?? this.image,
        name: name ?? this.name,
        id: id ?? this.id,
        fileId: fileId ?? this.fileId,
      );

  factory Question.fromRawJson(String str) =>
      Question.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        image: json['image'],
        name: json['name'],
        id: json['id'],
        fileId: json['fileId'],
      );

  Map<String, dynamic> toJson() => {
        'image': image,
        'name': name,
        'id': id,
        'fileId': fileId,
      };
}
