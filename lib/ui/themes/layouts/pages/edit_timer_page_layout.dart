import 'package:flutter/material.dart';

class EditTimerPageLayout {
  final double inputTimeWidth, inputTimePadding;
  final EdgeInsets wheelPadding;

  const EditTimerPageLayout({
    this.inputTimeWidth = 120,
    this.inputTimePadding = 16,
    this.wheelPadding = const EdgeInsets.only(top: 11),
  });
}
