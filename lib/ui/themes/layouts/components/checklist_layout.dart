import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistLayout {
  final ChecklistQuestionLayout question;
  final EdgeInsets listPadding, addNewQButtonPadding, addNewQIconPadding;
  const ChecklistLayout({
    this.question = const ChecklistQuestionLayout(),
    this.listPadding = const EdgeInsets.all(12),
    this.addNewQButtonPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.addNewQIconPadding = const EdgeInsets.symmetric(horizontal: 12),
  });
}

class ChecklistQuestionLayout {
  final EdgeInsets imagePadding, titlePadding, iconPadding;
  final double imageSize, viewHeight, fontSize, lineHeight;

  const ChecklistQuestionLayout({
    this.imagePadding = const EdgeInsets.fromLTRB(6, 4, 0, 4),
    this.titlePadding = const EdgeInsets.fromLTRB(8, 10, 0, 10),
    this.iconPadding = const EdgeInsets.fromLTRB(14, 12, 12, 12),
    this.imageSize = 40,
    this.viewHeight = 48,
    this.fontSize = 16,
    this.lineHeight = 28,
  });

  TextStyle get textStyle => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          height: lineHeight / fontSize,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class ChecklistQuestionLayoutMedium extends ChecklistQuestionLayout {
  const ChecklistQuestionLayoutMedium({
    double? viewHeight,
    double? imageSize,
    double? fontSize,
    double? lineHeight,
  }) : super(
          imagePadding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          titlePadding: const EdgeInsets.fromLTRB(12, 16, 0, 16),
          iconPadding: const EdgeInsets.fromLTRB(16, 22, 22, 22),
          viewHeight: viewHeight ?? 80,
          imageSize: imageSize ?? 60,
          fontSize: fontSize ?? 28,
          lineHeight: lineHeight ?? 48,
        );
}

class ChecklistQuestionLayoutLarge extends ChecklistQuestionLayoutMedium {
  const ChecklistQuestionLayoutLarge()
      : super(
          viewHeight: 88,
          imageSize: 72,
          fontSize: 36,
          lineHeight: 52,
        );
}
