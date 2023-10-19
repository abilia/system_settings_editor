part of 'about_page.dart';

class SearchForUpdateButton extends StatelessWidget {
  const SearchForUpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWhite(
      onPressed: () async => AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
          'market://details?id=${GetIt.I<PackageInfo>().packageName}',
        ),
      ).launch(),
      leading: const Icon(AbiliaIcons.reset),
      text: Lt.of(context).check_for_updates,
    );
  }
}
