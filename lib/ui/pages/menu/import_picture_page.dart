import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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

  const _ImportPictureBody({
    required this.imageCallback,
    this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
        PhotoMenuSettings>(
      selector: (state) => state.settings.photoMenu,
      builder: (context, settings) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: layout.templates.m1,
              child: Column(
                children: [
                  if (settings.displayLocalImages) ...[
                    ImageSourceWidget(
                      text: translate.devicesLocalImages,
                      imageSource: ImageSource.gallery,
                      permission: Permission.photos,
                      imageCallback: imageCallback,
                    ),
                    SizedBox(height: layout.formPadding.verticalItemDistance),
                  ],
                  if (settings.displayCamera)
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
