import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';

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
