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

class ShowPictureState extends State<ImageWizSelectPictureWidget> {
  AbiliaFile selectedImage;
  final bool errorState;

  ShowPictureState({required this.selectedImage, required this.errorState});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: FullScreenImage(
            backgroundDecoration: whiteNoBorderBoxDecoration,
            fileId: selectedImage.id,
            filePath: selectedImage.path,
          ),
        ),
      ),
    );
  }
}

class SelectPictureState extends State<ImageWizSelectPictureWidget> {
  AbiliaFile selectedImage;
  final bool errorState;

  SelectPictureState({required this.selectedImage, required this.errorState});

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    if (selectedImage.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: FullScreenImage(
                  backgroundDecoration: whiteNoBorderBoxDecoration,
                  fileId: selectedImage.id,
                  filePath: selectedImage.path,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0.s),
          RemoveButton(
            key: TestKey.removePicture,
            onTap: () => setState(() {
              imageSelected(AbiliaFile.empty);
            }),
            icon: Icon(
              AbiliaIcons.delete_all_clear,
              color: AbiliaColors.white,
              size: smallIconSize,
            ),
            text: translate.removePicture,
          ),
        ],
      );
    } else {
      return SelectPictureMainContent(
        imageCallback: (newImage) => setState(() {
          imageSelected(newImage);
        }),
      );
    }
  }

  void imageSelected(AbiliaFile newSelectedImage) {
    if (newSelectedImage is UnstoredAbiliaFile) {
      BlocProvider.of<UserFileBloc>(context).add(
        ImageAdded(newSelectedImage),
      );
      BlocProvider.of<SortableBloc>(context).add(
        ImageArchiveImageAdded(
          newSelectedImage.id,
          newSelectedImage.file.path,
        ),
      );
    }
    selectedImage = newSelectedImage;
    context.read<EditActivityBloc>().add(ImageSelected(newSelectedImage));
  }
}
