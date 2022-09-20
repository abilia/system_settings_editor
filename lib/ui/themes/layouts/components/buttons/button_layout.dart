import 'package:flutter/painting.dart';

class ButtonLayout {
  final double baseButtonMinHeight;
  final Size redButtonMinSize, secondaryActionButtonSize;
  final EdgeInsets textButtonInsets,
      actionButtonIconTextPadding,
      startBasicTimerPadding;

  const ButtonLayout({
    this.baseButtonMinHeight = 64,
    this.redButtonMinSize = const Size(0, 48),
    this.secondaryActionButtonSize = const Size(40, 40),
    this.textButtonInsets =
        const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    this.actionButtonIconTextPadding =
        const EdgeInsets.fromLTRB(10, 10, 20, 10),
    this.startBasicTimerPadding = const EdgeInsets.fromLTRB(0, 4, 4, 4),
  });
}

class ButtonLayoutMedium extends ButtonLayout {
  const ButtonLayoutMedium()
      : super(
          baseButtonMinHeight: 96,
          redButtonMinSize: const Size(0, 72),
          secondaryActionButtonSize: const Size(64, 64),
          textButtonInsets:
              const EdgeInsets.symmetric(horizontal: 48, vertical: 30),
          actionButtonIconTextPadding:
              const EdgeInsets.fromLTRB(15, 15, 30, 15),
          startBasicTimerPadding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        );
}
