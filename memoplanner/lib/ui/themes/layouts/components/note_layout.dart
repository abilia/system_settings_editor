import 'package:flutter/material.dart';

class NoteLayout {
  final EdgeInsets notePadding;
  final double lineOffset, previewExtrasHeight;

  const NoteLayout({
    this.notePadding = const EdgeInsets.fromLTRB(18, 10, 16, 24),
    this.lineOffset = 2,
    this.previewExtrasHeight = 24,
  });
}
