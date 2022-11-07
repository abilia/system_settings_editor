import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/abilia_file.dart';
import 'package:memoplanner/ui/all.dart';

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
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      buildWhen: (previous, current) =>
          previous.selectedImage != current.selectedImage,
      builder: (context, state) => SelectPictureBody(
        imageCallback: (newImage) {
          if (newImage is UnstoredAbiliaFile) {
            BlocProvider.of<UserFileCubit>(context).fileAdded(
              newImage,
              image: true,
            );
            BlocProvider.of<SortableBloc>(context).add(
              ImageArchiveImageAdded(
                newImage.id,
                newImage.file.path,
              ),
            );
          }
          context.read<EditActivityCubit>().imageSelected(newImage);
        },
        selectedImage: state.selectedImage,
        onCancel: Navigator.of(context).pop,
      ),
    );
  }
}
