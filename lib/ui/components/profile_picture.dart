import 'package:flutter/widgets.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AbiliaColors.white120,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Icon(
                AbiliaIcons.contact,
                color: AbiliaColors.black75,
                size: hugeIconSize,
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
