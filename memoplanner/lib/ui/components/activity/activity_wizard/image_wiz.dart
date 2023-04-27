import 'dart:io';

import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/abilia_file.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:sortables/bloc/sortable/sortable_bloc.dart';

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
        imageCallback: (imageAndName) {
          final newImage = imageAndName.image;
          if (newImage is UnstoredAbiliaFile) {
            final now = context.read<ClockBloc>().state;
            final name = DateFormat.yMd(Platform.localeName).format(now);
            BlocProvider.of<UserFileBloc>(context).add(
              FileAdded(newImage, isImage: true),
            );
            BlocProvider.of<SortableBloc>(context).add(
              ImageArchiveImageAdded(
                newImage.id,
                name,
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
