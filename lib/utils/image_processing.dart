import 'dart:math';

import 'package:exif/exif.dart' as exif;
import 'package:image/image.dart' as img;
import 'package:image/src/exif_data.dart';
import 'package:image/src/transform/flip.dart';
import 'package:image/src/transform/copy_rotate.dart';
import 'package:seagull/models/all.dart';

const IMAGE_ORIENTATION_FLAG = 'Image Orientation';
const IMAGE_QUALITY = 80;
const IMAGE_MAX_SIZE = 1500;

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
    height = min(IMAGE_MAX_SIZE, adjustedOrientation.height);
  } else {
    width = min(IMAGE_MAX_SIZE, adjustedOrientation.width);
  }

  final resizedOriginal = img.copyResize(
    adjustedOrientation,
    height: height,
    width: width,
  );

  return img.encodeJpg(resizedOriginal, quality: IMAGE_QUALITY);
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
  final orientationData = data[IMAGE_ORIENTATION_FLAG];
  final orientation = orientationData?.values.firstAsInt() ?? 1;
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

Future<ImageResponse> adjustRotationAndCreateThumbs(
    List<int> originalBytes) async {
  final adjustedImage = await adjustRotationToExif(originalBytes);
  final original = img.encodeJpg(adjustedImage, quality: IMAGE_QUALITY);

  final thumb =
      (max(adjustedImage.height, adjustedImage.width) > ImageThumb.THUMB_SIZE)
          ? img.encodeJpg(await resizeImg(adjustedImage, ImageThumb.THUMB_SIZE),
              quality: IMAGE_QUALITY)
          : original;

  return ImageResponse(
    originalImage: original,
    thumb: thumb,
  );
}
