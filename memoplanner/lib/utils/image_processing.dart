import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:memoplanner/models/all.dart';

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

const _orientationTag = 0x0112;
Future<Image> adjustRotationToExif(Uint8List imageBytes) async {
  final image = decodeImage(imageBytes);
  if (image == null) throw 'could not decode image bytes $imageBytes';
  final bakedImage = Image.from(image);
  final exif = bakedImage.exif;

  bakedImage.exif = ExifData();
  final hasOrientation = exif.hasTag(_orientationTag);
  if (!hasOrientation) return bakedImage;
  final orientation = exif.getTag(_orientationTag)?.toInt();
  switch (orientation) {
    case 2:
      return flipHorizontal(bakedImage);
    case 3:
      return flip(bakedImage, direction: FlipDirection.both);
    case 4:
      return flipHorizontal(copyRotate(bakedImage, angle: 180));
    case 5:
      return flipHorizontal(copyRotate(bakedImage, angle: 90));
    case 6:
      return copyRotate(bakedImage, angle: 90);
    case 7:
      return flipHorizontal(copyRotate(bakedImage, angle: -90));
    case 8:
      return copyRotate(bakedImage, angle: -90);
  }
  return bakedImage;
}

Future<ImageResponse> adjustRotationAndCreateThumbs(
    Uint8List originalBytes) async {
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
