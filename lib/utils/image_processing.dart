import 'dart:math';

import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:image/src/exif_data.dart';
import 'package:image/src/transform/flip.dart';
import 'package:image/src/transform/copy_rotate.dart';

import 'package:seagull/models/all.dart';

const IMAGE_ORIENTATION_FLAG = 'Image Orientation';
const IMAGE_QUALITY = 80;
const IMAGE_MAX_SIZE = 1500;

class ImageResult {
  final List<int> originalImage;
  final List<int> thumbImage;

  ImageResult({
    this.originalImage,
    this.thumbImage,
  });
}

Future<ImageResult> imageProcessingIsolate(List<int> originalData) async {
  final adjustedOrientation = await adjustRotationToExif(originalData);

  int width, height, thumbWidth, thumbHeight;
  if (adjustedOrientation.height > adjustedOrientation.width) {
    height = min(IMAGE_MAX_SIZE, adjustedOrientation.height);
    thumbHeight = ImageThumb.DEFAULT_THUMB_SIZE;
  } else {
    width = min(IMAGE_MAX_SIZE, adjustedOrientation.width);
    thumbWidth = ImageThumb.DEFAULT_THUMB_SIZE;
  }

  final resizedOriginal = img.copyResize(
    adjustedOrientation,
    height: height,
    width: width,
  );

  final thumbImage = img.copyResize(
    adjustedOrientation,
    height: thumbHeight,
    width: thumbWidth,
  );

  final jpgFile = img.encodeJpg(resizedOriginal, quality: IMAGE_QUALITY);
  final thumbJpgFile = img.encodeJpg(thumbImage, quality: IMAGE_QUALITY);
  return ImageResult(originalImage: jpgFile, thumbImage: thumbJpgFile);
}

Future<img.Image> adjustRotationToExif(List<int> imageBytes) async {
  final img.Image image = img.decodeImage(imageBytes);
  img.Image bakedImage = img.Image.from(image);
  Map<String, IfdTag> data = await readExifFromBytes(imageBytes);
  final orientationData = data[IMAGE_ORIENTATION_FLAG];
  final int orientation =
      orientationData?.values?.firstWhere((_) => true, orElse: () => 1);
  if (orientation == 1) {
    return bakedImage;
  }

  bakedImage.exif = ExifData();
  switch (orientation) {
    case 2:
      return flipHorizontal(bakedImage);
    case 3:
      return flip(bakedImage, Flip.both);
    case 4:
      return flipHorizontal(copyRotate(bakedImage, 180));
    case 5:
      return flipHorizontal(copyRotate(bakedImage, 90));
    case 6:
      return copyRotate(bakedImage, 90);
    case 7:
      return flipHorizontal(copyRotate(bakedImage, -90));
    case 8:
      return copyRotate(bakedImage, -90);
  }
  return bakedImage;
}
