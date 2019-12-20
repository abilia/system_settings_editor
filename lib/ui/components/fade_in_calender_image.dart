import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';

class FadeInCalenderImage extends StatelessWidget {
  final String imageFileId;
  final bool isThumb;
  final double width, height;
  FadeInCalenderImage({
    @required this.imageFileId,
    this.width,
    this.height,
  }) : isThumb = width != null && height != null;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => (state is Authenticated)
          ? FadeInImage(
              width: width,
              height: height,
              image: NetworkImage(
                  isThumb
                      ? thumbImageUrl(state.userRepository.baseUrl,
                          state.userId, imageFileId,
                          height: height.ceil(), width: width.ceil())
                      : imageUrl(state.userRepository.baseUrl, state.userId,
                          imageFileId),
                  headers: authHeader(state.token)),
              placeholder:
                  ExactAssetImage('assets/graphics/seagull_icon_gray.png'),
            )
          : Container(),
    );
  }
}
