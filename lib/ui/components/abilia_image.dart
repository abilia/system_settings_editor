import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_view/photo_view.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:transparent_image/transparent_image.dart';

class ActivityImage extends StatelessWidget {
  final ActivityDay activityDay;
  final bool past;
  final ImageSize imageSize;
  final File imageFile;
  final BoxFit fit;
  final Widget checkmark;
  final double size;
  static const duration = Duration(milliseconds: 400);
  static const crossPadding = 8.0;

  const ActivityImage({
    Key key,
    @required this.activityDay,
    this.size,
    this.past = false,
    this.imageSize = ImageSize.THUMB,
    this.imageFile,
    this.fit = BoxFit.cover,
  })  : checkmark = size != null && size < 100
            ? const CheckMarkWithBorder()
            : const CheckMark(),
        super(key: key);

  static ActivityImage fromActivityOccasion({
    Key key,
    ActivityOccasion activityOccasion,
    double size,
    ImageSize imageSize = ImageSize.THUMB,
    File imageFile,
    BoxFit fit = BoxFit.cover,
    bool preview = false,
  }) =>
      preview
          ? FadeInCalendarImage(
              key: key,
              imageFileId: activityOccasion.activity.fileId,
              imageFilePath: activityOccasion.activity.icon,
              width: size,
              height: size,
              imageSize: imageSize,
              imageFile: imageFile,
              fit: fit,
            )
          : ActivityImage(
              key: key,
              activityDay: activityOccasion,
              size: size,
              past: activityOccasion.occasion == Occasion.past,
              imageSize: imageSize,
              imageFile: imageFile,
              fit: fit,
            );

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage,
        signedOff = activityDay.isSignedOff,
        inactive = past || signedOff;
    return Hero(
      tag: activityDay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasImage)
            AnimatedOpacity(
              duration: duration,
              opacity: inactive ? 0.5 : 1.0,
              child: FadeInCalendarImage(
                imageFileId: activity.fileId,
                imageFilePath: activity.icon,
                width: size,
                height: size,
                imageSize: imageSize,
                imageFile: imageFile,
              ),
            ),
          if (past || activity.checkable)
            Center(
              child: SizedBox(
                height: size != null ? size - crossPadding : null,
                width: size != null ? size - crossPadding : null,
                child: past && !signedOff
                    ? CrossOver()
                    : AnimatedOpacity(
                        opacity: signedOff ? 1.0 : 0.0,
                        duration: duration,
                        child: checkmark,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckedImageWithImagePopup extends StatelessWidget {
  final ActivityDay activityDay;
  final double size;

  const CheckedImageWithImagePopup({
    Key key,
    this.activityDay,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: TestKey.viewImage,
      onTap: () => activityDay.activity.hasImage
          ? _showImage(
              activityDay.activity.fileId, activityDay.activity.icon, context)
          : null,
      child: ActivityImage(
        activityDay: activityDay,
        imageSize: ImageSize.ORIGINAL,
        size: size,
      ),
    );
  }

  void _showImage(String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      context: context,
      builder: (_) {
        return FullScreenImage(
          fileId: fileId,
          filePath: filePath,
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String fileId;
  final String filePath;
  final Decoration backgroundDecoration;
  const FullScreenImage({
    Key key,
    @required this.fileId,
    @required this.filePath,
    this.backgroundDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Navigator.of(context).maybePop,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        return BlocBuilder<UserFileBloc, UserFileState>(
            builder: (context, userFileState) {
          final userFile = userFileState.getLoadedByIdOrPath(fileId, filePath);
          return PhotoView(
            backgroundDecoration: backgroundDecoration,
            imageProvider: userFile != null
                ? Image.file(GetIt.I<FileStorage>().getFile(userFile.id)).image
                : (state is Authenticated)
                    ? Image.network(
                        imageThumbUrl(
                          baseUrl: state.userRepository.baseUrl,
                          userId: state.userId,
                          imageFileId: fileId,
                          imagePath: filePath,
                          size: ImageThumb.THUMB_SIZE,
                        ),
                        headers: authHeader(state.token),
                      ).image
                    : MemoryImage(kTransparentImage),
          );
        });
      }),
    );
  }
}

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final File imageFile;
  final double width, height;
  final ImageSize imageSize;
  final BoxFit fit;
  FadeInCalendarImage({
    Key key,
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
    this.imageFile,
    this.imageSize = ImageSize.THUMB,
    this.fit = BoxFit.cover,
  }) : super(key: key);
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
      final userFile =
          userFileState.getLoadedByIdOrPath(imageFileId, imageFilePath);
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: imageFile != null
              ? FadeInImage(
                  fit: fit,
                  image: Image.file(imageFile).image,
                  placeholder: MemoryImage(kTransparentImage),
                )
              : userFile != null
                  ? FadeInImage(
                      fit: fit,
                      image: imageSize == ImageSize.ORIGINAL
                          ? Image.file(fileStorage.getFile(userFile.id)).image
                          : Image.file(
                              fileStorage.getImageThumb(
                                ImageThumb(id: userFile.id),
                              ),
                            ).image,
                      placeholder: MemoryImage(kTransparentImage),
                    )
                  : FadeInNetworkImage(
                      imageFileId: imageFileId,
                      imageFilePath: imageFilePath,
                      fit: fit,
                    ),
        ),
      );
    });
  }
}

class FadeInAbiliaImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  final BoxFit fit;

  FadeInAbiliaImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
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
      final userFile = userFileState.getLoadedByIdOrPath(
        imageFileId,
        imageFilePath,
      );

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: userFile != null
            ? FadeInImage(
                height: height,
                width: width,
                fit: fit,
                image: Image.file(
                  fileStorage.getImageThumb(ImageThumb(id: userFile.id)),
                ).image,
                placeholder: MemoryImage(kTransparentImage),
              )
            : FadeInNetworkImage(
                height: height,
                width: width,
                fit: fit,
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
  final BoxFit fit;
  FadeInNetworkImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.fit = BoxFit.cover,
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
          ? FadeInImage(
              height: height,
              width: width,
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(
                imageFileId != null
                    ? imageThumbIdUrl(
                        baseUrl: state.userRepository.baseUrl,
                        userId: state.userId,
                        imageFileId: imageFileId,
                        size: ImageThumb.THUMB_SIZE,
                      )
                    : imageThumbPathUrl(
                        baseUrl: state.userRepository.baseUrl,
                        userId: state.userId,
                        imagePath: imageFilePath,
                        size: ImageThumb.THUMB_SIZE,
                      ),
                headers: authHeader(state.token),
              ),
              fit: fit,
            )
          : emptyImage,
    );
  }
}
