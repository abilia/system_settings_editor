class TimeInputLayout {
  final double width,
      height,
      amPmHeight,
      amPmWidth,
      timeDashAlignValue,
      amPmDistance,
      inputKeyboardDistance,
      keyboardButtonHeight,
      keyboardButtonWidth,
      keyboardButtonPadding;

  const TimeInputLayout({
    this.width = 120,
    this.height = 64,
    this.amPmHeight = 48,
    this.amPmWidth = 59,
    this.timeDashAlignValue = 14,
    this.amPmDistance = 2,
    this.inputKeyboardDistance = 44,
    this.keyboardButtonHeight = 48,
    this.keyboardButtonWidth = 80,
    this.keyboardButtonPadding = 8,
  });
}

class TimeInputLayoutMedium extends TimeInputLayout {
  const TimeInputLayoutMedium()
      : super(
          height: 96,
          width: 180,
          amPmHeight: 72,
          amPmWidth: 88.5,
          timeDashAlignValue: 21,
          amPmDistance: 3,
          inputKeyboardDistance: 96,
          keyboardButtonHeight: 88,
          keyboardButtonWidth: 160,
          keyboardButtonPadding: 12,
        );
}
