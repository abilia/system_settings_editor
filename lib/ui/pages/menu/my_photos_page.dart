import 'dart:io';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MyPhotosPage extends StatelessWidget {
  const MyPhotosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyPhotosBloc>(
      create: (_) => MyPhotosBloc(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: BlocBuilder<MyPhotosBloc, MyPhotosState>(
        builder: (context, state) => Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.myPhotos,
            iconData: AbiliaIcons.my_photos,
            trailing: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.s),
              child: AddPhotoButton(),
            ),
          ),
          body: GridView.count(
            padding: EdgeInsets.only(
              top: verticalPadding,
              left: leftPadding,
              right: rightPadding,
            ),
            crossAxisCount: 3,
            mainAxisSpacing: 8.0.s,
            crossAxisSpacing: 8.0.s,
            children: state.currentFolderContent
                .where((s) => !s.isGroup)
                .map(
                  (sortable) => Photo(sortable: sortable),
                )
                .toList(),
          ),
          bottomNavigationBar: const BottomNavigation(
            backNavigationWidget: CloseButton(),
          ),
        ),
      ),
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, permissionState) => BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) => ActionButtonLight(
            onPressed: () async {
              if (permissionState
                      .status[Permission.camera]?.isPermanentlyDenied ==
                  true) {
                await showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) =>
                        PermissionInfoDialog(permission: Permission.camera));
              } else {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  final selectedImage =
                      SelectedImageFile.newFile(File(image.path));
                  BlocProvider.of<UserFileBloc>(context).add(
                    ImageAdded(selectedImage),
                  );
                  BlocProvider.of<MyPhotosBloc>(context).add(
                    PhotoAdded(
                      selectedImage.id,
                      selectedImage.file.path,
                      DateFormat.yMd(
                              Localizations.localeOf(context).toLanguageTag())
                          .format(time),
                    ),
                  );
                }
              }
            },
            child: Icon(AbiliaIcons.plus),
          ),
        ),
      );
}

class Photo extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;
  final imageHeight, imageWidth;
  const Photo(
      {Key? key, required this.sortable, this.imageHeight, this.imageWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageArchiveData = sortable.data;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: imageArchiveData.name,
        image: imageArchiveData.fileId.isNotEmpty ||
            imageArchiveData.file.isNotEmpty,
        button: true,
      ),
      child: Container(
        decoration: boxDecoration,
        padding: EdgeInsets.all(4.0.s),
        child: Column(
          children: [
            Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: FadeInAbiliaImage(
                fit: BoxFit.cover,
                width: double.infinity,
                imageFileId: imageId,
                imageFilePath: iconPath,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
