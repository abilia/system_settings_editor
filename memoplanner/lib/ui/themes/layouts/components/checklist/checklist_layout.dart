import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'checklist_question_layout.dart';

class ChecklistLayout {
  final ChecklistQuestionLayout question;
  final EdgeInsets listPadding,
      addNewQButtonPadding,
      addNewQIconPadding,
      previewPadding,
      previewTextPadding;
  final double addNewButtonHeight,
      previewCornerRadius,
      previewItemCornerRadius,
      previewImageSize,
      previewItemSpacing,
      previewExtrasHeight;
  final double previewImageBorderRadius;

  const ChecklistLayout({
    this.question = const ChecklistQuestionLayout(),
    this.listPadding = const EdgeInsets.all(12),
    this.addNewQButtonPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.addNewQIconPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.previewTextPadding = const EdgeInsets.only(left: 12, right: 8),
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
  });
}

class ChecklistLayoutMedium extends ChecklistLayout {
  const ChecklistLayoutMedium({
    ChecklistQuestionLayout? question,
  }) : super(
          question: question ?? const ChecklistQuestionLayoutMedium(),
          listPadding: const EdgeInsets.all(24),
          addNewQButtonPadding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          addNewQIconPadding: const EdgeInsets.only(left: 22, right: 16),
          previewTextPadding: const EdgeInsets.only(left: 16, right: 12),
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
        );
}

class ChecklistLayoutLarge extends ChecklistLayoutMedium {
  const ChecklistLayoutLarge()
      : super(
          question: const ChecklistQuestionLayoutLarge(),
        );
}
