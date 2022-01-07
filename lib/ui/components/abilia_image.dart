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
  final EdgeInsets? crossPadding;
  final EdgeInsets? checkPadding;

  static const duration = Duration(milliseconds: 400);
  static final fallbackCrossPadding = EdgeInsets.all(4.s);
  static final fallbackCheckPadding = EdgeInsets.all(8.s);

  const ActivityImage({
    required this.activityDay,
    this.past = false,
    this.imageSize = ImageSize.thumb,
    this.fit = BoxFit.cover,
    this.crossPadding,
    this.checkPadding,
    Key? key,
  }) : super(key: key);

  static Widget fromActivityOccasion({
    Key? key,
    required ActivityOccasion activityOccasion,
    ImageSize imageSize = ImageSize.thumb,
    BoxFit fit = BoxFit.cover,
    bool preview = false,
    EdgeInsets? crossPadding,
    EdgeInsets? checkPadding,
  }) =>
      preview
          ? FadeInCalendarImage(
              key: key,
              imageFileId: activityOccasion.activity.fileId,
              imageFilePath: activityOccasion.activity.icon,
              imageSize: imageSize,
              fit: fit,
            )
          : ActivityImage(
              key: key,
              activityDay: activityOccasion,
              past: activityOccasion.occasion == Occasion.past,
              imageSize: imageSize,
              fit: fit,
              crossPadding: crossPadding,
              checkPadding: crossPadding,
            );

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final signedOff = activityDay.isSignedOff;
    final inactive = past || signedOff;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (activity.hasImage)
          AnimatedOpacity(
            duration: duration,
            opacity: inactive ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: FadeInImage(
                fit: fit,
                image: getImage(
                  context,
                  activity.fileId,
                  activity.icon,
                ).image,
                placeholder: MemoryImage(kTransparentImage),
              ),
            ),
          ),
        if (signedOff)
          Padding(
            padding: checkPadding ?? fallbackCheckPadding,
            child: const CheckMark(),
          )
        else if (past)
          Padding(
            padding: crossPadding ?? fallbackCrossPadding,
            child: const CrossOver(),
          )
      ],
    );
  }

  Image getImage(BuildContext context, String fileId, String filePath) {
    final userFileState = context.watch<UserFileCubit>().state;
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
          size: ImageThumb.thumbSize,
        ),
        headers: authHeader(authenicatedState.token),
      );
    }
    return Image.memory(kTransparentImage);
  }
}

class CheckedImageWithImagePopup extends StatelessWidget {
  final ActivityDay activityDay;

  const CheckedImageWithImagePopup({
    Key? key,
    required this.activityDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: TestKey.viewImage,
      onTap: () => activityDay.activity.hasImage
          ? _showImage(
              activityDay.activity.fileId,
              activityDay.activity.icon,
              context,
            )
          : null,
      child: ActivityImage(
        activityDay: activityDay,
        imageSize: ImageSize.original,
        fit: BoxFit.contain,
      ),
    );
  }

  void _showImage(
    String fileId,
    String filePath,
    BuildContext context,
  ) async {
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
  final String filePath;
  final Widget? errorContent;

  const PhotoCalendarImage({
    Key? key,
    required this.fileId,
    required this.filePath,
    this.errorContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorImage = errorContent ?? Image.memory(kTransparentImage);
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      return BlocBuilder<UserFileCubit, UserFileState>(
          builder: (context, userFileState) {
        final file = userFileState.getLoadedByIdOrPath(
          fileId,
          filePath,
          GetIt.I<FileStorage>(),
          imageSize: ImageSize.original,
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
                      imagePath: filePath,
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
  final BoxDecoration? backgroundDecoration;
  final GestureTapCallback? onTap;

  const FullScreenImage({
    Key? key,
    required this.fileId,
    required this.filePath,
    this.backgroundDecoration,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        return BlocBuilder<UserFileCubit, UserFileState>(
            builder: (context, userFileState) {
          final file = userFileState.getLoadedByIdOrPath(
            fileId,
            filePath,
            GetIt.I<FileStorage>(),
            imageSize: ImageSize.original,
          );
          ImageProvider getProvider() {
            if (file != null) return FileImage(file);
            if (state is Authenticated) {
              return NetworkImage(
                imageThumbUrl(
                  baseUrl: state.userRepository.baseUrl,
                  userId: state.userId,
                  imageFileId: fileId,
                  imagePath: filePath,
                ),
                headers: authHeader(state.token),
              );
            }
            return MemoryImage(kTransparentImage);
          }

          return PhotoView(
            backgroundDecoration: backgroundDecoration,
            imageProvider: getProvider(),
          );
        });
      }),
    );
  }
}

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double? width, height;
  final ImageSize imageSize;
  final BoxFit fit;
  const FadeInCalendarImage({
    Key? key,
    required this.imageFileId,
    required this.imageFilePath,
    this.width,
    this.height,
    this.imageSize = ImageSize.thumb,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final emptyImage = SizedBox(
      height: height,
      width: width,
    );

    if (imageFileId.isEmpty && imageFilePath.isEmpty) {
      return emptyImage;
    }

    return BlocBuilder<UserFileCubit, UserFileState>(
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
  final double? width, height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final radius = BorderRadius.circular(12.s);

  FadeInAbiliaImage({
    Key? key,
    required this.imageFileId,
    this.imageFilePath = '',
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

    if (imageFileId.isEmpty && imageFilePath.isEmpty) {
      return emptyImage;
    }

    return BlocBuilder<UserFileCubit, UserFileState>(
        builder: (context, userFileState) {
      final file = userFileState.getLoadedByIdOrPath(
        imageFileId,
        imageFilePath,
        GetIt.I<FileStorage>(),
        imageSize: ImageSize.thumb,
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
  final double? width, height;
  final BoxFit fit;
  const FadeInNetworkImage({
    required this.imageFileId,
    required this.imageFilePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    Key? key,
  }) : super(key: key);
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
                imageThumbUrl(
                  baseUrl: state.userRepository.baseUrl,
                  userId: state.userId,
                  imagePath: imageFilePath,
                  imageFileId: imageFileId,
                  size: ImageThumb.thumbSize,
                ),
                headers: authHeader(state.token),
              ),
              fit: fit,
            )
          : emptyImage,
    );
  }
}
