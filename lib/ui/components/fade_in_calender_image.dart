import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:transparent_image/transparent_image.dart';

class FadeInCalenderImage extends StatelessWidget {
  final String imageFileId;
  final double width, height;
  FadeInCalenderImage({
    @required this.imageFileId,
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
                  imageUrl(
                      state.userRepository.baseUrl, state.userId, imageFileId),
                  headers: authHeader(state.token)),
              placeholder: MemoryImage(kTransparentImage),
            )
          : Container(),
    );
  }
}

class FadeInThumb extends StatelessWidget {
  final String imageFileId;
  final double width, height;
  FadeInThumb({
    @required this.imageFileId,
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
                  thumbImageUrl(
                      state.userRepository.baseUrl, state.userId, imageFileId,
                      height: (height * 3).ceil(), width: (width * 3).ceil()),
                  headers: authHeader(state.token)),
              placeholder: MemoryImage(kTransparentImage),
            )
          : Container(),
    );
  }
}
