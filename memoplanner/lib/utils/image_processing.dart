import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
// ignore: implementation_imports
import 'package:image/src/exif_data.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/models/all.dart';
import 'package:meta/meta.dart';

const imageQuality = 80;
const imageMaxSize = 1500;

class ImageResponse {
  final List<int> originalImage;
  final List<int> thumb;

  ImageResponse({
    required this.originalImage,
    required this.thumb,
  });
}

class ImageRequest {
  final List<int> data;
  final String id;
  final String path;

  ImageRequest({
    required this.data,
    required this.id,
    required this.path,
  });
}

Future<List<int>> adjustImageSizeAndRotation(List<int> originalData) async {
  final adjustedOrientation = await adjustRotationToExif(originalData);

  int? width, height;
  if (adjustedOrientation.height > adjustedOrientation.width) {
    height = min(imageMaxSize, adjustedOrientation.height);
  } else {
    width = min(imageMaxSize, adjustedOrientation.width);
  }

  final resizedOriginal = copyResize(
    adjustedOrientation,
    height: height,
    width: width,
  );

  return encodeJpg(resizedOriginal, quality: imageQuality);
}

Future<Image> resizeImg(Image image, int size) async {
  int? width, height;
  if (image.height > image.width) {
    height = min(size, image.height);
  } else {
    width = min(size, image.width);
  }

  return copyResize(
    image,
    height: height,
    width: width,
  );
}

Future<Image> adjustRotationToExif(List<int> imageBytes) async {
  final image = decodeImage(imageBytes);
  if (image == null) throw 'could not decode image bytes $imageBytes';
  final bakedImage = Image.from(image);
  final exif = bakedImage.exif;

  bakedImage.exif = ExifData();
  if (!exif.hasOrientation) return bakedImage;
  switch (exif.orientation) {
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

Future<ImageResponse> adjustRotationAndCreateThumbs(
    List<int> originalBytes) async {
  final adjustedImage = await adjustRotationToExif(originalBytes);
  final original = encodeJpg(adjustedImage, quality: imageQuality);

  final thumb =
      (max(adjustedImage.height, adjustedImage.width) > ImageThumb.thumbSize)
          ? encodeJpg(await resizeImg(adjustedImage, ImageThumb.thumbSize),
              quality: imageQuality)
          : original;

  return ImageResponse(
    originalImage: original,
    thumb: thumb,
  );
}

String getImageNameFromDate(DateTime time) {
  final locale = Platform.localeName;
  return getImageName(locale, time);
}

@visibleForTesting
String getImageName(String locale, DateTime time) {
  return DateFormat.yMd(locale).format(time);
}
