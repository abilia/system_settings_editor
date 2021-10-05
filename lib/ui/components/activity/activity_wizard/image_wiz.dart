import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_file.dart';
import 'package:seagull/ui/all.dart';

class ImageWiz extends StatelessWidget {
  const ImageWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
      builder: (context, wizState) =>
          BlocBuilder<EditActivityBloc, EditActivityState>(
        builder: (context, state) => Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.selectImage,
            iconData: AbiliaIcons.edit,
          ),
          body: Padding(
            padding: ordinaryPadding,
            child: ImageWizSelectPictureWidget(
              selectedImage: state.selectedImage,
              onImageSelected: (selectedImage) {
                BlocProvider.of<EditActivityBloc>(context).add(
                  ImageSelected(selectedImage),
                );
              },
              errorState:
                  wizState.saveErrors.contains(SaveError.NO_TITLE_OR_IMAGE),
            ),
          ),
          bottomNavigationBar: WizardBottomNavigation(),
        ),
      ),
    );
  }
}

class ImageWizSelectPictureWidget extends StatefulWidget {
  static final imageSize = 84.0.s, padding = 4.0.s;
  final AbiliaFile selectedImage;

  final void Function(AbiliaFile)? onImageSelected;
  final bool errorState;

  ImageWizSelectPictureWidget({
    Key? key,
    this.selectedImage = AbiliaFile.empty,
    this.onImageSelected,
    this.errorState = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectPictureState(
        selectedImage: selectedImage, errorState: errorState);
  }
}

class SelectPictureState extends State<ImageWizSelectPictureWidget> {
  AbiliaFile selectedImage;
  final bool errorState;

  SelectPictureState({required this.selectedImage, required this.errorState});

  @override
  Widget build(BuildContext context) {
    return SelectPictureBody(
        imageCallback: (newImage) => setState(() {
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
              selectedImage = newImage;
              context.read<EditActivityBloc>().add(ImageSelected(newImage));
            }),
        selectedImage: selectedImage,
        onCancel: () => {Navigator.of(context).pop()});
  }
}
