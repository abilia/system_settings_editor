import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/image_thumb.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';
import 'package:transparent_image/transparent_image.dart';

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final File imageFile;
  final double width, height;
  FadeInCalendarImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
    this.imageFile,
  });
  @override
  Widget build(BuildContext context) {
    final fileStorage = GetIt.I<FileStorage>();
    final emptyImage = SizedBox(
      height: height,
      width: width,
    );

    if ((imageFileId == null || imageFileId.isEmpty) &&
        (imageFilePath == null || imageFilePath.isEmpty)) {
      return emptyImage;
    }

    return BlocBuilder<UserFileBloc, UserFileState>(
        builder: (context, userFileState) {
      final userFileLoaded = userFileState is UserFilesLoaded &&
          userFileState.userFiles.any((f) => f.id == imageFileId);
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AbiliaColors.white,
        ),
        child: Hero(
          tag: imageFileId,
          child: imageFile != null
              ? FadeInImage(
                  width: width,
                  height: height,
                  image: Image.file(imageFile).image,
                  placeholder: MemoryImage(kTransparentImage),
                )
              : userFileLoaded
                  ? FadeInImage(
                      width: width,
                      height: height,
                      image: Image.file(
                        fileStorage.getImageThumb(ImageThumb(
                          id: imageFileId,
                        )),
                      ).image,
                      placeholder: MemoryImage(kTransparentImage),
                    )
                  : FadeInNetworkImage(
                      imageFileId: imageFileId,
                      imageFilePath: imageFilePath,
                      height: height,
                      width: width,
                    ),
        ),
      );
    });
  }
}

class FadeInNetworkImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  FadeInNetworkImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    final emptyImage = SizedBox(
      height: height,
      width: width,
    );
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => (state is Authenticated)
          ? CachedNetworkImage(
              httpHeaders: authHeader(state.token),
              height: height,
              width: width,
              imageUrl: imageFileId?.isNotEmpty ?? false
                  ? imageThumbUrl(
                      baseUrl: state.userRepository.baseUrl,
                      userId: state.userId,
                      imageFileId: imageFileId,
                    )
                  : imagePathUrl(
                      state.userRepository.baseUrl,
                      state.userId,
                      imageFilePath,
                    ),
              placeholder: (context, url) => emptyImage,
              errorWidget: (context, url, error) => emptyImage,
            )
          : emptyImage,
    );
  }
}
