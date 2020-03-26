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
      final userFileLoaded = userFileState is UserFilesLoaded &&
          userFileState.userFiles.any((f) => f.id == imageFileId);
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AbiliaColors.white,
        ),
        child: Hero(
          tag: imageFileId,
          child: userFileLoaded
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
