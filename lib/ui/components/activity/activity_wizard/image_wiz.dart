import 'package:seagull/bloc/all.dart';
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
            child: SelectPictureWidget(
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
