import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:seagull/models/user.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';

class ProfilePicture extends StatelessWidget {
  final double radius;
  final String baseUrl;
  final User user;
  const ProfilePicture(this.baseUrl, this.user, {Key key, this.radius = 84.0})
      : assert(radius != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
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
              if (user != null &&
                  user.image != null &&
                  user.image.isNotEmpty &&
                  baseUrl != null)
                FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  placeholder: kTransparentImage,
                  image: profileImageUrl(baseUrl, user.image,
                      size: widhtHeight.ceil()),
                )
            ],
          ),
        ),
      ),
    );
  }
}
