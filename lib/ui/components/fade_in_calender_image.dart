import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';

class FadeInCalenderImage extends StatelessWidget {
  final String imageFileId;
  final bool isThumb;
  final double width, height;
  FadeInCalenderImage({
    @required this.imageFileId,
    this.width,
    this.height,
    this.isThumb = true,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => (state is Authenticated)
          ? FadeInImage(
              width: width ?? (isThumb ? 56 : null),
              height: height ?? (isThumb ? 56 : null),
              image: NetworkImage(
                  isThumb
                      ? thumbImageUrl(state.userRepository.baseUrl, state.userId, imageFileId)
                      : imageUrl(state.userRepository.baseUrl, state.userId, imageFileId),
                  headers: authHeader(state.token)),
              placeholder:
                  ExactAssetImage('assets/graphics/seagull_icon_gray.png'),
            )
          : Container(),
    );
  }
}
