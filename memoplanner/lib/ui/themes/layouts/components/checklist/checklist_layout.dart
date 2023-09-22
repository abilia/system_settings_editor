import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'checklist_question_layout.dart';

class ChecklistLayout {
  final ChecklistQuestionLayout question;
  final EdgeInsets previewPadding;
  final double addNewButtonHeight,
      previewCornerRadius,
      previewItemCornerRadius,
      previewImageSize,
      previewItemSpacing,
      previewExtrasHeight,
      previewListPadding;
  final double previewImageBorderRadius;
  final double dividerHeight;

  const ChecklistLayout({
    this.question = const ChecklistQuestionLayout(),
    this.previewListPadding = 8,
    this.previewPadding = const EdgeInsets.only(
      top: 4,
      bottom: 4,
      left: 12,
      right: 8,
    ),
    this.addNewButtonHeight = 48,
    this.previewCornerRadius = 8,
    this.previewItemCornerRadius = 6,
    this.previewImageSize = 16,
    this.previewItemSpacing = 4,
    this.previewImageBorderRadius = 4,
    this.previewExtrasHeight = 40,
    this.dividerHeight = 1,
  });
}

class ChecklistLayoutMedium extends ChecklistLayout {
  const ChecklistLayoutMedium({
    ChecklistQuestionLayout? question,
  }) : super(
          question: question ?? const ChecklistQuestionLayoutMedium(),
          previewListPadding: 12,
          previewPadding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          addNewButtonHeight: 64,
          previewCornerRadius: 16,
          previewItemCornerRadius: 12,
          previewImageSize: 24,
          previewItemSpacing: 8,
          previewImageBorderRadius: 8,
          previewExtrasHeight: 56,
          dividerHeight: 2,
        );
}

class ChecklistLayoutLarge extends ChecklistLayoutMedium {
  const ChecklistLayoutLarge()
      : super(
          question: const ChecklistQuestionLayoutLarge(),
        );
}
