import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';
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

    return BlocBuilder<UserFileBloc, UserFileState>(
        builder: (context, userFileState) {
      if (userFileState is UserFilesLoaded) {
        return FutureBuilder<File>(
          future: fileStorage.getFile(imageFileId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: AbiliaColors.white,
                ),
                child: FadeInImage(
                  width: width,
                  height: height,
                  image: Image.file(
                    snapshot.data,
                  ).image,
                  placeholder: MemoryImage(kTransparentImage),
                ),
              );
            } else {
              return SizedBox(
                height: height,
                width: width,
              );
            }
          },
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
