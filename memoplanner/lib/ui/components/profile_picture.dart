import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class ProfilePicture extends StatelessWidget {
  final String baseUrl;
  final String image;
  final String initial;
  static final radius = layout.logout.profilePictureSize;
  final double? size;

  const ProfilePicture(
    this.baseUrl,
    this.image, {
    Key? key,
    this.initial = '',
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widthHeight = size ?? radius * 2;
    return Container(
      width: widthHeight,
      height: widthHeight,
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
              if (initial.isNotEmpty)
                Center(
                  child: Text(
                    initial,
                    style: headline6.copyWith(color: AbiliaColors.white),
                  ),
                )
              else
                Icon(
                  AbiliaIcons.contact,
                  color: AbiliaColors.black75,
                  size: layout.icon.huge,
                ),
              if (image.isNotEmpty && baseUrl.isNotEmpty)
                FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  placeholder: kTransparentImage,
                  image:
                      profileImageUrl(baseUrl, image, size: widthHeight.ceil()),
                )
            ],
          ),
        ),
      ),
    );
  }
}
