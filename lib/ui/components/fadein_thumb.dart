import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';

class FadeInThumb extends StatelessWidget {
  final String imageFileId;
  FadeInThumb({@required this.imageFileId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => (state is Authenticated)
          ? FadeInImage(
              width: 56,
              height: 56,
              image: state.userRepository.baseUrl.isNotEmpty
                  ? NetworkImage(
                      thumbImageUrl(state.userRepository.baseUrl, state.userId,
                          imageFileId),
                      headers: authHeader(state.token))
                  : ExactAssetImage('assets/graphics/seagull_icon_gray.png'),
              placeholder:
                  ExactAssetImage('assets/graphics/seagull_icon_gray.png'),
            )
          : Container(),
    );
  }
}
