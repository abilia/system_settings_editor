import 'package:image_picker/image_picker.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImportPicturePage extends StatelessWidget {
  const ImportPicturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.plus,
        title: translate.add,
      ),
      body: _ImportPictureBody(
        imageCallback: (selectedImage) async {
          await Navigator.of(context).maybePop(selectedImage);
        },
        onCancel: () async {
          Navigator.of(context).pop();
          await Navigator.of(context).maybePop();
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
    final translate = Lt.of(context);
    final photoMenuSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.photoMenu);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: layout.templates.m1,
          child: Column(
            children: [
              if (photoMenuSettings.displayLocalImages) ...[
                ImageSourceWidget(
                  text: translate.devicesLocalImages,
                  imageSource: ImageSource.gallery,
                  permission: Permission.photos,
                  imageCallback: imageCallback,
                ),
                SizedBox(height: layout.formPadding.verticalItemDistance),
              ],
              if (photoMenuSettings.displayCamera)
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
  }
}
