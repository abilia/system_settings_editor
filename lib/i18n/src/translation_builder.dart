import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';

class TranslationBuilder extends Builder {
  final BuilderOptions options;
  final deliminator = ';',
      dartExtension = '.dart',
      missingExtension = '.missing.csv',
      className = 'Translated',
      emptyToken = '&empty&';
  TranslationBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
        '.csv': [dartExtension, missingExtension]
      };
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final content = await buildStep.readAsString(buildStep.inputId);
    final translations = _parseTranslationsAndWriteMissing(content, buildStep);
    final languages = translations.keys;
    final buffer = StringBuffer();
    final emitter = DartEmitter();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// instead, modify ${buildStep.inputId.path} and run');
    buffer.writeln('// > flutter packages pub run build_runner build');
    buffer.writeln();
    buffer.writeln("import 'dart:ui';");

    buffer.writeln(_generateLocalesMap(languages, emitter));

    // generate abstract class
    final fields =
        translations.values.first.keys.map((field) => Field((fb) => fb
          ..modifier = FieldModifier.final$
          ..type = refer('String')
          ..name = field
          ..assignment = Code("'N/A'")));

    final langClass = Class((b) => b
      ..name = className
      ..abstract = true
      ..fields.addAll(fields));

    final a = langClass.accept(emitter);
    buffer.writeln(a);

    // generate translations
    for (var lang in languages) {
      final dictionary = translations[lang];
      final fields = translations.values.first.keys.map((field) => Field((fb) =>
          fb
            ..annotations =
                ListBuilder<Expression>([CodeExpression(Code('override'))])
            ..modifier = FieldModifier.final$
            ..type = refer('String')
            ..name = field
            ..assignment = Code(
                "'${dictionary.containsKey(field) ? dictionary[field] : 'N/A($lang)'}'")));

      final langClass = Class((b) => b
        ..name = lang.toUpperCase()
        ..extend = refer(className)
        ..fields.addAll(fields));

      final a = langClass.accept(emitter);
      buffer.writeln(a);
    }
    final id = buildStep.inputId.changeExtension(dartExtension);

    await buildStep.writeAsString(
        id, DartFormatter().format(buffer.toString()));
  }

  Map<String, Map<String, String>> _parseTranslationsAndWriteMissing(
    String content,
    BuildStep buildStep,
  ) {
    final missing = <String>{};
    final lines = LineSplitter().convert(content);
    final lineSplitted = lines.map((row) => row.split(deliminator)).toList();

    final dictionarise = lineSplitted.first // Fist heading row
        .sublist(1) // drop id heading
        .map((e) => MapEntry(e, <String, String>{}))
        .toList();
    if (dictionarise.isEmpty) return {};

    for (var entry in lineSplitted.sublist(1)) {
      // every row except heading row
      if (entry.isEmpty) continue;
      final valueId = entry[0]; // first column is id
      if (entry.length < dictionarise.length + 1 ||
          entry.any((value) => value.isEmpty)) {
        missing.add(entry.join(deliminator));
      }

      final roof = min(entry.length, dictionarise.length + 1);
      for (var i = 1; i < roof; i++) {
        final dictionary = dictionarise[i - 1].value;
        if (dictionary.containsKey(valueId)) {
          throw Exception('$valueId not a unique id!');
        }
        final value = entry[i];
        if (value.isEmpty) continue;
        dictionary[valueId] = value == emptyToken ? '' : value;
      }
    }

    if (missing.isNotEmpty) {
      final missingId = buildStep.inputId.changeExtension(missingExtension);
      buildStep.writeAsString(missingId, [lines.first, ...missing].join('\n'));
    }

    return Map.fromEntries(dictionarise);
  }

  StringSink _generateLocalesMap(
      Iterable<String> languages, DartEmitter emitter) {
    final def =
        languages.map((l) => "Locale('$l'): ${l.toUpperCase()}()").join(',\n');
    final locales = Class((b) => b
      ..name = 'Locales'
      ..fields = ListBuilder([
        Field(
          (fb) => fb
            ..static = true
            ..modifier = FieldModifier.final$
            ..name = 'language'
            ..assignment = Code('<Locale, Translated>{$def}'),
        )
      ]));
    return locales.accept(emitter);
  }
}
