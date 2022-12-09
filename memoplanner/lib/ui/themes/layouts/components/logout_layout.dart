import 'package:flutter/painting.dart';

class LogoutLayout {
  final double profilePictureSize,
      profileDistance,
      topDistance,
      modalIconSize,
      modalBottomRowSpacing,
      modalBodyTopSpacing,
      modalIconBottomSpacing,
      modalTitleBottomSpacing,
      modalBorderRadius,
      modalProgressIndicatorStrokeWidth,
      infoItemVerticalSpacing,
      infoItemHorizontalSpacing;
  final EdgeInsets modalBottomRowPadding,
      infoItemsCollectionPadding,
      infoPadding;

  const LogoutLayout({
    this.profilePictureSize = 84,
    this.profileDistance = 24,
    this.topDistance = 64,
    this.modalIconSize = 96,
    this.modalBottomRowSpacing = 8,
    this.modalBodyTopSpacing = 24,
    this.modalIconBottomSpacing = 16,
    this.modalTitleBottomSpacing = 8,
    this.modalBorderRadius = 12,
    this.modalProgressIndicatorStrokeWidth = 12,
    this.infoItemVerticalSpacing = 4,
    this.infoItemHorizontalSpacing = 0,
    this.modalBottomRowPadding = const EdgeInsets.all(12),
    this.infoItemsCollectionPadding = const EdgeInsets.only(top: 8),
    this.infoPadding = const EdgeInsets.all(16),
  });
}

class LogoutLayoutMedium extends LogoutLayout {
  const LogoutLayoutMedium({
    super.profilePictureSize = 126,
    super.profileDistance = 35,
    super.topDistance = 94,
    super.modalIconSize = 144,
    super.modalBottomRowSpacing = 12,
    super.modalBodyTopSpacing = 56,
    super.modalIconBottomSpacing = 32,
    super.modalTitleBottomSpacing = 16,
    super.modalBorderRadius = 20,
    super.modalProgressIndicatorStrokeWidth = 18,
    super.infoItemVerticalSpacing = 8,
    super.infoItemHorizontalSpacing = 12,
    super.modalBottomRowPadding = const EdgeInsets.all(16),
    super.infoItemsCollectionPadding = const EdgeInsets.only(top: 12),
  });
}
