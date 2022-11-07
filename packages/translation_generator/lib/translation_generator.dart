import 'package:build/build.dart';
import 'package:translation_generator/src/translation_builder.dart';

Builder translationGeneratorBuilder(BuilderOptions options) =>
    TranslationBuilder(options);
