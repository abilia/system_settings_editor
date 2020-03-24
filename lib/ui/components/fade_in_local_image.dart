import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/image_thumb.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
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
      if (userFileState is UserFilesLoaded &&
          userFileState.userFiles.any((f) => f.id == imageFileId)) {
        final file =
            fileStorage.getImageThumb(ImageThumb(imageFileId, 350, 350));
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: AbiliaColors.white,
          ),
          child: Hero(
            tag: imageFileId,
            child: FadeInImage(
              width: width,
              height: height,
              image: Image.file(
                file,
              ).image,
              placeholder: MemoryImage(kTransparentImage),
            ),
          ),
        );
      } else {
        return Hero(
          tag: imageFileId,
          child: FadeInCalendarImage(
            imageFileId: imageFileId,
            imageFilePath: imageFilePath,
            height: height,
            width: width,
          ),
        );
      }
    });
  }
}
