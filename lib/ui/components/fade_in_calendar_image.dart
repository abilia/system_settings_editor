import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:transparent_image/transparent_image.dart';

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
          ? FadeInImage(
              width: width,
              height: height,
              image: NetworkImage(
                  imageFileId?.isNotEmpty ?? false
                      ? imageIdUrl(state.userRepository.baseUrl, state.userId,
                          imageFileId)
                      : imagePathUrl(state.userRepository.baseUrl, state.userId,
                          imageFilePath),
                  headers: authHeader(state.token)),
              placeholder: MemoryImage(kTransparentImage),
            )
          : Container(),
    );
  }
}
