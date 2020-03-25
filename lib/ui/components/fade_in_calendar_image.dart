import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/abilia_icons.dart';

class FadeInCalendarImage extends StatelessWidget {
  final String imageFileId, imageFilePath;
  final double width, height;
  FadeInCalendarImage({
    @required this.imageFileId,
    @required this.imageFilePath,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    print('Render image with fileId: $imageFileId and path: $imageFilePath');
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => (state is Authenticated)
          ? CachedNetworkImage(
              height: height,
              width: width,
              imageUrl: imageFileId?.isNotEmpty ?? false
                  ? fileIdUrl(
                      state.userRepository.baseUrl, state.userId, imageFileId)
                  : imagePathUrl(state.userRepository.baseUrl, state.userId,
                      imageFilePath),
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => Icon(AbiliaIcons.error),
            )
          : Container(),
    );
  }
}
