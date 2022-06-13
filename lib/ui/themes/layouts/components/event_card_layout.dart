import 'package:seagull/ui/all.dart';

class EventCardLayout {
  final double height,
      marginSmall,
      marginLarge,
      imageSize,
      categorySideOffset,
      iconSize,
      titleImagePadding,
      borderWidth,
      currentBorderWidth,
      timerWheelSize,
      privateIconSize,
      titleSubtitleSpacing;

  final EdgeInsets imagePadding;
  final EdgeInsets crossPadding;
  final EdgeInsets titlePadding;
  final EdgeInsets statusesPadding;
  final EdgeInsets timerWheelPadding;
  final EdgeInsets cardIconPadding;

  const EventCardLayout({
    this.height = 56,
    this.marginSmall = 6,
    this.marginLarge = 10,
    this.imageSize = 48,
    this.categorySideOffset = 43,
    this.iconSize = 18,
    this.titleImagePadding = 10,
    this.borderWidth = 1.5,
    this.currentBorderWidth = 3,
    this.timerWheelSize = 44,
    this.crossPadding = const EdgeInsets.all(4),
    this.imagePadding = const EdgeInsets.only(left: 4),
    this.titlePadding = const EdgeInsets.only(left: 8, right: 8),
    this.statusesPadding = const EdgeInsets.only(right: 8, bottom: 3),
    this.timerWheelPadding = const EdgeInsets.only(right: 5),
    this.cardIconPadding = const EdgeInsets.only(right: 4),
    this.privateIconSize = 24,
    this.titleSubtitleSpacing = 6,
  });
}

class EventCardLayoutMedium extends EventCardLayout {
  const EventCardLayoutMedium({
    double? height,
    double? imageSize,
    double? timerWheelSize,
  }) : super(
          height: height ?? 104,
          marginSmall: 8,
          marginLarge: 16,
          imageSize: imageSize ?? 88,
          categorySideOffset: 76,
          timerWheelSize: 72,
          timerWheelPadding: const EdgeInsets.only(right: 10),
          iconSize: 24.0,
          titleImagePadding: 12,
          borderWidth: 4,
          currentBorderWidth: 6,
          imagePadding: const EdgeInsets.only(left: 8),
          crossPadding: const EdgeInsets.all(8),
          titlePadding: const EdgeInsets.only(left: 12, right: 12),
          statusesPadding: const EdgeInsets.only(right: 12, bottom: 8),
          privateIconSize: 36,
          cardIconPadding: const EdgeInsets.only(right: 6),
          titleSubtitleSpacing: 12,
        );
}

class EventCardLayoutLarge extends EventCardLayoutMedium {
  const EventCardLayoutLarge()
      : super(
          height: 120,
          imageSize: 104,
          timerWheelSize: 84,
        );
}
