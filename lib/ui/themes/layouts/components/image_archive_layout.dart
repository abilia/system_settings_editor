class ImageArchiveLayout {
  final double imageWidth,
      imageHeight,
      imagePadding,
      fullscreenImagePadding,
      imageNameBottomPadding,
      aspectRatio;

  const ImageArchiveLayout({
    this.imageWidth = 84,
    this.imageHeight = 86,
    this.imagePadding = 4,
    this.fullscreenImagePadding = 12,
    this.imageNameBottomPadding = 2,
    this.aspectRatio = 1,
  });
}

class ImageArchiveLayoutMedium extends ImageArchiveLayout {
  const ImageArchiveLayoutMedium()
      : super(
          imageWidth: 140,
          imageHeight: 129,
          imagePadding: 3,
          imageNameBottomPadding: 3,
          fullscreenImagePadding: 18,
          aspectRatio: 188 / 180,
        );
}
