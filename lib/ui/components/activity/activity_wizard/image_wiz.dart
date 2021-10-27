import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_file.dart';
import 'package:seagull/ui/all.dart';

class ImageWiz extends StatelessWidget {
  const ImageWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      title: Translator.of(context).translate.selectImage,
      iconData: AbiliaIcons.edit,
      body: const ImageWizSelectPictureWidget(),
    );
  }
}

class ImageWizSelectPictureWidget extends StatelessWidget {
  const ImageWizSelectPictureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      buildWhen: (previous, current) =>
          previous.selectedImage != current.selectedImage,
      builder: (context, state) => SelectPictureBody(
        imageCallback: (newImage) {
          if (newImage is UnstoredAbiliaFile) {
            BlocProvider.of<UserFileBloc>(context).add(
              ImageAdded(newImage),
            );
            BlocProvider.of<SortableBloc>(context).add(
              ImageArchiveImageAdded(
                newImage.id,
                newImage.file.path,
              ),
            );
          }
          context.read<EditActivityBloc>().add(ImageSelected(newImage));
        },
        selectedImage: state.selectedImage,
        onCancel: Navigator.of(context).pop,
      ),
    );
  }
}
