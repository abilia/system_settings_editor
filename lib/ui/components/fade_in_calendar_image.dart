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
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => Icon(AbiliaIcons.error),
            )
          : Container(),
    );
  }
}
