import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

abstract class InfoItem extends Equatable {
  String get type;
  Map<String, dynamic> toJson();
  static InfoItem fromBase64(String base64) {
    try {
      if (base64?.isEmpty ?? true) return null;
      final jsonString = utf8.decode(base64Decode(base64));
      final json = jsonDecode(jsonString);
      final infoItem = json['info-item'][0];
      final data = infoItem['data'];
      switch (infoItem['type']) {
        case NoteInfoItem.typeName:
          return NoteInfoItem(data['text']);
        case Checklist.typeName:
          return Checklist.fromJson(data);
        default:
      }
    } catch (e) {
      print('Exception when trying to create info item $e');
    }
    return null;
  }

  String toBase64() => base64Encode(
        utf8.encode(
          json.encode(
            {
              'info-item': [
                {
                  'type': type,
                  'data': toJson(),
                }
              ],
            },
          ),
        ),
      );
}

class NoteInfoItem extends InfoItem {
  static const typeName = 'note';
  final String text;
  NoteInfoItem(this.text);

  @override
  List<Object> get props => [text];

  @override
  Map<String, dynamic> toJson() => {'text': text};

  @override
  String get type => typeName;
}

class Checklist extends InfoItem {
  static const typeName = 'checklist';
  final String image;
  final String name;
  final UnmodifiableListView<Question> questions;
  final UnmodifiableMapView<String, UnmodifiableSetView<int>> checked;
  final String fileId;

  Checklist({
    @required List<Question> questions,
    Map<String, Set<int>> checked = const {},
    this.image,
    this.name,
    this.fileId,
  })  : assert(questions != null),
        assert(questions.isNotEmpty),
        questions = UnmodifiableListView(questions),
        checked = UnmodifiableMapView(checked?.map(
                (key, value) => MapEntry(key, UnmodifiableSetView(value))) ??
            const {});

  Checklist copyWith({
    String image,
    String name,
    List<Question> questions,
    Map<String, Set<int>> checked,
    String fileId,
  }) =>
      Checklist(
        image: image ?? this.image,
        name: name ?? this.name,
        questions: questions ?? this.questions,
        checked: checked ?? this.checked,
        fileId: fileId ?? this.fileId,
      );

  final yyyyMMdd = DateFormat('yyyyMMdd').format;

  bool isSignedOff(Question question, DateTime day) {
    final key = yyyyMMdd(day);
    return checked[key]?.contains(question.id) ?? false;
  }

  Checklist signOff(Question question, DateTime day) {
    final key = yyyyMMdd(day);
    final id = question.id;
    final modChecked = checked
        .map((key, value) => MapEntry<String, Set<int>>(key, Set.from(value)));
    final checkThisDay = modChecked[key] ?? <int>{};
    if (!checkThisDay.remove(id)) {
      (checkThisDay.add(id));
    }
    modChecked[key] = checkThisDay;
    return copyWith(checked: modChecked);
  }

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        image: json['image'],
        fileId: json['fileId'],
        name: json['name'],
        questions: List<Question>.from(
          json['questions'].map((x) => Question.fromJson(x)),
        ),
        checked: Map.from(json['checked']
            .map((k, v) => MapEntry<String, Set<int>>(k, Set<int>.from(v)))),
      );

  Map<String, dynamic> toJson() => {
        'checked': checked.map(
            (key, value) => MapEntry<String, List<int>>(key, List.from(value))),
        'questions': List.from(questions.map((x) => x.toJson())),
        'image': image,
        'name': name,
        'fileId': fileId,
      };

  @override
  List<Object> get props => [image, name, fileId, questions, checked];

  @override
  String get type => typeName;
}

class Question extends Equatable {
  final String image;
  final String name;
  final int id;
  final String fileId;
  final bool checked;
  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (image?.isNotEmpty ?? false);
  bool get hasTitle => name?.isNotEmpty ?? false;

  const Question({
    this.image,
    this.name,
    @required this.id,
    this.fileId,
    this.checked = false,
  })  : assert(id != null),
        assert(id >= 0),
        assert((name != null) || (fileId != null) || (image != null));

  Question copyWith({
    String image,
    String name,
    int id,
    String fileId,
    bool checked,
  }) =>
      Question(
        image: image ?? this.image,
        name: name ?? this.name,
        id: id ?? this.id,
        fileId: fileId ?? this.fileId,
        checked: checked ?? this.checked,
      );

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        fileId: json['fileId'],
        checked: json['checked'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'fileId': fileId,
        'checked': checked,
      };

  @override
  List<Object> get props => [id, name, fileId, image, checked];
}
