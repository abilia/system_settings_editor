import 'dart:math';

import 'package:exif/exif.dart' as exif;
import 'package:image/image.dart' as img;
// ignore: implementation_imports
import 'package:image/src/exif_data.dart';
import 'package:seagull/models/all.dart';

const imageOrientationFlag = 'Image Orientation';
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

  final resizedOriginal = img.copyResize(
    adjustedOrientation,
    height: height,
    width: width,
  );

  return img.encodeJpg(resizedOriginal, quality: imageQuality);
}

Future<img.Image> resizeImg(img.Image image, int size) async {
  int? width, height;
  if (image.height > image.width) {
    height = min(size, image.height);
  } else {
    width = min(size, image.width);
  }

  return img.copyResize(
    image,
    height: height,
    width: width,
  );
}

Future<img.Image> adjustRotationToExif(List<int> imageBytes) async {
  final image = img.decodeImage(imageBytes);
  if (image == null) throw 'could not decode image bytes $imageBytes';
  final bakedImage = img.Image.from(image);
  final data = await exif.readExifFromBytes(imageBytes);
  final orientationData = data[imageOrientationFlag];
  final orientation = orientationData?.values.firstAsInt() ?? 1;
  if (orientation == 1) {
    return bakedImage;
  }

  bakedImage.exif = ExifData();
  switch (orientation) {
    case 2:
      return img.flipHorizontal(bakedImage);
    case 3:
      return img.flip(bakedImage, img.Flip.both);
    case 4:
      return img.flipHorizontal(img.copyRotate(bakedImage, 180));
    case 5:
      return img.flipHorizontal(img.copyRotate(bakedImage, 90));
    case 6:
      return img.copyRotate(bakedImage, 90);
    case 7:
      return img.flipHorizontal(img.copyRotate(bakedImage, -90));
    case 8:
      return img.copyRotate(bakedImage, -90);
  }
  return bakedImage;
}

Future<ImageResponse> adjustRotationAndCreateThumbs(
    List<int> originalBytes) async {
  final adjustedImage = await adjustRotationToExif(originalBytes);
  final original = img.encodeJpg(adjustedImage, quality: imageQuality);

  final thumb =
      (max(adjustedImage.height, adjustedImage.width) > ImageThumb.thumbSize)
          ? img.encodeJpg(await resizeImg(adjustedImage, ImageThumb.thumbSize),
              quality: imageQuality)
          : original;

  return ImageResponse(
    originalImage: original,
    thumb: thumb,
  );
}
