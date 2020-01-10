import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:seagull/bloc/authentication/authentication_state.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';

class ProfilePicture extends StatelessWidget {
  final double radius;
  final AuthenticationState _authState;
  final Future<User> _futureUser;
  const ProfilePicture(this._authState, this._futureUser,
      {Key key, this.radius = 84.0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final state = _authState;
    final widhtHeight = radius * 2;
    return Container(
      width: widhtHeight,
      height: widhtHeight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AbiliaColors.white[120],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Icon(
                AbiliaIcons.contact,
                color: AbiliaColors.black[75],
                size: 96,
              ),
              FutureBuilder(
                future: _futureUser,
                builder: (context, AsyncSnapshot<User> snapshot) => snapshot
                            .hasData &&
                        snapshot.data.image != null &&
                        state is AuthenticationInitialized
                    ? FadeInImage.memoryNetwork(
                        fit: BoxFit.cover,
                        placeholder: kTransparentImage,
                        image: profileImageUrl(
                            state.userRepository.baseUrl, snapshot.data.image,
                            size: widhtHeight.ceil()),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
