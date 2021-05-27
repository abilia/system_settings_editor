import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MyPhotosPage extends StatelessWidget {
  const MyPhotosPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.myPhotos,
        iconData: AbiliaIcons.my_photos,
        trailing: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.s),
          child: AddPhotoButton(),
        ),
      ),
      body: BlocProvider<MyPhotosBloc>(
        create: (_) => MyPhotosBloc(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: BlocBuilder<MyPhotosBloc, MyPhotosState>(
          builder: (context, state) => GridView.count(
            padding: EdgeInsets.only(
              top: verticalPadding,
              left: leftPadding,
              right: rightPadding,
            ),
            mainAxisSpacing: 8.0.s,
            crossAxisSpacing: 8.0.s,
            crossAxisCount: 3,
            childAspectRatio: 0.92,
            children: state.currentFolderContent
                .map(
                  (sortable) => sortable.isGroup
                      ? LibraryFolder(
                          title: sortable.data.title(),
                          fileId: sortable.data.folderFileId(),
                          filePath: sortable.data.folderFilePath(),
                        )
                      : ArchiveImage(sortable: sortable),
                )
                .toList(),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CloseButton(),
      ),
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ActionButtonLight(
        onPressed: () => {},
        //  Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => CopiedAuthProviders(
        //       blocContext: context,
        //       child: CreateActivityPage(day: day),
        //     ),
        //     settings: RouteSettings(name: 'CreateActivityPage'),
        //   ),
        // ),
        child: Icon(AbiliaIcons.plus),
      );
}
