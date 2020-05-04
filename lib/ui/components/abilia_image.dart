import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/image_thumb.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:transparent_image/transparent_image.dart';

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath, activityId;
  final File imageFile;
  final double width, height;
  final ImageSize imageSize;
  FadeInCalendarImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    @required this.activityId,
    this.width,
    this.height,
    this.imageFile,
    this.imageSize = ImageSize.THUMB,
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
      return SizedBox(
        height: height,
        width: width,
        child: Hero(
          tag: '${imageFileId}_$activityId',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageFile != null
                ? FadeInImage(
                    fit: BoxFit.cover,
                    image: Image.file(imageFile).image,
                    placeholder: MemoryImage(kTransparentImage),
                  )
                : userFileLoaded
                    ? FadeInImage(
                        fit: BoxFit.cover,
                        image: imageSize == ImageSize.ORIGINAL
                            ? Image.file(fileStorage.getFile(imageFileId)).image
                            : Image.file(
                                fileStorage.getImageThumb(
                                  ImageThumb(id: imageFileId),
                                ),
                              ).image,
                        placeholder: MemoryImage(kTransparentImage),
                      )
                    : FadeInNetworkImage(
                        imageFileId: imageFileId,
                        imageFilePath: imageFilePath,
                      ),
          ),
        ),
      );
    });
  }
}

class FadeInAbiliaImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  final ImageSize imageSize;

  FadeInAbiliaImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.height,
    this.width,
    this.imageSize = ImageSize.THUMB,
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
          userFileState.userFiles
              .any((f) => f.id == imageFileId && f.fileLoaded);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: userFileLoaded
            ? FadeInImage(
                height: height,
                width: width,
                image: Image.file(
                  fileStorage.getImageThumb(ImageThumb(id: imageFileId)),
                ).image,
                placeholder: MemoryImage(kTransparentImage),
              )
            : FadeInNetworkImage(
                height: height,
                width: width,
                imageFileId: imageFileId,
                imageFilePath: imageFilePath,
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
              fit: BoxFit.cover,
              httpHeaders: authHeader(state.token),
              height: height,
              width: width,
              imageUrl: imageFileId?.isNotEmpty ?? false
                  ? imageThumbUrl(
                      baseUrl: state.userRepository.baseUrl,
                      userId: state.userId,
                      imageFileId: imageFileId,
                      size: ImageThumb.THUMB_SIZE,
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
