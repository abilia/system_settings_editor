import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_view/photo_view.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityImage extends StatelessWidget {
  final ActivityDay activityDay;
  final bool past;
  final ImageSize imageSize;
  final BoxFit fit;
  final double size;
  final EdgeInsets crossOverPadding;
  static const duration = Duration(milliseconds: 400);
  static const crossPadding = 8.0;

  const ActivityImage({
    Key key,
    @required this.activityDay,
    this.size,
    this.past = false,
    this.imageSize = ImageSize.THUMB,
    this.fit = BoxFit.cover,
    this.crossOverPadding = EdgeInsets.zero,
  });

  static ActivityImage fromActivityOccasion({
    Key key,
    ActivityOccasion activityOccasion,
    double size,
    ImageSize imageSize = ImageSize.THUMB,
    BoxFit fit = BoxFit.cover,
    bool preview = false,
    EdgeInsets crossOverPadding = EdgeInsets.zero,
  }) =>
      preview
          ? FadeInCalendarImage(
              key: key,
              imageFileId: activityOccasion.activity.fileId,
              imageFilePath: activityOccasion.activity.icon,
              width: size,
              height: size,
              imageSize: imageSize,
              fit: fit,
            )
          : ActivityImage(
              key: key,
              activityDay: activityOccasion,
              size: size,
              past: activityOccasion.occasion == Occasion.past,
              imageSize: imageSize,
              fit: fit,
              crossOverPadding: crossOverPadding,
            );

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final signedOff = activityDay.isSignedOff, inactive = past || signedOff;
    final image = activity.hasImage
        ? getImage(
            context,
            activity.fileId,
            activity.icon,
          ) // all calls to blocs needs to be outside of Hero
        : null;
    final activityImage = Stack(
      alignment: Alignment.center,
      children: [
        if (image != null)
          AnimatedOpacity(
            duration: duration,
            opacity: inactive ? 0.5 : 1.0,
            child: SizedBox(
              height: size,
              width: size,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Container(
                  color: AbiliaColors.white,
                  child: FadeInImage(
                    fit: fit,
                    image: image.image,
                    placeholder: MemoryImage(kTransparentImage),
                  ),
                ),
              ),
            ),
          ),
        if (past || activity.checkable)
          Center(
            child: SizedBox(
              height: size != null ? size - crossPadding : null,
              width: size != null ? size - crossPadding : null,
              child: past && !signedOff
                  ? Padding(
                      padding: crossOverPadding,
                      child: CrossOver(),
                    )
                  : AnimatedOpacity(
                      opacity: signedOff ? 1.0 : 0.0,
                      duration: duration,
                      child: CheckMark(),
                    ),
            ),
          ),
      ],
    );
    if (image != null) {
      return Hero(
        tag: activityDay,
        child: activityImage,
      );
    } else {
      return activityImage;
    }
  }

  Image getImage(BuildContext context, String fileId, String filePath) {
    final userFileState = context.watch<UserFileBloc>().state;
    final file = userFileState.getLoadedByIdOrPath(
      fileId,
      filePath,
      GetIt.I<FileStorage>(),
      imageSize: imageSize,
    );
    if (file != null) {
      return Image.file(file);
    }
    final authenicatedState = context.watch<AuthenticationBloc>().state;
    if (authenicatedState is Authenticated) {
      return Image.network(
        imageThumbUrl(
          baseUrl: authenicatedState.userRepository.baseUrl,
          userId: authenicatedState.userId,
          imageFileId: fileId,
          imagePath: filePath,
          size: ImageThumb.THUMB_SIZE,
        ),
        headers: authHeader(authenicatedState.token),
      );
    }
    return Image.memory(kTransparentImage);
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
        fit: BoxFit.contain,
      ),
    );
  }

  void _showImage(String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      useSafeArea: false,
      context: context,
      builder: (_) {
        return FullscreenImageDialog(
          fileId: fileId,
          filePath: filePath,
        );
      },
    );
  }
}

class PhotoCalendarImage extends StatelessWidget {
  final String fileId;
  final Widget errorContent;

  const PhotoCalendarImage({
    Key key,
    @required this.fileId,
    this.errorContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorImage = errorContent ?? Image.memory(kTransparentImage);
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      return BlocBuilder<UserFileBloc, UserFileState>(
          builder: (context, userFileState) {
        final file = userFileState.getLoadedByIdOrPath(
          fileId,
          null,
          GetIt.I<FileStorage>(),
          imageSize: ImageSize.ORIGINAL,
        );
        return file != null
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => errorImage,
              )
            : (state is Authenticated)
                ? Image.network(
                    imageThumbUrl(
                      baseUrl: state.userRepository.baseUrl,
                      userId: state.userId,
                      imageFileId: fileId,
                      imagePath: null,
                    ),
                    headers: authHeader(state.token),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => errorImage,
                  )
                : errorImage;
      });
    });
  }
}

class FullScreenImage extends StatelessWidget {
  final String fileId;
  final String filePath;
  final Decoration backgroundDecoration;
  final GestureTapCallback onTap;

  const FullScreenImage({
    Key key,
    @required this.fileId,
    @required this.filePath,
    this.backgroundDecoration,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        return BlocBuilder<UserFileBloc, UserFileState>(
            builder: (context, userFileState) {
          final file = userFileState.getLoadedByIdOrPath(
            fileId,
            filePath,
            GetIt.I<FileStorage>(),
            imageSize: ImageSize.ORIGINAL,
          );
          return PhotoView(
            backgroundDecoration: backgroundDecoration,
            imageProvider: file != null
                ? FileImage(file)
                : (state is Authenticated)
                    ? NetworkImage(
                        imageThumbUrl(
                          baseUrl: state.userRepository.baseUrl,
                          userId: state.userId,
                          imageFileId: fileId,
                          imagePath: filePath,
                        ),
                        headers: authHeader(state.token),
                      )
                    : MemoryImage(kTransparentImage),
          );
        });
      }),
    );
  }
}

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  final ImageSize imageSize;
  final BoxFit fit;
  FadeInCalendarImage({
    Key key,
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
    this.imageSize = ImageSize.THUMB,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
      final file = userFileState.getLoadedByIdOrPath(
        imageFileId,
        imageFilePath,
        GetIt.I<FileStorage>(),
        imageSize: imageSize,
      );
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: file != null
              ? FadeInImage(
                  fit: fit,
                  image: Image.file(file).image,
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
  final BorderRadius borderRadius;
  final radius = BorderRadius.circular(12.s);

  FadeInAbiliaImage({
    Key key,
    @required this.imageFileId,
    this.imageFilePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      final file = userFileState.getLoadedByIdOrPath(
        imageFileId,
        imageFilePath,
        GetIt.I<FileStorage>(),
        imageSize: ImageSize.THUMB,
      );

      return ClipRRect(
        borderRadius: borderRadius ?? radius,
        child: file != null
            ? FadeInImage(
                height: height,
                width: width,
                fit: fit,
                image: Image.file(file).image,
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
              imageErrorBuilder: (_, __, ___) => CrossOver(
                fallbackHeight: height,
                fallbackWidth: width,
              ),
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
