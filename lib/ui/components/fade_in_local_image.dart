import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:transparent_image/transparent_image.dart';

class FadeInLocalImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  FadeInLocalImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    final fileStorage = GetIt.I<FileStorage>();

    return FutureBuilder(
        future: fileStorage.getFile(imageFileId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FadeInImage(
              width: width,
              height: height,
              image: FileImage(snapshot.data),
              placeholder: MemoryImage(kTransparentImage),
            );
          } else {
            return SizedBox(
              height: height,
              width: width,
            );
          }
        });
  }
}
