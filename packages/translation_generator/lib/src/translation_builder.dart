import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class TranslationBuilder extends Builder {
  final BuilderOptions options;
  final deliminator = '\t',
      comment = '#',
      dartExtension = '.g.dart',
      missingExtension = '.missing.tsv',
      className = 'Translated',
      emptyToken = '&empty&';
  TranslationBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
        '.tsv': [dartExtension, missingExtension]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final content = await buildStep.readAsString(buildStep.inputId);
    final translations =
        await _parseTranslationsAndWriteMissing(content, buildStep);
    final languages = translations.keys;
    final buffer = StringBuffer();
    final emitter = DartEmitter();

    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln('// instead, modify ${buildStep.inputId.path} and run')
      ..writeln('// > flutter packages pub run build_runner build')
      ..writeln()
      ..writeln('// ignore_for_file: overridden_fields')
      ..writeln()
      ..writeln("import 'dart:ui';")
      ..writeln(_generateLocalesMap(languages, emitter));

    // generate abstract class
    final fallbackLang = translations.values.first;
    final fields = fallbackLang.keys.map(
      (id) => Field(
        (fb) => fb
          ..modifier = FieldModifier.final$
          ..type = refer('String')
          ..name = id
          ..assignment = _getTranslation(fallbackLang[id]),
      ),
    );

    buffer.writeln(Class((b) => b
      ..name = className
      ..abstract = true
      ..constructors =
          ListBuilder<Constructor>([Constructor((c) => c.constant = true)])
      ..fields.addAll(fields)).accept(emitter));

    // generate translations
    for (var entry in translations.entries) {
      final dictionary = entry.value;
      final lang = entry.key;
      final overrideFields = lang == languages.first
          ? <Field>[]
          : fields.where((f) => dictionary.containsKey(f.name)).map(
                (f) => f.rebuild(
                  (fb) => fb
                    ..annotations = ListBuilder<Expression>(
                        [const CodeExpression(Code('override'))])
                    ..assignment = _getTranslation(dictionary[f.name]),
                ),
              );

      buffer.writeln(Class((b) => b
        ..name = lang.toUpperCase()
        ..constructors =
            ListBuilder<Constructor>([Constructor((c) => c.constant = true)])
        ..extend = refer(className)
        ..fields.addAll(overrideFields)).accept(emitter));
    }

    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(dartExtension),
        DartFormatter().format(buffer.toString()));
  }

  Code? _getTranslation(String? translation) => translation != null
      ? Code(
          translation.contains("'") ? '''"$translation"''' : "'$translation'")
      : null;

  Future<Map<String, Map<String, String>>> _parseTranslationsAndWriteMissing(
    String content,
    BuildStep buildStep,
  ) async {
    final missing = <String>{};
    final lines = const LineSplitter().convert(content);
    final lineSplitted = lines
        .where((line) =>
            line.trim().isNotEmpty) // ignore empty lines ands comments
        .where((line) => !line.startsWith(comment)) // ignore comments
        .map((row) => row.split(deliminator))
        .toList();

    final dictionaries = lineSplitted.first // First heading row
        .sublist(1) // drop id heading
        .map((e) => MapEntry(e, <String, String>{}))
        .toList();
    if (dictionaries.isEmpty) return {};

    for (var entry in lineSplitted.sublist(1)) {
      // every row except heading row
      if (entry.isEmpty) continue;
      final valueId = entry[0]; // first column is id

      if (entry.length < dictionaries.length + 1 ||
          entry.any((value) => value.isEmpty)) {
        missing.add(entry.join(deliminator));
      }

      for (var i = 1; i < min(entry.length, dictionaries.length + 1); i++) {
        final dictionary = dictionaries[i - 1].value;
        if (dictionary.containsKey(valueId)) {
          throw Exception('$valueId not an unique id!');
        }
        final value = entry[i];
        if (value.isEmpty) continue;
        dictionary[valueId] = value == emptyToken ? '' : value;
      }
    }

    if (missing.isNotEmpty) {
      final missingId = buildStep.inputId.changeExtension(missingExtension);
      await buildStep.writeAsString(
          missingId, [lines.first, ...missing, ''].join('\n'));
    }

    return Map.fromEntries(dictionaries);
  }

  StringSink _generateLocalesMap(
      Iterable<String> languages, DartEmitter emitter) {
    final translationEntry = languages
        .map((l) => "const Locale('$l'): const ${l.toUpperCase()}()")
        .join(',\n');
    final locales = Class((b) => b
      ..name = 'Locales'
      ..fields = ListBuilder([
        Field(
          (fb) => fb
            ..static = true
            ..modifier = FieldModifier.final$
            ..name = 'language'
            ..assignment = Code('{$translationEntry}'),
        )
      ]));
    return locales.accept(emitter);
  }
}
