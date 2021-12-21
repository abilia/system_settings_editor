import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_file.dart';
import 'package:seagull/ui/all.dart';

class ImportPicturePage extends StatelessWidget {
  const ImportPicturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.plus,
        title: translate.add,
      ),
      body: _ImportPictureBody(
        imageCallback: (selectedImage) async {
          await Navigator.of(context).maybePop(selectedImage);
        },
        onCancel: () => {
          Navigator.of(context)
            ..pop()
            ..maybePop()
        },
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }
}

class _ImportPictureBody extends StatelessWidget {
  final ValueChanged<AbiliaFile> imageCallback;
  final VoidCallback? onCancel;

  const _ImportPictureBody(
      {Key? key, required this.imageCallback, this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
              child: Column(
                children: [
                  if (state.displayPhotos) ...[
                    ImageSourceWidget(
                      text: translate.uploadImage,
                      imageSource: ImageSource.gallery,
                      permission: Permission.photos,
                      imageCallback: imageCallback,
                    ),
                    SizedBox(height: 8.0.s),
                  ],
                  if (state.displayCamera)
                    ImageSourceWidget(
                      text: translate.takeNewPhoto,
                      imageSource: ImageSource.camera,
                      permission: Permission.camera,
                      imageCallback: imageCallback,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
