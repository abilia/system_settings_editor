class DisplaySettingsDialogLayout {
  final double height, width;

  const DisplaySettingsDialogLayout({
    this.height = double.infinity,
    this.width = double.infinity,
  });
}

class DisplaySettingsLayoutDialogMedium extends DisplaySettingsDialogLayout {
  const DisplaySettingsLayoutDialogMedium({
    double? height,
    double? width,
  }) : super(
          height: height ?? double.infinity,
          width: width ?? double.infinity,
        );
}

class DisplaySettingsDialogLayoutLarge
    extends DisplaySettingsLayoutDialogMedium {
  const DisplaySettingsDialogLayoutLarge() : super(width: 760, height: 1000);
}
