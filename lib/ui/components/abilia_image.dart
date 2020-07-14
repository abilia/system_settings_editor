import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:photo_view/photo_view.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:transparent_image/transparent_image.dart';

class CheckedImage extends StatelessWidget {
  final ActivityDay activityDay;
  final bool past;
  final ImageSize imageSize;
  final File imageFile;
  final BoxFit fit;
  final Widget checkmark;
  final double size;
  static const duration = Duration(milliseconds: 400);

  const CheckedImage({
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

  static CheckedImage fromActivityOccasion({
    Key key,
    ActivityOccasion activityOccasion,
    double size,
    ImageSize imageSize = ImageSize.THUMB,
    File imageFile,
    BoxFit fit = BoxFit.cover,
  }) =>
      CheckedImage(
        key: key,
        activityDay: activityOccasion,
        size: size,
        past: activityOccasion.occasion == Occasion.past,
        imageSize: imageSize,
        imageFile: imageFile,
      );

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage,
        signedOff = activityDay.isSignedOff,
        inactive = past || signedOff;
    return Hero(
      tag: '${activity.id}${activityDay.day.millisecondsSinceEpoch}',
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
                activityId: activity.id,
                width: size,
                height: size,
                imageSize: imageSize,
                imageFile: imageFile,
              ),
            ),
          Center(
            child: AnimatedOpacity(
              opacity: signedOff ? 1.0 : 0,
              duration: duration,
              child: checkmark,
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
          ? _showImage(activityDay.activity.fileId, context)
          : null,
      child: CheckedImage(
        activityDay: activityDay,
        imageSize: ImageSize.ORIGINAL,
        size: size,
      ),
    );
  }

  void _showImage(String fileId, BuildContext context) async {
    await showViewDialog<bool>(
      context: context,
      builder: (_) {
        return FullScreenImage(fileId: fileId);
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String fileId;
  final Decoration backgroundDecoration;
  const FullScreenImage({
    Key key,
    this.fileId,
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
          final userFileLoaded = userFileState is UserFilesLoaded &&
              userFileState.userFiles.any((f) => f.id == fileId);
          return PhotoView(
            backgroundDecoration: backgroundDecoration,
            imageProvider: userFileLoaded
                ? Image.file(GetIt.I<FileStorage>().getFile(fileId)).image
                : (state is Authenticated)
                    ? AdvancedNetworkImage(
                        imageThumbUrl(
                          baseUrl: state.userRepository.baseUrl,
                          userId: state.userId,
                          imageFileId: fileId,
                          size: ImageThumb.THUMB_SIZE,
                        ),
                        header: authHeader(state.token),
                      )
                    : MemoryImage(kTransparentImage),
          );
        });
      }),
    );
  }
}

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath, activityId;
  final File imageFile;
  final double width, height;
  final ImageSize imageSize;
  final BoxFit fit;
  FadeInCalendarImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    @required this.activityId,
    this.width,
    this.height,
    this.imageFile,
    this.imageSize = ImageSize.THUMB,
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
      final userFileLoaded = userFileState is UserFilesLoaded &&
          userFileState.userFiles.any((f) => f.id == imageFileId);
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
              : userFileLoaded
                  ? FadeInImage(
                      fit: fit,
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
      final userFileLoaded = userFileState is UserFilesLoaded &&
          userFileState.userFiles
              .any((f) => f.id == imageFileId && f.fileLoaded);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: userFileLoaded
            ? FadeInImage(
                height: height,
                width: width,
                fit: fit,
                image: Image.file(
                  fileStorage.getImageThumb(ImageThumb(id: imageFileId)),
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
  static final _log = Logger((FadeInNetworkImage).toString());
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
              image: AdvancedNetworkImage(
                imageFileId != null
                    ? imageThumbUrl(
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
                header: authHeader(state.token),
                loadFailedCallback: () =>
                    _log.info('Failed to load network image'),
              ),
              fit: fit,
            )
          : emptyImage,
    );
  }
}
