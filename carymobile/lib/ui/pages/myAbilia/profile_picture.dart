part of 'myabilia_page.dart';

class ProfilePicture extends StatelessWidget {
  final User user;
  const ProfilePicture({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = GetIt.I<BaseUrlDb>().baseUrl;
    return SizedBox(
      width: 192,
      height: 192,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(96),
        child: FadeInImage.memoryNetwork(
          fit: BoxFit.cover,
          placeholder: kTransparentImage,
          imageErrorBuilder: (context, obj, stack) => const ColoredBox(
            color: abiliaWhite120,
            child: Icon(
              AbiliaIcons.contact,
              color: abiliaBlack75,
              size: 96,
            ),
          ),
          image: profileImageUrl(baseUrl, user.image),
        ),
      ),
    );
  }
}

String profileImageUrl(String baseUrl, String imageFileId) =>
    '$baseUrl/open/v1/file/$imageFileId';
