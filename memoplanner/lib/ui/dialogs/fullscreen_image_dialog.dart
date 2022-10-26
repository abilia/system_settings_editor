import 'package:seagull/ui/all.dart';

class FullscreenImageDialog extends StatelessWidget {
  final String fileId;
  final String filePath;
  const FullscreenImageDialog({
    required this.fileId,
    required this.filePath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      expanded: true,
      bodyPadding: EdgeInsets.zero,
      body: FullScreenImage(
        backgroundDecoration: whiteNoBorderBoxDecoration.copyWith(
          borderRadius: BorderRadius.zero,
        ),
        fileId: fileId,
        filePath: filePath,
      ),
      backNavigationWidget: const CloseButton(),
    );
  }
}
