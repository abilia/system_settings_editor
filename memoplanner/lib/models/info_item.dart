import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:memoplanner/utils/all.dart';

abstract class InfoItem extends Equatable {
  const InfoItem();
  static final _log = Logger((InfoItem).toString());
  String get typeId;

  static InfoItem get none => const NoInfoItem();

  bool get isEmpty;

  @visibleForTesting
  Map<String, dynamic> toJson();
  static InfoItem fromBase64(String? base64) {
    try {
      if (base64 == null || base64.isEmpty) return const NoInfoItem();
      final jsonString = utf8.decode(base64Decode(base64));
      return fromJsonString(jsonString);
    } catch (e, stacktrace) {
      _log.severe(
        'Exception when trying to utf8/base64 decode info item: $base64',
        e,
        stacktrace,
      );
    }
    return const NoInfoItem();
  }

  static InfoItem fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return const NoInfoItem();
    try {
      final json = jsonDecode(jsonString);
      final infoItem = json['info-item'][0];
      final data = infoItem['data'];
      final type = infoItem['type'];
      switch (type) {
        case NoteInfoItem.typeName:
          return NoteInfoItem(data['text']);
        case Checklist.typeName:
          return Checklist.fromJson(data);
        case UrlInfoItem.typeName:
          return UrlInfoItem(data['url']);
        case VideoInfoItem.typeName:
          return VideoInfoItem(data['videoId']);
        default:
          _log.warning('unknown info item type', type);
      }
    } catch (e, stacktrace) {
      _log.severe(
        'Exception when trying to json decode info item: $jsonString',
        e,
        stacktrace,
      );
    }
    return const NoInfoItem();
  }

  String toBase64() => base64Encode(utf8.encode(infoItemJson()));

  String infoItemJson() => this is NoInfoItem
      ? ''
      : json.encode(
          {
            'info-item': [
              {
                'type': typeId,
                'data': toJson(),
              }
            ],
          },
        );
}

class NoInfoItem extends InfoItem {
  const NoInfoItem();
  @override
  List<Object> get props => [];
  @override
  Map<String, dynamic> toJson() => {};
  @override
  String toBase64() => '';
  @override
  String get typeId => '';
  @override
  bool get isEmpty => true;
}

class NoteInfoItem extends InfoItem {
  static const typeName = 'note';
  final String text;
  const NoteInfoItem([this.text = '']);

  @override
  List<Object> get props => [text];

  @override
  Map<String, dynamic> toJson() => {'text': text};

  @override
  String get typeId => typeName;
  @override
  bool get isEmpty => text.isEmpty;
}

class UrlInfoItem extends InfoItem {
  static const typeName = 'url';
  final String url;
  const UrlInfoItem([this.url = '']);

  @override
  List<Object> get props => [url];

  @override
  Map<String, dynamic> toJson() => {'url': url};

  @override
  String get typeId => typeName;
  @override
  bool get isEmpty => url.isEmpty;
}

class VideoInfoItem extends InfoItem {
  static const typeName = 'video';
  final String videoId;
  const VideoInfoItem([this.videoId = '']);

  @override
  List<Object> get props => [videoId];

  @override
  Map<String, dynamic> toJson() => {'videoId': videoId};

  @override
  String get typeId => typeName;
  @override
  bool get isEmpty => videoId.isEmpty;
}

class Checklist extends InfoItem {
  static const typeName = 'checklist';
  final String image;
  final String name;
  final UnmodifiableListView<Question> questions;
  final UnmodifiableMapView<String, UnmodifiableSetView<int>> checked;
  final String fileId;
  final String icon; // only used for groups

  bool get hasImage => fileId.isNotEmpty || image.isNotEmpty;

  Checklist({
    Iterable<Question> questions = const <Question>[],
    Map<String, Set<int>> checked = const {},
    this.image = '',
    this.name = '',
    this.fileId = '',
    this.icon = '',
  })  : questions = UnmodifiableListView(questions),
        checked = UnmodifiableMapView(checked
            .map((key, value) => MapEntry(key, UnmodifiableSetView(value))));

  Checklist copyWith({
    String? image,
    String? name,
    Iterable<Question>? questions,
    Map<String, Set<int>>? checked,
    String? fileId,
  }) =>
      Checklist(
        image: image ?? this.image,
        name: name ?? this.name,
        questions: questions ?? this.questions,
        checked: checked ?? this.checked,
        fileId: fileId ?? this.fileId,
      );

  static final dayKey = DateFormat('yyyyMMdd').format;

  bool isSignedOff(Question question, DateTime day) {
    final key = dayKey(day);
    return checked[key]?.contains(question.id) ?? false;
  }

  bool allSignedOff(DateTime day) {
    final key = dayKey(day);
    final containsAnyUnchecked = questions.any((question) {
      final checkedOnDay = checked[key]?.contains(question.id) ?? false;
      return !checkedOnDay;
    });
    return !containsAnyUnchecked;
  }

  Checklist signOff(Question question, DateTime day) {
    final key = dayKey(day);
    final id = question.id;
    final modifiableChecked =
        checked.map((k, v) => MapEntry<String, Set<int>>(k, Set.from(v)));
    final checkThisDay = modifiableChecked[key] ?? <int>{};
    if (!checkThisDay.remove(id)) {
      checkThisDay.add(id);
    }
    modifiableChecked[key] = checkThisDay;
    return copyWith(checked: modifiableChecked);
  }

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        image: json['image'] ?? '',
        fileId: json['fileId'] ?? '',
        name: json['name'] ?? '',
        questions: json['questions'] != null
            ? List<Question>.from(
                (json['questions'] as List)
                    .mapIndexed((i, x) => Question.fromJson(x, i)),
              )
            : List<Question>.empty(),
        checked: Map.from(json['checked']?.map(
                (k, v) => MapEntry<String, Set<int>>(k, Set<int>.from(v))) ??
            {}),
      );

  @override
  Map<String, dynamic> toJson() => {
        'checked':
            checked.map((k, v) => MapEntry<String, List<int>>(k, List.from(v))),
        'questions': List.from(questions.map((x) => x.toJson())),
        'image': image.nullOnEmpty(),
        'name': name.nullOnEmpty(),
        'fileId': fileId.nullOnEmpty(),
      };

  @override
  List<Object> get props => [image, name, fileId, questions, checked];

  @override
  String get typeId => typeName;
  @override
  bool get isEmpty => questions.isEmpty;
}

class Question extends Equatable {
  final String image;
  final String name;
  final int id;
  final String fileId;
  final bool checked;
  bool get hasImage => fileId.isNotEmpty || image.isNotEmpty;
  bool get hasTitle => name.isNotEmpty;

  const Question({
    required this.id,
    this.name = '',
    this.fileId = '',
    this.image = '',
    this.checked = false,
  });

  Question copyWith({
    String? image,
    String? name,
    int? id,
    String? fileId,
    bool? checked,
  }) =>
      Question(
        image: image ?? this.image,
        name: name ?? this.name,
        id: id ?? this.id,
        fileId: fileId ?? this.fileId,
        checked: checked ?? this.checked,
      );

  factory Question.fromJson(Map<String, dynamic> json, int fallbackId) =>
      Question(
        id: json['id'] ?? fallbackId,
        name: json['name'] ?? '',
        image: json['image'] ?? json['imageName'] ?? '',
        fileId: json['fileId'] ?? '',
        checked: json['checked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.nullOnEmpty(),
        'image': image.nullOnEmpty(),
        'fileId': fileId.nullOnEmpty(),
        'checked': checked,
      };

  @override
  List<Object> get props => [id, name, fileId, image, checked];

  @override
  bool get stringify => true;
}
